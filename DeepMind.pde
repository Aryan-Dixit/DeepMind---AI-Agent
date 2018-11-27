int nextConnectionNo = 1000;
Populate pop;
int frameSpeed = 60;


boolean showBestEachGen = false;
int upToGen = 0;
Avatar genAvatarTemp;

boolean showNothing = false;


//image repository
PImage fig1;
PImage fig2;
PImage fig3;
PImage fig4;
PImage fig5;
PImage obSmall;
PImage ManyObs;
PImage obBig;
PImage FloatOb1;
PImage FloatOb2;


ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
ArrayList<FlyObs> FObs = new ArrayList<FlyObs>();
ArrayList<Floor> grounds = new ArrayList<Floor>();


int obstacleTimer = 0;
int minimumTimeBetweenObstacles = 60;
int randomAddition = 0;
int groundCounter = 0;
float speed = 10;

int groundHeight = 250;
int AvatarXpos = 150;

ArrayList<Integer> obstacleHistory = new ArrayList<Integer>();
ArrayList<Integer> randomAdditionHistory = new ArrayList<Integer>();


void setup() {

  frameRate(60);
  fullScreen();
  fig1 = loadImage("fig1.png");
  fig2 = loadImage("fig2.png");
  fig3 = loadImage("fig3.png");
  fig4 = loadImage("fig4.png");
  fig5 = loadImage("fig5.png");

  obSmall = loadImage("obSmall.png");
  obBig = loadImage("obBig.png");
  ManyObs = loadImage("ManyObs.png");
  FloatOb1 = loadImage("FloatOb1.png");
  FloatOb2 = loadImage("FloatOb2.png");

  pop = new Populate(500);
}


void draw() {
  drawToScreen();
  if (showBestEachGen) {//show the best of each gen
    if (!genAvatarTemp.dead) {//if current gen Avatar is not dead then update it
      genAvatarTemp.updateLocalObstacles();
      genAvatarTemp.look();
      genAvatarTemp.think();
      genAvatarTemp.update();
      genAvatarTemp.show();
    } else {
      upToGen ++;
      if (upToGen >= pop.genAvatars.size()) {
        upToGen= 0;
        showBestEachGen = false;
      } else {
        genAvatarTemp = pop.genAvatars.get(upToGen).cloneForReplay();
      }
    }
  } else {
    if (!pop.done()) {
      updateObstacles();
      pop.updateAlive();
    } else {
      //genetic function
      pop.naturalSelection();
      resetObstacles();
    }
  }
}



//draws the display screen
void drawToScreen() {
  if (!showNothing) {
    background(250); 
    stroke(0);
    strokeWeight(2);
    line(0, height - groundHeight - 30, width, height - groundHeight - 30);
    //drawBrain();
    writeInfo();
  }
}

//Write Gen info and score
void writeInfo() {
  fill(200);
  textAlign(LEFT);
  textSize(40);
  if (showBestEachGen) {
    text("Score: " + genAvatarTemp.score, 30, height - 30);
    textAlign(RIGHT);
    text("Gen: " + (genAvatarTemp.gen +1), width -40, height-30);
    textSize(20);
 
  } else { //evolving normally 
    text("Score: " + floor(pop.populationLife/3.0), 30, height - 30);
    //text(, width/2-180, height-30);
    textAlign(RIGHT);

    text("Gen: " + (pop.gen +1), width -40, height-30);
    textSize(20);
  }
}


//Update Obstacle evry frame 
void updateObstacles() {
  obstacleTimer ++;
  speed += 0.002;
  if (obstacleTimer > minimumTimeBetweenObstacles + randomAddition) { 
    addObstacle();
  }
  groundCounter ++;
  if (groundCounter> 10) {
    groundCounter =0;
    grounds.add(new Floor());
  }

  moveObstacles();
  if (!showNothing) {
    showObstacles();
  }
}

void moveObstacles() {
  println(speed);
  for (int i = 0; i< obstacles.size(); i++) {
    obstacles.get(i).move(speed);
    if (obstacles.get(i).posX < -AvatarXpos) { 
      obstacles.remove(i);
      i--;
    }
  }

  for (int i = 0; i< FObs.size(); i++) {
    FObs.get(i).move(speed);
    if (FObs.get(i).posX < -AvatarXpos) {
      FObs.remove(i);
      i--;
    }
  }
  for (int i = 0; i < grounds.size(); i++) {
    grounds.get(i).move(speed);
    if (grounds.get(i).posX < -AvatarXpos) {
      grounds.remove(i);
      i--;
    }
  }
} 
void addObstacle() {
  int lifespan = pop.populationLife;
  int tempInt;
  if (lifespan > 1000 && random(1) < 0.15) { 
    tempInt = floor(random(3));
    FlyObs temp = new FlyObs(tempInt);//floor(random(3)));
    FObs.add(temp);
  } else {//otherwise add a cactus
    tempInt = floor(random(3));
    Obstacle temp = new Obstacle(tempInt);//floor(random(3)));
    obstacles.add(temp);
    tempInt+=3;
  }
  obstacleHistory.add(tempInt);

  randomAddition = floor(random(50));
  randomAdditionHistory.add(randomAddition);
  obstacleTimer = 0;
}


void showObstacles() {
  for (int i = 0; i< grounds.size(); i++) {
    grounds.get(i).show();
  }
  for (int i = 0; i< obstacles.size(); i++) {
    obstacles.get(i).show();
  }

  for (int i = 0; i< FObs.size(); i++) {
    FObs.get(i).show();
  }
}

//Reset game every gen
void resetObstacles() {
  randomAdditionHistory = new ArrayList<Integer>();
  obstacleHistory = new ArrayList<Integer>();

  obstacles = new ArrayList<Obstacle>();
  FObs = new ArrayList<FlyObs>();
  obstacleTimer = 0;
  randomAddition = 0;
  groundCounter = 0;
  speed = 10;
}
