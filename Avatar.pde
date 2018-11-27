class Avatar {
  float fitness;
  NeuralNetwork brain;
  boolean replay = false;

  float unadjustedFitness;
  int lifespan = 0;
  int bestScore =0;
  boolean dead;
  int score;
  int gen = 0;

  int genomeInputs = 7;
  int genomeOutputs = 3;

  float[] vision = new float[genomeInputs]; 
  float[] decision = new float[genomeOutputs];  
  //-------------------------------------
  float posY = 0;
  float velY = 0;
  float gravity =1.2;
  int runCount = -5;
  int size = 20;

  ArrayList<Obstacle> replayObstacles = new ArrayList<Obstacle>();
  ArrayList<FlyObs> replayFObs = new ArrayList<FlyObs>();
  ArrayList<Integer> localObstacleHistory = new ArrayList<Integer>();
  ArrayList<Integer> localRandomAdditionHistory = new ArrayList<Integer>();
  int historyCounter = 0;
  int localObstacleTimer = 0;
  float localSpeed = 10;
  int localRandomAddition = 0;

  boolean duck= false;
  

  Avatar() {
    brain = new NeuralNetwork(genomeInputs, genomeOutputs);
  }

  
  void show() {
    if (duck && posY == 0) {
      if (runCount < 0) {

        image(fig4, AvatarXpos - fig4.width/2, height - groundHeight - (posY + fig4.height));
      } else {

        image(fig5, AvatarXpos - fig5.width/2, height - groundHeight - (posY + fig5.height));
      }
    } else
      if (posY ==0) {
        if (runCount < 0) {
          image(fig2, AvatarXpos - fig2.width/2, height - groundHeight - (posY + fig2.height));
        } else {
          image(fig3, AvatarXpos - fig3.width/2, height - groundHeight - (posY + fig3.height));
        }
      } else {
        image(fig1, AvatarXpos - fig1.width/2, height - groundHeight - (posY + fig1.height));
      }
    runCount++;
    if (runCount > 5) {
      runCount = -5;
    }
  }
  
  
  
  void incrementCounters() {
    lifespan++;
    if (lifespan % 3 ==0) {
      score+=1;
    }
  }


  void move() {
    posY += velY;
    if (posY >0) {
      velY -= gravity;
    } else {
      velY = 0;
      posY = 0;
    }

    if (!replay) {

      for (int i = 0; i< obstacles.size(); i++) {
        if (obstacles.get(i).collided(AvatarXpos, posY +fig2.height/2, fig2.width*0.5, fig2.height)) {
          dead = true;
        }
      }

      for (int i = 0; i< FObs.size(); i++) {
        if (duck && posY ==0) {
          if (FObs.get(i).collided(AvatarXpos, posY + fig4.height/2, fig4.width*0.8, fig4.height)) {
            dead = true;
          }
        } else {
          if (FObs.get(i).collided(AvatarXpos, posY +fig2.height/2, fig2.width*0.5, fig2.height)) {
            dead = true;
          }
        }
      }
    } else {//if replayign then move local obstacles
      for (int i = 0; i< replayObstacles.size(); i++) {
        if (replayObstacles.get(i).collided(AvatarXpos, posY +fig2.height/2, fig2.width*0.5, fig2.height)) {
          dead = true;
        }
      }


      for (int i = 0; i< replayFObs.size(); i++) {
        if (duck && posY ==0) {
          if (replayFObs.get(i).collided(AvatarXpos, posY + fig4.height/2, fig4.width*0.8, fig4.height)) {
            dead = true;
          }
        } else {
          if (replayFObs.get(i).collided(AvatarXpos, posY +fig2.height/2, fig2.width*0.5, fig2.height)) {
            dead = true;
          }
        }
      }
    }
  }


    void jump(boolean bigJump) {
    if (posY ==0) {
      if (bigJump) {
        gravity = 1;
        velY = 20;
      } else {
        gravity = 1.2;
        velY = 16;
      }
    }
  }

  void ducking(boolean isDucking) {
    if (posY != 0 && isDucking) {
      gravity = 3;
    }
    duck = isDucking;
  }

  void update() {
    incrementCounters();
    move();
  }
  
  
  void look() {
    if (!replay) {
      float min = 10000;
      int minIndex = -1;
      boolean berd = false; 
      for (int i = 0; i< obstacles.size(); i++) {
        if (obstacles.get(i).posX + obstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  obstacles.get(i).posX + obstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
          min = obstacles.get(i).posX + obstacles.get(i).w/2 - (AvatarXpos - fig2.width/2);
          minIndex = i;
        }
      }

      for (int i = 0; i< FObs.size(); i++) {
        if (FObs.get(i).posX + FObs.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  FObs.get(i).posX + FObs.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
          min = FObs.get(i).posX + FObs.get(i).w/2 - (AvatarXpos - fig2.width/2);
          minIndex = i;
          berd = true;
        }
      }
      vision[4] = speed;
      vision[5] = posY;


      if (minIndex == -1) {
        vision[0] = 0; 
        vision[1] = 0;
        vision[2] = 0;
        vision[3] = 0;
        vision[6] = 0;
      } else {

        vision[0] = 1.0/(min/10.0);
        if (berd) {
          vision[1] = FObs.get(minIndex).h;
          vision[2] = FObs.get(minIndex).w;
          if (FObs.get(minIndex).typeOfFOb == 0) {
            vision[3] = 0;
          } else {
            vision[3] = FObs.get(minIndex).posY;
          }
        } else {
          vision[1] = obstacles.get(minIndex).h;
          vision[2] = obstacles.get(minIndex).w;
          vision[3] = 0;
        }




        int bestIndex = minIndex;
        float closestDist = min;
        min = 10000;
        minIndex = -1;
        for (int i = 0; i< obstacles.size(); i++) {
          if ((berd || i != bestIndex) && obstacles.get(i).posX + obstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  obstacles.get(i).posX + obstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
            min = obstacles.get(i).posX + obstacles.get(i).w/2 - (AvatarXpos - fig2.width/2);
            minIndex = i;
          }
        }

        for (int i = 0; i< FObs.size(); i++) {
          if ((!berd || i != bestIndex) && FObs.get(i).posX + FObs.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  FObs.get(i).posX + FObs.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
            min = FObs.get(i).posX + FObs.get(i).w/2 - (AvatarXpos - fig2.width/2);
            minIndex = i;
          }
        }

        if (minIndex == -1) {
          vision[6] = 0;
        } else {
          vision[6] = 1/(min - closestDist);
        }
      }
    } else {
      float min = 10000;
      int minIndex = -1;
      boolean berd = false; 
      for (int i = 0; i< replayObstacles.size(); i++) {
        if (replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
          min = replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (AvatarXpos - fig2.width/2);
          minIndex = i;
        }
      }

      for (int i = 0; i< replayFObs.size(); i++) {
        if (replayFObs.get(i).posX + replayFObs.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  replayFObs.get(i).posX + replayFObs.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
          min = replayFObs.get(i).posX + replayFObs.get(i).w/2 - (AvatarXpos - fig2.width/2);
          minIndex = i;
          berd = true;
        }
      }
      vision[4] = localSpeed;
      vision[5] = posY;


      if (minIndex == -1) {
        vision[0] = 0; 
        vision[1] = 0;
        vision[2] = 0;
        vision[3] = 0;
        vision[6] = 0;
      } else {

        vision[0] = 1.0/(min/10.0);
        if (berd) {
          vision[1] = replayFObs.get(minIndex).h;
          vision[2] = replayFObs.get(minIndex).w;
          if (replayFObs.get(minIndex).typeOfFOb == 0) {
            vision[3] = 0;
          } else {
            vision[3] = replayFObs.get(minIndex).posY;
          }
        } else {
          vision[1] = replayObstacles.get(minIndex).h;
          vision[2] = replayObstacles.get(minIndex).w;
          vision[3] = 0;
        }




        //Distance between obstacles
        int bestIndex = minIndex;
        float closestDist = min;
        min = 10000;
        minIndex = -1;
        for (int i = 0; i< replayObstacles.size(); i++) {
          if ((berd || i != bestIndex) && replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
            min = replayObstacles.get(i).posX + replayObstacles.get(i).w/2 - (AvatarXpos - fig2.width/2);
            minIndex = i;
          }
        }

        for (int i = 0; i< replayFObs.size(); i++) {
          if ((!berd || i != bestIndex) && replayFObs.get(i).posX + replayFObs.get(i).w/2 - (AvatarXpos - fig2.width/2) < min &&  replayFObs.get(i).posX + replayFObs.get(i).w/2 - (AvatarXpos - fig2.width/2) > 0) {//if the distance between the left of the Avatar and the right of the obstacle is the least
            min = replayFObs.get(i).posX + replayFObs.get(i).w/2 - (AvatarXpos - fig2.width/2);
            minIndex = i;
          }
        }

        if (minIndex == -1) {//if there is only one obejct on the screen
          vision[6] = 0;
        } else {
          vision[6] = 1/(min - closestDist);
        }
      }
    }
  }






  void think() {

    float max = 0;
    int maxIndex = 0;
    //get the output of the neural network
    decision = brain.feedForward(vision);

    for (int i = 0; i < decision.length; i++) {
      if (decision[i] > max) {
        max = decision[i];
        maxIndex = i;
      }
    }

    if (max < 0.7) {
      ducking(false);
      return;
    }

    switch(maxIndex) {
    case 0:
      jump(false);
      break;
    case 1:
      jump(true);
      break;
    case 2:
      ducking(true);
      break;
    }
  }

//Generate cloned Avatar

  Avatar clone() {
    Avatar clone = new Avatar();
    clone.brain = brain.clone();
    clone.fitness = fitness;
    clone.brain.generateNetwork(); 
    clone.gen = gen;
    clone.bestScore = score;
    return clone;
  }


  Avatar cloneForReplay() {
    Avatar clone = new Avatar();
    clone.brain = brain.clone();
    clone.fitness = fitness;
    clone.brain.generateNetwork();
    clone.gen = gen;
    clone.bestScore = score;
    clone.replay = true;
    if (replay) {
      clone.localObstacleHistory = (ArrayList)localObstacleHistory.clone();
      clone.localRandomAdditionHistory = (ArrayList)localRandomAdditionHistory.clone();
    } else {
      clone.localObstacleHistory = (ArrayList)obstacleHistory.clone();
      clone.localRandomAdditionHistory = (ArrayList)randomAdditionHistory.clone();
    }

    return clone;
  }

  
  void calculateFitness() {
    fitness = score*score;
  }

  Avatar crossover(Avatar parent2) {
    Avatar child = new Avatar();
    child.brain = brain.crossover(parent2.brain);
    child.brain.generateNetwork();
    return child;
  }

  void updateLocalObstacles() {
    localObstacleTimer ++;
    localSpeed += 0.002;
    if (localObstacleTimer > minimumTimeBetweenObstacles + localRandomAddition) {
      addLocalObstacle();
    }
    groundCounter ++;
    if (groundCounter > 10) {
      groundCounter =0;
      grounds.add(new Floor());
    }

    moveLocalObstacles();
    showLocalObstacles();
  }

  void moveLocalObstacles() {
    for (int i = 0; i< replayObstacles.size(); i++) {
      replayObstacles.get(i).move(localSpeed);
      if (replayObstacles.get(i).posX < -100) {
        replayObstacles.remove(i);
        i--;
      }
    }

    for (int i = 0; i< replayFObs.size(); i++) {
      replayFObs.get(i).move(localSpeed);
      if (replayFObs.get(i).posX < -100) {
        replayFObs.remove(i);
        i--;
      }
    }
    for (int i = 0; i < grounds.size(); i++) {
      grounds.get(i).move(localSpeed);
      if (grounds.get(i).posX < -100) {
        grounds.remove(i);
        i--;
      }
    }
  }


  void addLocalObstacle() {
    int tempInt = localObstacleHistory.get(historyCounter);
    localRandomAddition = localRandomAdditionHistory.get(historyCounter);
    historyCounter ++;
    if (tempInt < 3) {
      replayFObs.add(new FlyObs(tempInt));
    } else {
      replayObstacles.add(new Obstacle(tempInt -3));
    }
    localObstacleTimer = 0;
  }
  
  
  void showLocalObstacles() {
    for (int i = 0; i< grounds.size(); i++) {
      grounds.get(i).show();
    }
    for (int i = 0; i< replayObstacles.size(); i++) {
      replayObstacles.get(i).show();
    }

    for (int i = 0; i< replayFObs.size(); i++) {
      replayFObs.get(i).show();
    }
  }
}
