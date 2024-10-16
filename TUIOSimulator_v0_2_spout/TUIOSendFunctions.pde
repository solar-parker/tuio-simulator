

void sendAliveMessage(){
  OscMessage aliveMsg = new OscMessage("/tuio/2Dcur");
  aliveMsg.add("alive");
  for(int i=CursorList.size()-1; i>=0; i--){
    aliveMsg.add(CursorList.get(i).CursorID);  
  }
  oscP5.send(aliveMsg, remoteLocation);
}

void sendCursor(int id, float posX, float posY){
  posX = posX/width;
  posY = posY/height;
  OscMessage setMsg = new OscMessage("/tuio/2Dcur");
  setMsg.add("set");
  setMsg.add(id);
  setMsg.add(posX);
  setMsg.add(posY);
  setMsg.add(0.0);
  setMsg.add(0.0);
  setMsg.add(0.0);
  
  oscP5.send(setMsg, remoteLocation);
}


void sendFSEQ(){
  OscMessage fseqMsg = new OscMessage("/tuio/2Dcur");
  fseqMsg.add("fseq");
  fseqMsg.add(-1);
  oscP5.send(fseqMsg, remoteLocation);
  
}
