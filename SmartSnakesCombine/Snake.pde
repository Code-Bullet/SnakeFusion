class Snake {

  int len = 1;//the length of the snake
  PVector pos;//position of the head of the snake
  ArrayList<PVector> tailPositions; //all the positions of the tail of the snake
  PVector vel;//the velocity of the snake i.e. direction it will move next
  PVector temp; //just a temporary PVector which gets used a bunch
  Food food;//the food that this snake needs to eat
  NeuralNet brain; // the neural net controlling the snake
  float[] vision = new float[24]; //the inputs for the neural net
  float[] decision; // the output of the neural net

  int lifetime = 0;//how long the snake lived for
  long fitness = 0;//the quality of this snake
  int leftToLive = 200; //the number of moves left to live if this gets down to 0 the snake dies
  //this is to prevent the snakes doing circles forever

  
  int growCount = 0;//the amount the snake still needs to grow

  boolean alive = true;  //true if the snake is alive
  boolean test = false;//true if the snake is being tested not trained



  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //constructor
  Snake() {
    //set initial position of head and add 3 tail positions since the starting length is 4
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

    //intiate the food
    food = new Food();




    brain = new NeuralNet(24, 18, 4);//create a neural net with 24 input neurons 18 hidden neurons and 4 output neurons
    leftToLive = 200;
  }

  //mutates neural net
  void mutate(float mr) {
    brain.mutate(mr);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //set the velocity from the output of the neural network
  void setVelocity() {
    //get the output of the neural network
    decision = brain.output(vision);

    //get the maximum position in the output array and use this as the decision on which direction to go
    float max = 0;
    int maxIndex  =0;
    for (int i = 0; i < decision.length; i++) {
      if (max < decision[i]) {
        max = decision[i];
        maxIndex = i;
      }
    }
    //set the velocity based on this decision
    if (maxIndex == 0) {
      //if (vel.x!=10 && vel.y !=0) { //this is to stop the snake from going back into its own body but i removed it to teach the snakes to avoid their bodies
      vel.x =-10;
      vel.y =0;
      //}
    } else if (maxIndex == 1) {
      //if (vel.x!=0 && vel.y !=10) {
      vel.x =0;
      vel.y =-10;
      //}
    } else if (maxIndex == 2) {
      //if (vel.x!=-10 && vel.y !=0) {
      vel.x =10;
      vel.y =0;
      //}
    } else {
      //if (vel.x!=0 && vel.y !=-10) {
      vel.x =0;
      vel.y =10;
      //}
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //move the snake in direction of the vel PVector
  void move() {
    //move through time
    lifetime+=1;
    leftToLive -=1;

    //if time left to live is up then kill the snake
    if (leftToLive < 0) {
      alive = false;
    }

    //if the snake hit itself or the edge then kill it
    if (gonnaDie(pos.x + vel.x, pos.y + vel.y)) {
      alive= false;
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
      temp = new PVector(pos.x, pos.y);
      tailPositions.set(len-2, temp);
    }

    //actually move the snakes head
    pos.add(vel);
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //the snake just ate some food 
  void eat() {

    //reset food to a new position  
    food = new Food(); 
    while (tailPositions.contains(food.pos)) { //make sure the food isnt on the snake
      food = new Food();
    }
   
    //increase time left to live
    leftToLive += 100;

    //if testing then grow by 4 but if not and the snake is still small only grow by 1
    //this is for helping snakes evolving so they dont get too big too soon
    if (test||len>=10) {
      growCount += 4;
    } else {
      growCount += 1;
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //display the snake
  void show() {
    fill(255);
    stroke(0);
    //show the tail
    for (int i = 0; i< tailPositions.size(); i++) {
      rect(tailPositions.get(i).x, tailPositions.get(i).y, 10, 10);
    }
    //show the head
    rect(pos.x, pos.y, 10, 10);

    //show the food
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

  //calculate the fitness of the snake after it has died
  void calcFitness() {
    //fitness is based on length and lifetime
    if (len < 10) {
      fitness = floor(lifetime *lifetime * pow(2, (floor(len))));
    } else {
      //grows slower after 10 to stop fitness from getting stupidly big
      //ensure greater than len = 9
      fitness =  lifetime * lifetime;
      fitness *= pow(2, 10);
      fitness *=(len-9);
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //crossover function for genetic algorithm
  Snake crossover(Snake partner) {
    Snake child = new Snake();

    child.brain = brain.crossover(partner.brain);
    return child;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //returns a clone of the snake
  Snake clone() {
    Snake clone = new Snake();
    clone.brain = brain.clone();
    clone.alive = true;
    return clone;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //saves the snake to a file by converting it to a table
  void saveSnake(int snakeNo, int score, int popID) {
    //save the snakes top score and its population id 
    Table snakeStats = new Table();
    snakeStats.addColumn("Top Score");
    snakeStats.addColumn("PopulationID");
    TableRow tr = snakeStats.addRow();
    tr.setFloat(0, score);
    tr.setInt(1, popID);

    saveTable(snakeStats, "data/SnakeStats" + snakeNo+ ".csv");

    //save snakes brain
    saveTable(brain.NetToTable(), "data/Snake" + snakeNo+ ".csv");
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //return the snake saved in the parameter position
  Snake loadSnake(int snakeNo) {

    Snake load = new Snake();
    Table t = loadTable("data/Snake" + snakeNo + ".csv");
    load.brain.TableToNet(t);
    return load;
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