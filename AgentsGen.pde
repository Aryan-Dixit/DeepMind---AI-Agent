class AgentsGen {
  ArrayList<Avatar> Avatars = new ArrayList<Avatar>();
  float bestFitness = 0;
  Avatar champ;
  float averageFitness = 0;
  int staleness = 0;//Non improving AgentsGen
  NeuralNetwork rep;

  float excessCoeff = 1;
  float weightDiffCoeff = 0.5;
  float compatibilityThreshold = 3;


  AgentsGen() {
  }


  AgentsGen(Avatar p) {
    Avatars.add(p); 
    bestFitness = p.fitness; 
    rep = p.brain.clone();
    champ = p.cloneForReplay();
  }

 
  boolean sameAgentsGen(NeuralNetwork g) {
    float compatibility;
    float excessAndDisjoint = getExcessDisjoint(g, rep);
    float averageWeightDiff = averageWeightDiff(g, rep);


    float largeGenomeNormaliser = g.genes.size() - 20;
    if (largeGenomeNormaliser<1) {
      largeGenomeNormaliser =1;
    }

    compatibility =  (excessCoeff* excessAndDisjoint/largeGenomeNormaliser) + (weightDiffCoeff* averageWeightDiff);//compatablilty formula
    return (compatibilityThreshold > compatibility);
  }

  void addToAgentsGen(Avatar p) {
    Avatars.add(p);
  }


  float getExcessDisjoint(NeuralNetwork brain1, NeuralNetwork brain2) {
    float matching = 0.0;
    for (int i =0; i <brain1.genes.size(); i++) {
      for (int j = 0; j < brain2.genes.size(); j++) {
        if (brain1.genes.get(i).innovationNo == brain2.genes.get(j).innovationNo) {
          matching ++;
          break;
        }
      }
    }
    return (brain1.genes.size() + brain2.genes.size() - 2*(matching));
  }
 
  
  float averageWeightDiff(NeuralNetwork brain1, NeuralNetwork brain2) {
    if (brain1.genes.size() == 0 || brain2.genes.size() ==0) {
      return 0;
    }


    float matching = 0;
    float totalDiff= 0;
    for (int i =0; i <brain1.genes.size(); i++) {
      for (int j = 0; j < brain2.genes.size(); j++) {
        if (brain1.genes.get(i).innovationNo == brain2.genes.get(j).innovationNo) {
          matching ++;
          totalDiff += abs(brain1.genes.get(i).weight - brain2.genes.get(j).weight);
          break;
        }
      }
    }
    if (matching ==0) {//divide by 0 error
      return 100;
    }
    return totalDiff/matching;
  }
  
  
  //sorts the AgentsGen by fitness 
  void sortAgentsGen() {

    ArrayList<Avatar> temp = new ArrayList<Avatar>();

    //selection short 
    for (int i = 0; i < Avatars.size(); i ++) {
      float max = 0;
      int maxIndex = 0;
      for (int j = 0; j< Avatars.size(); j++) {
        if (Avatars.get(j).fitness > max) {
          max = Avatars.get(j).fitness;
          maxIndex = j;
        }
      }
      temp.add(Avatars.get(maxIndex));
      Avatars.remove(maxIndex);
      i--;
    }

    Avatars = (ArrayList)temp.clone();
    if (Avatars.size() == 0) {
      print("fucking"); 
      staleness = 200;
      return;
    }
    //if new best Avatar
    if (Avatars.get(0).fitness > bestFitness) {
      staleness = 0;
      bestFitness = Avatars.get(0).fitness;
      rep = Avatars.get(0).brain.clone();
      champ = Avatars.get(0).cloneForReplay();
    } else {//if no new best Avatar
      staleness ++;
    }
  }

  
  void setAverage() {

    float sum = 0;
    for (int i = 0; i < Avatars.size(); i ++) {
      sum += Avatars.get(i).fitness;
    }
    averageFitness = sum/Avatars.size();
  }
  
  
  //gets baby from the Avatars in this AgentsGen
  Avatar giveBaby(ArrayList<connectionHistory> innovationHistory) {
    Avatar baby;
    if (random(1) < 0.25) {//0.25 of sample has no gene random crossover
      baby =  selectAvatar().clone();
    } else {

      Avatar parent1 = selectAvatar();
      Avatar parent2 = selectAvatar();

      if (parent1.fitness < parent2.fitness) {
        baby =  parent2.crossover(parent1);
      } else {
        baby =  parent1.crossover(parent2);
      }
    }
    baby.brain.mutate(innovationHistory);//mutate that baby brain
    return baby;
  }

  Avatar selectAvatar() {
    float fitnessSum = 0;
    for (int i =0; i<Avatars.size(); i++) {
      fitnessSum += Avatars.get(i).fitness;
    }

    float rand = random(fitnessSum);
    float runningSum = 0;

    for (int i = 0; i<Avatars.size(); i++) {
      runningSum += Avatars.get(i).fitness; 
      if (runningSum > rand) {
        return Avatars.get(i);
      }
    }
    return Avatars.get(0);
  }
  
  
  void cull() {
    if (Avatars.size() > 2) {
      for (int i = Avatars.size()/2; i<Avatars.size(); i++) {
        Avatars.remove(i); 
        i--;
      }
    }
  }
 
  
  void fitnessSharing() {
    for (int i = 0; i< Avatars.size(); i++) {
      Avatars.get(i).fitness/=Avatars.size();
    }
  }
}
