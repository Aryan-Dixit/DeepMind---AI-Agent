class Populate{
  ArrayList<Avatar> pop = new ArrayList<Avatar>();
  Avatar bestAvatar;
  int bestScore =0;
  int gen;
  ArrayList<connectionHistory> innovationHistory = new ArrayList<connectionHistory>();
  ArrayList<Avatar> genAvatars = new ArrayList<Avatar>();
  ArrayList<AgentsGen> AgentsGen = new ArrayList<AgentsGen>();

  boolean massExtinctionEvent = false;
  boolean newStage = false;
  int populationLife = 0;



  Populate(int size) {

    for (int i =0; i<size; i++) {
      pop.add(new Avatar());
      pop.get(i).brain.generateNetwork();
      pop.get(i).brain.mutate(innovationHistory);
    }
  }
  void updateAlive() {
    populationLife ++;
    for (int i = 0; i< pop.size(); i++) {
      if (!pop.get(i).dead) {
        pop.get(i).look();
        pop.get(i).think();
        pop.get(i).update();
        if (!showNothing) {
          pop.get(i).show();
        }
      }
    }
  }

  boolean done() {
    for (int i = 0; i< pop.size(); i++) {
      if (!pop.get(i).dead) {
        return false;
      }
    }
    return true;
  }
 
  void setBestAvatar() {
    Avatar tempBest =  AgentsGen.get(0).Avatars.get(0);
    tempBest.gen = gen;



    if (tempBest.score > bestScore) {
      genAvatars.add(tempBest.cloneForReplay());
      println("old best:", bestScore);
      println("new best:", tempBest.score);
      bestScore = tempBest.score;
      bestAvatar = tempBest.cloneForReplay();
    }
  }
  
  
  
  void naturalSelection() {
    speciate();
    calculateFitness();
    sortAgentsGen();
    if (massExtinctionEvent) { 
      massExtinction();
      massExtinctionEvent = false;
    }
    killAgentsGen();
    setBestAvatar();
    killStaleAgentsGen();
    killBadAgentsGen();

    println("generation", gen, "Number of mutations", innovationHistory.size(), "AgentsGen: " + AgentsGen.size(), "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");


    float averageSum = getAvgFitnessSum();
    ArrayList<Avatar> children = new ArrayList<Avatar>();
    println("AgentsGen:");               
    for (int j = 0; j < AgentsGen.size(); j++) {

      println("best unadjusted fitness:", AgentsGen.get(j).bestFitness);
      for (int i = 0; i < AgentsGen.get(j).Avatars.size(); i++) {
        print("Avatar " + i, "fitness: " +  AgentsGen.get(j).Avatars.get(i).fitness, "score " + AgentsGen.get(j).Avatars.get(i).score, ' ');
      }
      println();
      children.add(AgentsGen.get(j).champ.clone());

      int NoOfChildren = floor(AgentsGen.get(j).averageFitness/averageSum * pop.size()) -1;
      for (int i = 0; i< NoOfChildren; i++) {
        children.add(AgentsGen.get(j).giveBaby(innovationHistory));
      }
    }

    while (children.size() < pop.size()) {
      children.add(AgentsGen.get(0).giveBaby(innovationHistory));
    }
    pop.clear();
    pop = (ArrayList)children.clone();
    gen+=1;
    for (int i = 0; i< pop.size(); i++) {
      pop.get(i).brain.generateNetwork();
    }
    
    populationLife = 0;
  }

  void speciate() {
    for (AgentsGen s : AgentsGen) {
      s.Avatars.clear();
    }
    for (int i = 0; i< pop.size(); i++) {
      boolean AgentsGenFound = false;
      for (AgentsGen s : AgentsGen) {
        if (s.sameAgentsGen(pop.get(i).brain)) {
          s.addToAgentsGen(pop.get(i));
          AgentsGenFound = true;
          break;
        }
      }
      if (!AgentsGenFound) {//if no AgentsGen was similar enough then create new
        AgentsGen.add(new AgentsGen(pop.get(i)));
      }
    }
  }
  
  
  
  //Ftness of agents
  void calculateFitness() {
    for (int i =1; i<pop.size(); i++) {
      pop.get(i).calculateFitness();
    }
  }
 
  
  //sorts Avatars wihin AgentsGen
  void sortAgentsGen() {
    for (AgentsGen s : AgentsGen) {
      s.sortAgentsGen();
    }

    //Sort AgentsGen
    ArrayList<AgentsGen> temp = new ArrayList<AgentsGen>();
    for (int i = 0; i < AgentsGen.size(); i ++) {
      float max = 0;
      int maxIndex = 0;
      for (int j = 0; j< AgentsGen.size(); j++) {
        if (AgentsGen.get(j).bestFitness > max) {
          max = AgentsGen.get(j).bestFitness;
          maxIndex = j;
        }
      }
      temp.add(AgentsGen.get(maxIndex));
      AgentsGen.remove(maxIndex);
      i--;
    }
    AgentsGen = (ArrayList)temp.clone();
  }


  void killStaleAgentsGen() {
    for (int i = 2; i< AgentsGen.size(); i++) {
      if (AgentsGen.get(i).staleness >= 15) {
        AgentsGen.remove(i);
        i--;
      }
    }
  }
  
  
  //Kill AgentsGen with bad performance
  void killBadAgentsGen() {
    float averageSum = getAvgFitnessSum();

    for (int i = 1; i< AgentsGen.size(); i++) {
      if (AgentsGen.get(i).averageFitness/averageSum * pop.size() < 1) {
        AgentsGen.remove(i);
        i--;
      }
    }
  }
  //Avg fitness of AgentsGen
  float getAvgFitnessSum() {
    float averageSum = 0;
    for (AgentsGen s : AgentsGen) {
      averageSum += s.averageFitness;
    }
    return averageSum;
  }

 //Kill bottom half
  void killAgentsGen() {
    for (AgentsGen s : AgentsGen) {
      s.cull(); 
      s.fitnessSharing();
      s.setAverage();
    }
  }


  void massExtinction() {
    for (int i =5; i< AgentsGen.size(); i++) {
      AgentsGen.remove(i);//sad
      i--;
    }
  }
}
