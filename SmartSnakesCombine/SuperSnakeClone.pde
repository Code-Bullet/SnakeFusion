//a clone or thought which is used to plan ahead

class SuperSnakeClone {

  int len = 1;//the length of the snake
  PVector pos;//position of the head of the snake
  ArrayList<PVector> tailPositions; //all the positions of the tail of the snake
  PVector vel;//the velocity of the snake i.e. direction it will move next
  PVector temp; //just a temporary PVector which gets used a bunch
  Food food;//the food that this snake needs to eat
  NeuralNet brain; // the neural net controlling the snake
  float[] vision = new float[24]; //the inputs for the neural net
  float[] decision; // the output of the neural net
  ArrayList<PVector> blanks = new ArrayList<PVector>();//all the blank spaces that are enclosed by the snake used to tell if the snake is trapped 

  int leftToLive = 200; //the number of moves left ot live if this gets down to 0 the snake dies
  //this is to prevent the snakes doing circles forever


  int moveCount = 0;  //the amount of moves the clone has done
  boolean alive = true;  //true if the snake is alive
  boolean foodFound = false; // true if the snake found the food
  boolean trapped = false;//true if the snake is trapped


  boolean seenFood = false;//whether the snake saw the food
  int foodSeenAtCount = 300;
  boolean ranOut = false; //true if after 500 moves the clone hasnt died, gotten trapped or eaten the food, so its probably looping


  int growCount = 0;



  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //constructor
  SuperSnakeClone(SuperSnake original, NeuralNet chosenBrain) {
    //copy the position, tailPositions, length, brain, time to live and food from the original

    pos = new PVector(original.pos.x, original.pos.y);
    tailPositions = (ArrayList)original.tailPositions.clone();
    len = original.len;
    food = original.food.clone();
    brain = chosenBrain.clone();
    leftToLive = original.leftToLive;
    growCount = original.growCount;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  //runs the clone until it dies, finds the food is trapped or takes over 500 moves to do any of these things
  void runClone() {
    for (int i = 0; i< 500; i++) {
      //update clone
      look();
      setVelocity();
      move();
      if (!alive || foodFound || trapped) {//if anything interesting happened then stop the clone        
        return;
      }

    }
    ranOut = true; // the snake is probably in a loop
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------

  //from an output array returns an int indicating the direction the snake should go
  int getDirection(float[] netOutputs) {
    float max = 0;
    int maxIndex = 0;

    for (int i = 0; i < netOutputs.length; i++) {
      if (max < netOutputs[i]) {
        max = netOutputs[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //set the velocity from the output of the neural network
  void setVelocity() {
    //get the output of the neural network
    int direction = getDirection(brain.output(vision));

    //get the maximum position in the output array and use this as the decision on which direction to go

    //set the velocity based on this decision
    switch(direction) {
    case 0:
      vel = new PVector(-10, 0);
      break;
    case 1:
      vel = new PVector(0, -10);
      break;
    case 2:
      vel = new PVector(10, 0);
      break;
    case 3:
      vel = new PVector(0, 10);
      break;
    }
  }


  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //move the snake in direction of the vel PVector
  void move() {

    //increment moveCount
    moveCount+=1;
    //move through time
    leftToLive -=1;

    //if time left to live is up then kill the snake
    if (leftToLive < 0) {
      alive = false;
      return;
    }

    //if the snake hit itself or the edge then kill it
    if (gonnaDie(pos.x + vel.x, pos.y + vel.y)) {
      alive= false;
      return;
    }

    //if the snake is trapped then set it as trapped and end the clone
    if (isTrapped()) {
      trapped = true;
      return;
    }

    //if the snake is on  the same position as the food then set it as found food and end the clone
    //Note the snake cannot be trapped and find food so no need to test it
    if (pos.x + vel.x == food.pos.x && pos.y + vel.y == food.pos.y) {
      foodFound = true;
      return;
    }


    //not growing then move all the tail positions to follow the head
    //nice
    if (growCount > 0) {
      growCount --;
      grow();
    } else {
      for (int i = 0; i< tailPositions.size() -1; i++) {
        temp = new PVector(tailPositions.get(i+1).x, tailPositions.get(i+1).y);
        tailPositions.set(i, temp);
      }

      if (len>1) {
        temp = new PVector(pos.x, pos.y);
        tailPositions.set(len-2, temp);
      }
    }
    //actually move the snakes head
    pos.add(vel);

    //if the clone can see the food and hasnt already seen the food (we want the shortest point to seeing the food) then set the number of moves it took to see it
    if (!seenFood && seeFood()) {
      seenFood = true;
      foodSeenAtCount = moveCount;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //grows the snake by 1 square
  void grow() {
    //add the head to the tail list this simulates the snake growing as the head is the only thing which moves
    temp = new PVector(pos.x, pos.y);
    tailPositions.add(temp);
    len +=1;
  }


  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //is the food within sight (only 4 directions) cannot see through tail
  boolean seeFood() {
    //look in 4 directions for the food
    PVector left = new PVector(pos.x-10, pos.y);
    PVector right = new PVector(pos.x+10, pos.y);
    PVector up = new PVector(pos.x, pos.y-10);
    PVector down = new PVector(pos.x, pos.y+10);


    //look left until found the wall the snakes body or the food
    //while the left vector is not on the tail or out 
    while (!gonnaDie(left.x, left.y)) {
      //if the left vector is on the food then the snake can see the food and thus return true
      if (left.x == food.pos.x && left.y == food.pos.y) {
        return true;
      }
      //look further left
      left.x-=10;
    }
    //look right for food
    while (!gonnaDie(right.x, right.y)) {
      if (right.x == food.pos.x && right.y == food.pos.y) {
        return true;
      }
      right.x+=10;
    }

    //look up for food
    while (!gonnaDie(up.x, up.y)) {
      if (up.x == food.pos.x && up.y == food.pos.y) {
        return true;
      }
      up.y -=10;
    }
    //look down for food
    while (!gonnaDie(down.x, down.y)) {
      if (down.x == food.pos.x && down.y == food.pos.y) {
        return true;
      }
      down.y+=10;
    }

    //if not seen in any of the 4 directions then return false
    return false;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  //returns true if the snake is going to hit itself or a wall
  boolean gonnaDie(float x, float y) {
    //check if hit wall
    if (x < 400 || y < 0 || x >= 800 || y >= 400) {
      return true;
    }

    //check if hit tail
    return isOnTail(x, y);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------    
  //returns true if the coordinates is on the snakes tail
  boolean isOnTail(float x, float y) {
    for (int i = 0; i < tailPositions.size(); i++) {
      if (x == tailPositions.get(i).x &&  y == tailPositions.get(i).y) {
        return true;
      }
    }

    return false;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //this function return whether or not the snake is trapped, trapped meaning that the snake is trapped within its own tail
  boolean isTrapped() {
    //stores all the points within the tails 'trap' 
    blanks = new ArrayList<PVector>();
    countNextTo(pos.x, pos.y);//call recursive function to add all the blanks which are reachable from the head of the snake
    
    //if the amount of spaces is less than half the remaining positions(1600 - tailPositions.size()) or less than 300 whichever is less
    //then it considered as trapped so return true 
    //otherwise return false
    return (blanks.size() <= min((1600 - tailPositions.size())/2, 300));
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  
  //adds all the blanks which are reachable from the head of the snake to the blanks ArrayList 
  //see isTrapped function above for more info
  //recursively  calls itself to find all blanks within the snakes tail
  void countNextTo(float x, float y) {
    //no need to add more positions to blank if already considered not trapped
    if (blanks.size() <= min((1600 - tailPositions.size())/2, 300)) {
      temp = new PVector(x+10, y);//the position to check if its blank
      
      //if not out or on the tail then add it to the blank ArrayList and then look for other blanks around that position by calling this function again 
      if (!gonnaDie(temp.x, temp.y) && !blanks.contains(temp)) {
        blanks.add(temp);
        countNextTo(temp.x, temp.y);
      }
      //look to the left
      temp = new PVector(x-10, y);
      if (!gonnaDie(temp.x, temp.y) && !blanks.contains(temp)) {
        blanks.add(temp);
        countNextTo(temp.x, temp.y);
      }
      //look down
      temp = new PVector(x, y+10);
      if (!gonnaDie(temp.x, temp.y) && !blanks.contains(temp)) {
        blanks.add(temp);
        countNextTo(temp.x, temp.y);
      }
      //look up
      temp = new PVector(x, y-10);
      if (!gonnaDie(temp.x, temp.y) && !blanks.contains(temp)) {
        blanks.add(temp);
        countNextTo(temp.x, temp.y);
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //looks in 8 directions to find food,walls and its tail
  void look() {
    vision = new float[24];
    //look left
    float[] tempValues = lookInDirection(new PVector(-10, 0));
    vision[0] = tempValues[0];
    vision[1] = tempValues[1];
    vision[2] = tempValues[2];
    //look left/up  
    tempValues = lookInDirection(new PVector(-10, -10));
    vision[3] = tempValues[0];
    vision[4] = tempValues[1];
    vision[5] = tempValues[2];
    //look up
    tempValues = lookInDirection(new PVector(0, -10));
    vision[6] = tempValues[0];
    vision[7] = tempValues[1];
    vision[8] = tempValues[2];
    //look up/right
    tempValues = lookInDirection(new PVector(10, -10));
    vision[9] = tempValues[0];
    vision[10] = tempValues[1];
    vision[11] = tempValues[2];
    //look right
    tempValues = lookInDirection(new PVector(10, 0));
    vision[12] = tempValues[0];
    vision[13] = tempValues[1];
    vision[14] = tempValues[2];
    //look right/down
    tempValues = lookInDirection(new PVector(10, 10));
    vision[15] = tempValues[0];
    vision[16] = tempValues[1];
    vision[17] = tempValues[2];
    //look down
    tempValues = lookInDirection(new PVector(0, 10));
    vision[18] = tempValues[0];
    vision[19] = tempValues[1];
    vision[20] = tempValues[2];
    //look down/left
    tempValues = lookInDirection(new PVector(-10, 10));
    vision[21] = tempValues[0];
    vision[22] = tempValues[1];
    vision[23] = tempValues[2];
  }


  float[] lookInDirection(PVector direction) {
    //set up a temp array to hold the values that are going to be passed to the main vision array
    float[] visionInDirection = new float[3];

    PVector position = new PVector(pos.x, pos.y);//the position where we are currently looking for food or tail or wall
    boolean foodIsFound = false;//true if the food has been located in the direction looked
    boolean tailIsFound = false;//true if the tail has been located in the direction looked 
    float distance = 0;
    //move once in the desired direction before starting 
    position.add(direction);
    distance +=1;

    //look in the direction until you reach a wall
    while (!(position.x < 400 || position.y < 0 || position.x >= 800 || position.y >= 400)) {

      //check for food at the position
      if (!foodIsFound && position.x == food.pos.x && position.y == food.pos.y) {
        visionInDirection[0] = 1;
        foodIsFound = true; // dont check if food is already found
      }

      //check for tail at the position
      if (!tailIsFound && isOnTail(position.x, position.y)) {
        visionInDirection[1] = 1/distance;
        tailIsFound = true; // dont check if tail is already found
      }

      //look further in the direction
      position.add(direction);
      distance +=1;
    }

    //set the distance to the wall
    visionInDirection[2] = 1/distance;

    return visionInDirection;
  }
}