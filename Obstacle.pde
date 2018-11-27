//Uses Processing Libraries to generate the obstacles

class Obstacle {
  float posX;
  int w ;
  int h ;
  int type; 
  Obstacle(int t) {
    posX = width;
    type = t;
    switch(type) {
    case 0://small obstacle
      w = 40;
      h = 80;
      break;
    case 1://big obstacle
      w = 60;
      h = 120;
      break;
    case 2://collection of obstacles
      w = 120;
      h = 80;
      break;
    }
  }


//show function to generate the obstacles
  void show() {
    fill(0);
    rectMode(CENTER);
    switch(type) {
    case 0:
      image(obSmall, posX - obSmall.width/2, height - groundHeight - obSmall.height);
      break;
    case 1:
      image(obBig, posX - obBig.width/2, height - groundHeight - obBig.height);
      break;
    case 2:
      image(ManyObs, posX - ManyObs.width/2, height - groundHeight - ManyObs.height);
      break;
    }
  }
  
  //Move obstacles along with game progression
  void move(float speed) {
    posX -= speed;
  }
  boolean collided(float AvatarX, float AvatarY, float AvatarWidth, float AvatarHeight) {

    float AvatarLeft = AvatarX - AvatarWidth/2;
    float AvatarRight = AvatarX + AvatarWidth/2;
    float thisLeft = posX - w/2 ;
    float thisRight = posX + w/2;

    if ((AvatarLeft<= thisRight && AvatarRight >= thisLeft ) || (thisLeft <= AvatarRight && thisRight >= AvatarLeft)) {
      float AvatarDown = AvatarY - AvatarHeight/2;
      float thisUp = h;
      if (AvatarDown <= thisUp) {
        return true;
      }
    }
    return false;
  }
}
