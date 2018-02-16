class UI {
//todo: real fps log
//todo: add frame speed
//todo: show config todo dialog

  int vpWidth;
  int vpHeight;
  
  int fillColor = 255;
  int textColor = 255;
  
  int statisticsTextSize = 30;
  int legendTextSize = 20;
  
  int matrixHeight = 400;
  int legendHeight;
  
  int legendTextPosition;
  
  int[] dataDimensions = new int[4];
  int[] legendDimensions = new int[4];
  
  int colNo = 3;
  int colSize;
      
  int[] rows = new int[4];
  int[] cols = new int[colNo];
  
  
  UI(int viewportWidth, int viewportHeight) {
    vpWidth = viewportWidth;
    vpHeight = viewportHeight;
    
    size(windowWidth, windowHeight);
    calculateSections();
  }
  
  
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  void drawData() {
    fill(fillColor);
    stroke(textColor);
    line(400, 0, 400, 400);
    line(0, 400, 800, 400);
    textSize(30);
  
    //training/evolving the legend snakes
    if (trainLegendSnakes) {
      drawStatistics(worldOfLegends.gen, worldOfLegends.worldBestScore, true);      
  
      //testing a single legend
    } else if (showingLegend) {
      drawStatistics(world.gen, world.legend.len-4, false);
      // testing the supersnake fusion
    } else if (fusionGo) {
      drawStatistics(world.gen, world.fusedSnake.len-4, false);
  
      //training/evolving population normally
    } else {
      drawStatistics(world.gen, world.worldBestScore, false);
    }
  }
  
  void drawLegend() {
    
      fill(fillColor);
      stroke(textColor);
      line(400, 0, 400, 400);
      line(0, 400, 800, 400);

      line(cols[1] - 5, matrixHeight, cols[1] - 5, vpHeight);
      line(cols[2] - 5, matrixHeight, cols[2] - 5, vpHeight);
      
      textSize(legendTextSize);   
      
      text("\"+\" - increase speed by 10", cols[0], rows[0]);
      text("\"-\" - decrease speed by 10", cols[0], rows[1]);
      text("\"d\" - double mut. rate", cols[0], rows[2]);
      text("\"h\" - halve mut. rate", cols[0], rows[3]);
      
      text("\"l\" - train legends", cols[1], rows[0]);
      text("\"f\" - fuse a legend", cols[1], rows[1]);
      text("\"0-4\" - choose legend", cols[1], rows[2]);
      text("\" \" - show all", cols[1], rows[3]);
      
      fill(255);
      stroke(0);
      rect(cols[2], rows[0] - 10, 10, 10);
      fill(fillColor);
      text("normal", cols[2] + 20, rows[0]);
      
      fill(0,255,0);
      rect(cols[2], rows[1] - 10, 10, 10);
      fill(fillColor);
      text("food found", cols[2] + 20, rows[1]);
      
      fill(0,0,255);
      rect(cols[2], rows[2] - 10, 10, 10);
      fill(fillColor);
      text("food seen", cols[2] + 20, rows[2]);
  }
  
  private void drawStatistics(int generation, int score, boolean showGlobalScore) {
    if (!showGlobalScore) {
      text("Legend: " + (world.legendNo), 10, 40);
    }
      text("Generation: " + (generation), 10, 80); 
      if (showGlobalScore) {
          text("Global Best: " + (score), 10, 120);        
      } else {
          text("Score: " + (score), 10, 120);
      }
      text("Speed: " + speed, 10, 200);
      text("Mutation Rate: " + globalMutationRate, 10, 240);
      text("Training legends: " + (trainLegendSnakes ? "on" : "off"), 10, 280);
      text("Show all: " + (showAll ? "on" : "off"), 10, 320);
  }
  
  private void calculateSections() {
    colSize = this.vpWidth / colNo;
    legendHeight = vpHeight - matrixHeight;
    this.dataDimensions[0] = this.dataDimensions[2] = vpWidth / 2 ;
    this.dataDimensions[1] = this.dataDimensions[3] = matrixHeight ;
    
    this.legendDimensions[0] = this.legendDimensions[2] = vpHeight - legendHeight;
    
    this.legendTextPosition = this.dataDimensions[1] + legendTextSize;
    
    rows[0] = legendTextPosition;
      for (int i = 1; i < rows.length; i = i+1) {
        rows[i] = rows[i-1] + legendTextSize;
      }
      
      cols[0] = 10;
      for (int i = 1; i < cols.length; i = i+1) {
        cols[i] = cols[i-1] + colSize;
      }
  }
}