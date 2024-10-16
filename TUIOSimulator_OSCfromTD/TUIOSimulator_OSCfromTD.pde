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
  
  oscP5 = new OscP5(this, 10100);  // Listens for OSC messages on port 10100 from TD
  remoteLocation = new NetAddress("127.0.0.1", 3333); // Sending OSC to TouchDesigner on port 10100
  
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
    lastSend = millis();
    sendAliveMessage();
    for(int i=CursorList.size()-1; i>=0; i--){
      CursorList.get(i).sendTuio();
    }
    sendFSEQ();
  }
}

void mousePressed(){
  // Disabling mouse press to add cursor, positions will come from TouchDesigner
}

void mouseReleased(){
  checkReleaseOnCursor();  
}

void checkReleaseOnCursor(){
  for(int i=CursorList.size()-1; i>=0; i--){
    noMoreCursors = false;
    boolean clicked = CursorList.get(i).clicked();
    if(CursorList.get(i).clickedT == true) CursorList.get(i).clickedT = false;
    
    if(clicked && SelectionMode == true) CursorList.get(i).selected = !CursorList.get(i).selected;
    if(clicked && AliveState == true && newCursor == false) CursorList.remove(i);
  }  
  if(CursorList.size() == 0 && !noMoreCursors){  
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

// OSC event handling function to receive messages from TouchDesigner
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/tuio/2Dcur") && theOscMessage.checkTypetag("ff")) {
    // Receiving x and y position from TouchDesigner
    float x = theOscMessage.get(0).floatValue() * width;  // Normalize by width
    float y = theOscMessage.get(1).floatValue() * height; // Normalize by height

    // If CursorList is empty, add a new cursor
    if(CursorList.size() == 0) {
      CursorList.add(new TuioCursor(x, y, currentID, AliveState));
      currentID++;
    } else {
      // Update existing cursor's position
      CursorList.get(0).posX = x;
      CursorList.get(0).posY = y;
    }
  }
}
