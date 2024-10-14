import netP5.*;
import oscP5.*;

int cursorSize = 20;
int currentID = 0;

OscP5 oscP5;
NetAddress remoteLocation;

ArrayList<TuioCursor> CursorList;


boolean AliveState = false;
boolean SelectionMode = false;
boolean newCursor = false;
boolean noMoreCursors = false;
boolean periodicMsg = true;

float lastSend = 0;

void setup(){
  size(600, 600);
  CursorList = new ArrayList<TuioCursor>();
  
  oscP5 = new OscP5(this, 12000);
  remoteLocation = new NetAddress("127.0.0.1", 3333);
  delay(500);
  sendAliveMessage();
  sendFSEQ();
}

void draw(){
  background(0);
  
  if(CursorList.size() > 0){
    sendAliveMessage();
    for(int i=CursorList.size()-1; i>=0; i--){
      CursorList.get(i).update();
    }
    sendFSEQ();
  }
  
  if((millis() - lastSend) > 700 && periodicMsg){
    //println("AliveMsg");
    lastSend = millis();
    sendAliveMessage();
    for(int i=CursorList.size()-1; i>=0; i--){
      CursorList.get(i).sendTuio();
    }
    sendFSEQ();
  }
  
}

void mousePressed(){
 
  //println("Keep Alive");
  boolean clicked = checkClickOnCursor();
  if(!clicked){
    CursorList.add(new TuioCursor(mouseX, mouseY, currentID, AliveState));
    currentID++;
    println("Cursor");
    println(CursorList.size());
    newCursor = true;
  }
}

void mouseReleased(){
  checkReleaseOnCursor();  
}

void checkReleaseOnCursor(){
  for(int i=CursorList.size()-1; i>=0; i--){
    noMoreCursors = false;
    boolean clicked = CursorList.get(i).clicked();
    if(CursorList.get(i).clickedT == true) CursorList.get(i).clickedT = false;
    
    //if(clicked && SelectionMode == false) CursorList.get(i).selected = false;
    if(clicked && SelectionMode == true) CursorList.get(i).selected = !CursorList.get(i).selected;
    if(clicked && AliveState == true && newCursor == false) CursorList.remove(i);
  }  
  if(CursorList.size() == 0 && !noMoreCursors){   //Send Alive Msg once when all Cursors are one
    noMoreCursors = true; 
    sendAliveMessage();
    sendFSEQ();
  }
  newCursor = false;
}

boolean checkClickOnCursor(){
  
  for(int i=CursorList.size()-1; i>=0; i--){
    boolean clicked = CursorList.get(i).clicked();
    if(clicked) CursorList.get(i).clickedT = true;
    
    if(clicked) return true;
  }  
  return false;
}

void keyPressed(){
  if(key == CODED){
    if(keyCode == SHIFT){
      AliveState = true;
    }
    if(keyCode == CONTROL){
      SelectionMode = true;
    }
  }
}

void keyReleased(){
  if(key == CODED){
    if(keyCode == SHIFT){
      AliveState = false;
    }
    if(keyCode == CONTROL){
      SelectionMode = false;
    }
  }
}

void exit(){
  CursorList.clear();
  sendAliveMessage();
  sendFSEQ();
}
