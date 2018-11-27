class Node {
  int number;
  float inputSum = 0;
  float outputValue = 0;
  ArrayList<connectionGene> outputConnections = new ArrayList<connectionGene>();
  int layer = 0;
  PVector drawPos = new PVector();
  Node(int no) {
    number = no;
  }

  void engage() {
    if (layer!=0) {//Sigmoid not generated for the inputs and bias
      outputValue = sigmoid(inputSum);
    }

    for (int i = 0; i< outputConnections.size(); i++) {//for each connection
      if (outputConnections.get(i).enabled) {//Non enabled connections shouldnt work
        outputConnections.get(i).toNode.inputSum += outputConnections.get(i).weight * outputValue;//add the weighted output to the sum of the inputs of whatever node this node is connected to
      }
    }
 }
  float stepFunction(float x) {
    if (x < 0) {
      return 0;
    } else {
      return 1;
    }
  }
  //Sigmoid function to squash values
  float sigmoid(float x) {
    float y = 1 / (1 + pow((float)Math.E, -4.9*x));
    return y;
  }

  boolean isConnectedTo(Node node) {
    if (node.layer == layer) {//nodes in the same layer cannot be connected
      return false;
    }

    //you get it
    if (node.layer < layer) {
      for (int i = 0; i < node.outputConnections.size(); i++) {
        if (node.outputConnections.get(i).toNode == this) {
          return true;
        }
      }
    } else {
      for (int i = 0; i < outputConnections.size(); i++) {
        if (outputConnections.get(i).toNode == node) {
          return true;
        }
      }
    }

    return false;
  }
   Node clone() {
    Node clone = new Node(number);
    clone.layer = layer;
    return clone;
  }
}
