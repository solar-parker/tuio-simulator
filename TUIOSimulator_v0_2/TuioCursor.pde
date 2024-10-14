

class TuioCursor{
  int CursorID;
  float posX, posY;
  boolean selected = false;
  boolean keepAlive = false;
  boolean clickedT = true;
  
  TuioCursor(float x, float y, int id, boolean keep){
    posX = x;
    posY = y; 
    CursorID = id; 
    keepAlive = keep;
  }
  
  boolean clicked(){
    if(dist(mouseX, mouseY, posX, posY) < cursorSize/2.0){
      return true;
    }
    else{
      //selected = false;
      return false;
    }
  }
  
  void sendTuio(){
    sendCursor(CursorID, posX, posY);
  }
  
  void update(){
    
    if(selected && mousePressed || clickedT){
      posX = posX + mouseX - pmouseX;
      if(posX > width) posX = width;
      if(posX < 0) posX = 0;
      posY = posY + mouseY - pmouseY;
      if(posY > height) posY = height;
      if(posY < 0) posY = 0;
      sendTuio();
    }
    
    if(selected) fill(20,60,20);
    else fill(255);
    
    if(selected || keepAlive || clickedT){
      ellipseMode(CENTER);
      circle(posX, posY, cursorSize);
    }
    else{
      for(int i=CursorList.size()-1; i>=0; i--){
        if(CursorList.get(i).CursorID ==  CursorID){
          CursorList.remove(i);
          break;
        }
      } 
    }
  }
  
}
