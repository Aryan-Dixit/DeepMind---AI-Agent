class FlyObs {
  float w = 60;
  float h = 50;
  float posX;
  float posY;
  int flapCount = 0;
  int typeOfFOb;
  FlyObs(int type) {
    posX = width;
    typeOfFOb = type;
    switch(type) {
    case 0://flying low
      posY = 10 + h/2;
      break;
    case 1://flying middle
      posY = 100;
      break;
    case 2://flying high
      posY = 180;
      break;
    }
  }

  void show() {
    flapCount++;
    
    if (flapCount < 0) {
      image(FloatOb1,posX-FloatOb1.width/2,height - groundHeight - (posY + FloatOb1.height-20));
    } else {
      image(FloatOb2,posX-FloatOb2.width/2,height - groundHeight - (posY + FloatOb2.height-20));
    }
    if(flapCount > 15){
     flapCount = -15; 
      
    }
  }
  void move(float speed) {
    posX -= speed;
  }

  boolean collided(float AvatarX, float AvatarY, float AvatarWidth, float AvatarHeight) {

    float AvatarLeft = AvatarX - AvatarWidth/2;
    float AvatarRight = AvatarX + AvatarWidth/2;
    float thisLeft = posX - w/2 ;
    float thisRight = posX + w/2;

    if ((AvatarLeft<= thisRight && AvatarRight >= thisLeft ) || (thisLeft <= AvatarRight && thisRight >= AvatarLeft)) {
      float AvatarUp = AvatarY + AvatarHeight/2;
      float AvatarDown = AvatarY - AvatarHeight/2;
      float thisUp = posY + h/2;
      float thisDown = posY - h/2;
      if (AvatarDown <= thisUp && AvatarUp >= thisDown) {
        return true;
      }
    }
    return false;
  }
}
