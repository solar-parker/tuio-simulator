

class Player{
  TuioCursor myCursor;
  float xPos;
  float yPos;
  float mySize;
  
  Player(TuioCursor tc) {
    myCursor = tc;
    mySize = 300*SF;
  }
  
  
  // this is the part where you will enter your project
  void update() {
    xPos = myCursor.getScreenX(int(DS_WIDTH)) * SF;
    yPos = myCursor.getScreenY(int(DS_HEIGHT)) * SF;
    //ellipseMode(CENTER);
    //ellipse(xPos, yPos, mySize, mySize);
    //ellipse(xPos, yPos-DS_HEIGHT*SF, mySize, mySize); //this line is if you want what you draw on the floor to appear on the wall
    
  }
 
}
