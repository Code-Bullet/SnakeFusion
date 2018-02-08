class World {
  int gen = 0;//the current generation the world is up to

  //all the populations/species in the world 
  Population[] species;

  NeuralNet[] topBrains;//array containing the brains of the snakes of legend
  SuperSnake fusedSnake;//the superFusion snake
  //Snake worldBestSnake; //the best snake out of all the populations
  int worldBestScore = 0;// the best score of the best snake out of all the populations, like a world record

  Snake[] SnakesOfLegend; // the snakes which are loaded from file and are the best ever
  Snake legend; // a temp position to store one of these legends
  int legendNo; // the position the currently tested legend has in the snakes of legend array
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //constructor
  World(int speciesNo, int popSize) {

    //initiate species
    species = new Population[speciesNo];
    for (int i = 0; i< speciesNo; i++) {
      species[i] = new Population(popSize);
    }

    //initiates snakes of legends
    SnakesOfLegend = new Snake[5];
    for (int i = 0; i<SnakesOfLegend.length; i++) {
      SnakesOfLegend[i] = new Snake();
    }

    //initiate topbrains
    topBrains = new NeuralNet[SnakesOfLegend.length];
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //updates all the species in the world
  void updateAlive() {
    for (int i = 0; i< species.length; i++) {
      species[i].updateAlive();
    }
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //runs the genetic algorithm on all the species
  void geneticAlgorithm() {
    for (int i = 0; i< species.length; i++) {
      species[i].calcFitness();
      species[i].naturalSelection();
      //species[i].mutate();
    }
    gen+=1;
    setTopScore();
    //if any of the top snakes from the species is better than the any of the saved snakes then save them
    for (int i = 0; i< species.length; i++) {
      saveTopSnake(i);
    }
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //load the snakes of legend from file
  void loadBestSnakes() {
    for (int i = 0; i< 5; i++) {
      SnakesOfLegend[i] = SnakesOfLegend[i].loadSnake(i);
      
    }
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //creates the super snake from all the snakes of legend
  void snakeFusion() {
    loadBestSnakes();

    //populates the topBrians array with the brains of the best snakes
    for (int i = 0; i< SnakesOfLegend.length; i++) {
      topBrains[i] = SnakesOfLegend[i].brain.clone();
    }

    fusedSnake = new SuperSnake(topBrains);
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //update the state of the supersnake
  void updateSuperSnake() {

    fusedSnake.look();
    fusedSnake.setVelocity(); 
    fusedSnake.move();
    fusedSnake.show();
    saveFrame("output/superSnake/frame_#######.png");
  }  
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //update the legend snake test
  void updateLegend() {

    legend.look();
    legend.setVelocity();
    legend.move();
    legend.show();

  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //test if all the snakes from all the species are dead
  boolean done() {
    for (int i = 0; i< species.length; i++) {
      if (!species[i].done()) {
        return false;
      }
    }
    return true;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //set the top score from the global best scores of each species
  void setTopScore() {
    long max = 0;
    int maxIndex = 0;
    for (int i = 0; i< species.length; i++) {
      if (species[i].globalBestFitness > max ) {
        max = species[i].globalBestFitness;
        maxIndex = i;
      }
    }

    worldBestScore = species[maxIndex].globalBest;
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //saves the top snake of the parameter no. species if it has a better score than any of the legends
  void saveTopSnake(int speciesNo) {

    //load the data about which legend spaces have already been assigned a snake 
    Table t = loadTable("data/snakesStored.csv");
    int snakeNo = -1;
    TableRow tr = t.getRow(0);
    for (int i = 0; i< t.getColumnCount(); i++) {
      if (tr.getInt(i) == 0) {
        snakeNo = i;
        break;
      }
    }
    //if there are any free spaces store the top snake of this species
    if (snakeNo!= -1) {
      species[speciesNo].globalBestSnake.clone().saveSnake(snakeNo, species[speciesNo].globalBest, species[speciesNo].populationID);
      tr=t.getRow(0);
      tr.setInt(snakeNo, 1);
      saveTable(t, "data/snakesStored.csv");
    } else {
      //if snake positions are full
      //check for snakes from this population to stop snakes from the same generation populating the entire legend list
      Table t1;
      TableRow tr1;
      for (int i = 0; i< t.getColumnCount(); i++) {
        t1 = loadTable("data/SnakeStats" + i+ ".csv", "header");
        tr1 = t1.getRow(0);
        if (tr1.getInt(1) == species[speciesNo].populationID) {
          if (species[speciesNo].globalBest > tr1.getInt(0)) { //if the currently loaded snake is from this population and worse than the best snake
            species[speciesNo].globalBestSnake.clone().saveSnake(i, species[speciesNo].globalBest, species[speciesNo].populationID);//save the snake
          }
          return;//exit the function
        }
      }

      //if no snakes from this species are stored then overload the legend with the lowest score if its lower than the score of the top snake of this species

      int min = species[speciesNo].globalBest;
      int minIndex = -1;

      for (int i = 0; i< t.getColumnCount(); i++) {
        t1 = loadTable("data/SnakeStats" + i+ ".csv", "header");
        tr1 = t1.getRow(0);
        if (tr1.getInt(0) < min) {
          min = tr1.getInt(0);
          minIndex = i;//
        }
      }

      //if the snake to be saved isnt better than any of them dont save it
      if (minIndex!= -1) {
        species[speciesNo].globalBestSnake.clone().saveSnake(minIndex, species[speciesNo].globalBest, species[speciesNo].populationID);//save snake
      }
    }
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //get a legend ready for testing
  void playLegend(int snakeNo) {
    loadBestSnakes();
    legend = SnakesOfLegend[snakeNo].clone();
    legendNo = snakeNo;
    legend.test = true;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------  

  //for training the legends to reach higher levels of awesome
  World( int popSize, Snake[] legendsArray) {

    //initiate species
    species = new Population[legendsArray.length];

    //set each population to be a mutated version of the legend in the array
    for (int i = 0; i< legendsArray.length; i++) {
      species[i] = new Population(popSize, legendsArray[i]);
    }

    //set the population ID's for each population to stop overwriting the snakes data
    Table t ;
    for (int i = 0; i< legendsArray.length; i++) {
      t = loadTable("data/SnakeStats" + i+ ".csv", "header");
      TableRow tr = t.getRow(0);
      species[i].populationID = tr.getInt(1);
    }
  }
  
}