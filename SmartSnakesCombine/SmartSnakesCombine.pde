//GLOBAL VARIABLES
import java.io.File;
World world;//world which stores the species / populations

World worldOfLegends;//world containing the legends, used for training the legends to be even better
UI ui; //contains the ui elements

int speed = 30;//the frame rate

//booleans used to control the game state
boolean showAll = true;//whether to show all the snakes in the generation or just the current best snake
boolean trainLegendSnakes = false; //true if training the legends i.e. if running worldOfLegends
boolean showingLegend = false;//true if testing just one legend
boolean fusionGo =false;//true if testing the snake fusion 

float globalMutationRate = 0.01;

int windowWidth = 800;
int windowHeight = 500;

//---------------------------------------------------------------------------------------------------------------------------------------------------------
void settings() {
  ui = new UI(windowWidth, windowHeight);
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
//run on startup
void setup() {
  frameRate(speed);
  world = new World(5, 2000);
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------  
void draw() {
  background(40);

  ui.drawData();
  ui.drawLegend();
  
  //training/evolving the legend snakes
  if (trainLegendSnakes) {
    if (!worldOfLegends.done()) {
      worldOfLegends.updateAlive();
    } else {
      //all are dead
      worldOfLegends.geneticAlgorithm();
    }

    //testing a single legend
  } else if (showingLegend) {
    if (world.legend.alive) {
      world.updateLegend();
    } else {
      if(world.legend.len < 100){
        
        world.playLegend(world.legendNo);
      }else{

      showingLegend = false;
      }
    }

    // testing the supersnake fusion
  } else if (fusionGo) {
    if (world.fusedSnake.alive) {
      world.updateSuperSnake();
    } else { //once done set the fusionGo to false
      fusionGo = false;
    }


    //training/evolving population normally
  } else {
    if (!world.done()) {//if there is still a snake alive then update them
      world.updateAlive();
    } else {//if all are dead :(
      world.geneticAlgorithm();
    }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------------------  

void keyPressed() {
  switch(key) {
  case ' '://toggle show all
    showAll = !showAll;
    break;
  case '+'://speed up frame rate
    speed += 10;
    frameRate(speed);
    break;
  case '-'://slow down frame rate
    if (speed > 10) {
      speed -= 10;
      frameRate(speed);
    }
    break;
  case 'f'://create a fused snake from the legends
    fusionGo  = true;
    world.snakeFusion();
    break;
  case '0'://test legend 0
    showingLegend = true;
    world.playLegend(0);
    break;
  case '1': // test legend no 1
    world.playLegend(1);
    showingLegend = true;
    break;
  case '2'://test legend no 2
    world.playLegend(2);
    showingLegend = true;
    break;
  case '3'://test legend no 3
    world.playLegend(3);
    showingLegend = true;
    break;
  case '4'://test legend no 4
    world.playLegend(4);
    showingLegend = true;
    break;
  case 'h'://halve the mutation rate
    globalMutationRate /= 2;
    break;
  case 'd'://double the mutation rate
    globalMutationRate *= 2;
    break;
  case 'l'://train the legends
    trainLegendSnakes =!trainLegendSnakes;
    if (trainLegendSnakes == true) {//load best snakes from file and setup worldOfLegends
      world.loadBestSnakes();
      worldOfLegends = new World(1000, world.SnakesOfLegend);
    }

    
  }
}