class Food {
  PVector pos;//position of food

  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //constructor
  Food() {
    

    pos = new PVector();
    // set position to a random spot 
    pos.x = 400+floor(random(0, 40)) * 10;
    pos.y = floor(random(0, 40)) * 10;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //show the food as a red square
  void show() {
    fill(255, 0, 0);
    rect(pos.x, pos.y, 10, 10);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------  
  //return a clone of this food 
  Food clone() {
    Food clone = new Food();
    clone.pos = new PVector(pos.x, pos.y);

    
    return clone;
  }

}