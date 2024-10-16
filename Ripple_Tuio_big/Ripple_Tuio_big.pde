
/*
  Ripple - Interactive Audiovisual Enviroment 
  
  Copyright (c) Maria Orciuoli [2023]
  // run this in parallel with simulator sketch.
  https://github.com/solar-parker/tuio-simulator

  All rights reserved.

  This code is the property of Maria Orciuoli and is protected by copyright law. 
  No part of this code may be reproduced, distributed, or transmitted in any form 
  or by any means, including photocopying, recording, or other electronic or 
  mechanical methods, without the prior written permission of the author, 
  except for brief quotations in critical reviews or academic references 
  as permitted by copyright law.

  Unauthorized use, distribution, or duplication of this code is strictly prohibited.

  For permissions, contact: maria.orciuoli@gmail.com
*/


import TUIO.*;

import ddf.minim.*; 
Minim minim;
AudioPlayer player;

// Ripples
int cols, rows;
float[][] current;
float[][] previous;
float dampening = 0.95; // 1-0 values, controls how long the ripples remain
PGraphics offscreenBuffer;
boolean isAudioStarted = false;

// Tuio settings 
TuioProcessing tuioClient;
// resolution of the Deep Space and scale factor
float SF = 0.2; // SF scale factor 
float DS_HEIGHT = 2160; // height of deep space's floor and wall 
float DS_WIDTH = 3840;

XML xml;

ArrayList<Player> playerList;

void settings(){
  
  ///LOAD Settings from XML File START
  xml = loadXML("settings.xml"); //this one calls the xml document 
  SF = xml.getFloat("scaleFactor");
  println(SF);
  
  int isFullScreen = xml.getInt("isFullScreen");
  if(isFullScreen == 0) {
  size(int(DS_WIDTH*SF), int(DS_HEIGHT*2*SF), P2D);
  }
  else{
    fullScreen(P2D, SPAN);
  }
}

void setup() {
  // Tuio settings
  tuioClient = new TuioProcessing(this);
  playerList = new ArrayList<Player>();
  
  // Graphics
  cols = 1280;
  rows = 720;
  current = new float[cols][rows];
  previous = new float[cols][rows];
  offscreenBuffer = createGraphics(cols, rows, P2D);

  // Audio
  minim = new Minim(this);
  player = minim.loadFile("raindrop.wav");  
}


void draw() {
  println(frameRate);
  
  // Tuio setting 
  for(int i=playerList.size()-1; i>=0; i--) {
    Player tPl = playerList.get(i);
    tPl.update();
    float xPos = tPl.xPos;
    float yPos = tPl.yPos;
    int mouseXIndex = int(map(xPos, 0, DS_WIDTH*SF, 0, cols-1));
    int mouseYIndex = int(map(yPos, 0, DS_HEIGHT*SF, 0, rows-1));
    previous[mouseXIndex][mouseYIndex] = 1000;
  
  }

  // If someone is on the canvas
  if (playerList.size() > 0) {

    // Start playing audio on the first mouse click
    if (!isAudioStarted) {
      player.loop();
      isAudioStarted = true;
    }
  }
  else{
    player.play(0); // stop sound if no one is on the floor
  }

  offscreenBuffer.beginDraw();
  offscreenBuffer.fill(0,0,0, 6); // apply translucent rectangle to dissipate lines
  offscreenBuffer.rect(0,0,cols, rows); // apply translucent rectangle to dissipate lines
  offscreenBuffer.loadPixels();
  int stepS = 1;
  for (int i = 1; i < cols - 1; i++) {
    for (int j = 1; j < rows - 1; j++) {
      current[i][j] =
        (previous[i - stepS][j] +
          previous[i + stepS][j] +
          previous[i][j - stepS] +
          previous[i][j + stepS]) / 2
        - current[i][j];
      current[i][j] *= dampening;

      // Blend the ripple effect with the offscreen buffer
      int index = i + j * cols;
      offscreenBuffer.pixels[index] = color(current[i][j]) + offscreenBuffer.pixels[index];
    }
  }
  offscreenBuffer.updatePixels();
  offscreenBuffer.endDraw();

  // Swap current and previous arrays
  float[][] temp = previous;
  previous = current;
  current = temp;

   //Display offscreen buffer on the canvas
  image(offscreenBuffer, 0, DS_HEIGHT*SF, DS_WIDTH*SF, DS_HEIGHT*SF);
  image(offscreenBuffer, 0, 0, DS_WIDTH*SF, DS_HEIGHT*SF);
  
  //// Flip and display offscreen buffer on the canvas 
  //scale(1, -1); // Flip the image on the x-axis
  //image(offscreenBuffer, 0, -DS_HEIGHT*SF, DS_WIDTH*SF, DS_HEIGHT*SF); // Draw the flipped image
  //scale(1, 1); // Reset the scale
  //image(offscreenBuffer, 0, 0, DS_WIDTH*SF, DS_HEIGHT*SF);
  
  //// Mirror and display offscreen buffer on the canvas
  //offscreenBuffer.scale(-1, 1); // Mirror the image on the x-axis
  //image(offscreenBuffer, -DS_WIDTH*SF, 0, DS_WIDTH*SF, DS_HEIGHT*SF); // Draw the mirrored image
  //offscreenBuffer.scale(-1, 1); // Reset the scale
  //image(offscreenBuffer, 0, 0, DS_WIDTH*SF, DS_HEIGHT*SF);
  
  
}


/* 
  Copyright (c) Maria Orciuoli [2023]

  This code is the property of [Your Name] and is protected under copyright law. 
  No part of this code may be reproduced, distributed, or transmitted in any form 
  or by any means, including photocopying, recording, or other electronic or 
  mechanical methods, without the prior written permission of the author, 
  except in the case of brief quotations embodied in critical reviews and 
  certain other noncommercial uses permitted by copyright law.

  For permission requests, contact: maria.orciuoli@gmail.com

  Unauthorized use of this code is strictly prohibited.
*/
