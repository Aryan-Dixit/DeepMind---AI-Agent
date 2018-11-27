class Floor{
  float posX = width;
  float posY = height -floor(random(groundHeight - 20,groundHeight +30));
  
  Floor(){}
 
  void show(){
    stroke(0);
    strokeWeight(3);

  }
  void move(float speed) {
    posX -= speed;
  } 
}
