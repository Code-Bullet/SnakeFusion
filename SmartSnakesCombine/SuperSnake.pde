//a supersnake which is fusion of 5 best snakes

class SuperSnake {




  int len = 1;//the length of the snake
  PVector pos;//position of the head of the snake
  ArrayList<PVector> tailPositions; //all the positions of the tail of the snake
  PVector vel;//the velocity of the snake i.e. direction it will move next
  PVector temp; //just a temporary PVector which gets used a bunch
  Food food;//the food that this snake needs to eat

  float[] vision = new float[24]; //the inputs for the neural net
  float[] decision; // the output of the neural net

  int lifetime = 0;//how long the snake lived for
  long fitness = 0;//the quality of this snake
  int leftToLive = 500; //the number of moves left to live if this gets down to 0 the snake dies
  //this is to prevent the snakes doing circles forever



  int growCount = 0; //the amount the snake still needs to grow

  boolean alive = true;  //true if the snake is alive



  NeuralNet[] brain; // the array of neural nets controlling the snake

  SuperSnakeClone[] clones;

  int brainToFollow = 0;  //which brain to follow for the next few moves
  boolean foodFound = false;//true if a clone has found the food safely
  boolean sawFood = false; //true if a clone has seen the food
  int movesToFollow = 0;//how many moves to follow that snake


  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //constructor
  SuperSnake(NeuralNet[] demBrains) {
    //set intial position of head and add 3 tail positions
    int x = 600;
    int y = 200;
    pos = new PVector(x, y);
    vel = new PVector(10, 0);
    tailPositions = new ArrayList<PVector>();
    temp = new PVector(x-30, y);
    tailPositions.add(temp);
    temp = new PVector(x-20, y);
    tailPositions.add(temp);
    temp = new PVector(x-10, y);
    tailPositions.add(temp);
    len+=3;

    food = new Food();
    

    brain = demBrains;

    clones = new SuperSnakeClone[demBrains.length];
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //calculates the best direction to go based on the foresight from all of its brains 
  void bestDecision() {
    


    //for each brain create a clone and run it until it dies or is trapped or finds food
    for (int i = 0; i < brain.length; i++) {
      clones[i] = new SuperSnakeClone(this, brain[i]);
      clones[i].runClone();
      
    }
    
    //if any clones found the food find the one which does it in the least number of moves
    int min = 1000;
    int cloneAteFood = -1;
    for (int i = 0; i < brain.length; i++) {

      if (clones[i].foodFound) {
        if (clones[i].moveCount < min) {
          min =  clones[i].foodSeenAtCount;
          cloneAteFood = i;

        }
      }
    }
     //if any of the clones ate the food
    if (cloneAteFood != -1) {
      //set this clone as the brain to follow
      foodFound = true; 
      movesToFollow = clones[cloneAteFood].moveCount;
      brainToFollow = cloneAteFood;
      return;//we are done
    }
    

    //if you get to this point then none of the snakes found the food so lets test for the next best 
    //has any seen the food

     min = 1000;
    int cloneSeenFood = -1;
    for (int i = 0; i < brain.length; i++) {

      if (clones[i].seenFood) {
        if (clones[i].foodSeenAtCount < min) {
          min =  clones[i].foodSeenAtCount;
          cloneSeenFood = i;
        }
      }
    }

    //if any of the clones saw the food
    if (cloneSeenFood != -1) {
      sawFood = true; 
      movesToFollow = clones[cloneSeenFood].foodSeenAtCount;
      brainToFollow = cloneSeenFood;
      return;
    }


    //if you get to this point then no snake found the food nor did they see the food, damn
    //follow the snake which made it the furthest without running out of moves (because they would probably be looping)

    int max = 0;
    int cloneLastedLongest = 0;
    for (int i = 0; i < brain.length; i++) {

      if (!clones[i].ranOut) {
        if (clones[i].moveCount > max) {
          max =  clones[i].moveCount;
          cloneLastedLongest = i;
        }
      }
    }

    brainToFollow = cloneLastedLongest;
    movesToFollow = 1;
    return;
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

 
  void setVelocity() {
    look();
    //if no more moves to follow then create clones to 'imagine' where to go
    if (movesToFollow <= 0) {
      sawFood = false;
      foodFound = false;
      bestDecision();
    }

    //get the direction from the brain 
    int direction  = getDirection(brain[brainToFollow].output(vision));

    //set the velocity based on this decision
    switch(direction) {
    case 0://left
      vel = new PVector(-10, 0);
      break;
    case 1://up
      vel = new PVector(0, -10);
      break;
    case 2://right
      vel = new PVector(10, 0);
      break;
    case 3://down
      vel = new PVector(0, 10);
      break;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //move the snake in direction of the vel PVector
  void move() {
    lifetime+=1;
    leftToLive -=1;
    movesToFollow -=1;
    
    //if time left to live is up then kill the snake
    if (leftToLive < 0) {
      alive = false;
      println("fuck1");
    }
    
    //if the snake hit itself or the edge then kill it
    if (gonnaDie(pos.x + vel.x, pos.y + vel.y)) {
      alive= false;
      println("fuck2");

    }

    //if the snake is on  the same position as the food then eat it
    if (pos.x + vel.x == food.pos.x && pos.y + vel.y == food.pos.y) {
      eat();
    }
    
     //snake grows 1 square at a time so if the snake has recently eaten then grow count will be greater than 0
    if (growCount > 0) {
      growCount --;
      grow();
    } else {//not growing then move all the tail positions to follow the head
      for (int i = 0; i< tailPositions.size() -1; i++) {
        temp = new PVector(tailPositions.get(i+1).x, tailPositions.get(i+1).y);
        tailPositions.set(i, temp);
      }

      if (len>1) {
        temp = new PVector(pos.x, pos.y);
        tailPositions.set(len-2, temp);
      }
    }

    //actually move the head of the snake
    pos.add(vel);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
//the snake just ate some food 
  void eat() {
    
    //reset the food so its not on the tail
    food = new Food(); 
    while (tailPositions.contains(food.pos)) {
      food = new Food();
    }


    //let the snake live longer
    leftToLive += 100;
    growCount +=4;//the snake grows by 4
    movesToFollow =0;//make sure the bestDecision() function is called before the next move
    foodFound = false;
    
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //show the super snake
  void show() {
    fill(255);
    stroke(0);
    //if a clone has found the food then show the snake as blue
    if(foodFound){
     fill(0,255,0); 
    }else if(sawFood){
     fill(0,0,255); 
    }
    
    
    for (int i = 0; i< tailPositions.size(); i++) {
      rect(tailPositions.get(i).x, tailPositions.get(i).y, 10, 10);
    }
    rect(pos.x, pos.y, 10, 10);
    food.show();
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