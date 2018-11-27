class connectionGene {
  Node fromNode;
  Node toNode;
  float weight;
  boolean enabled = true;
  int innovationNo;
  connectionGene(Node from, Node to, float w, int inno) {
    fromNode = from;
    toNode = to;
    weight = w;
    innovationNo = inno;
  }

  void mutateWeight() {
    float rand2 = random(1);
    if (rand2 < 0.1) {
      weight = random(-1, 1);
    } else {
      weight += randomGaussian()/50;
      if(weight > 1){
        weight = 1;
      }
      if(weight < -1){
        weight = -1;        
        
      }
    }
  }

  connectionGene clone(Node from, Node  to) {
    connectionGene clone = new connectionGene(from, to, weight, innovationNo);
    clone.enabled = enabled;

    return clone;
  }
}
