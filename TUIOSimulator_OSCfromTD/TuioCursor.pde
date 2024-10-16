
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
    if(dist(mouseX, mouseY, posX, posY) < cursorSize / 2.0){
      return true;
    } else {
      return false;
    }
  }
  
  void sendTuio(){
    sendCursor(CursorID, posX, posY);
  }
  
  void update(){
    // Cursor is updated from TouchDesigner via oscEvent, no need to handle manually
    if(selected) fill(20,60,20);
    else fill(255);
    
    if(selected || keepAlive || clickedT){
      ellipseMode(CENTER);
      circle(posX, posY, cursorSize);
    }
    else{
      for(int i=CursorList.size()-1; i>=0; i--){
        if(CursorList.get(i).CursorID == CursorID){
          CursorList.remove(i);
          break;
        }
      }
    }
  }
}
