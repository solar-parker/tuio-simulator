

/*
  Ripple - Interactive Audiovisual Enviroment 
  
  Copyright (c) Maria Orciuoli [2023]

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

import ddf.minim.*;
import oscP5.*;
import netP5.*;

Minim minim;
AudioPlayer player;

int cols, rows;
float[][] current;
float[][] previous;
float dampening = 0.95;
PGraphics offscreenBuffer;
boolean isAudioStarted = false;

OscP5 oscP5;
int oscPort = 10100;

float[] oscX = new float[10];
float[] oscY = new float[10];

float touchDesignerWidth = 13.8;
float touchDesignerHeight = 7.9;

void setup() {
  size(1, 1, P2D);  // Create a very small display window
  surface.setVisible(false);  // Hide the window
  
  // Set resolution to 3840 × 2160 (4K)
  cols = 3840;
  rows = 2160;
  current = new float[cols][rows];
  previous = new float[cols][rows];

  // Create offscreen buffer with the updated resolution
  offscreenBuffer = createGraphics(cols, rows, P2D); 
  
  minim = new Minim(this);
  
  // Load the audio file
  player = minim.loadFile("raindrop.wav");
  
  // Check if the audio file was loaded correctly
  if (player == null) {
    println("Audio file could not be loaded!");
  } else {
    println("Audio file loaded successfully.");
  }

  oscP5 = new OscP5(this, oscPort);

  for (int i = 0; i < oscX.length; i++) {
    oscX[i] = 0;
    oscY[i] = 0;
  }

  println("Program is running in the background...");
}

void draw() {
  for (int i = 0; i < oscX.length; i++) {
    float normalizedX = map(oscX[i], -touchDesignerWidth / 2, touchDesignerWidth / 2, 0, cols);
    float normalizedY = map(oscY[i], -touchDesignerHeight / 2, touchDesignerHeight / 2, rows, 0);

    if (oscX[i] != 0 || oscY[i] != 0) {
      simulateMousePress(int(normalizedX), int(normalizedY));
    }
  }

  offscreenBuffer.beginDraw();
  offscreenBuffer.fill(0, 0, 0, 6);
  offscreenBuffer.rect(0, 0, cols, rows);
  offscreenBuffer.loadPixels();

  for (int i = 1; i < cols - 1; i++) {
    for (int j = 1; j < rows - 1; j++) {
      current[i][j] = (previous[i - 1][j] + previous[i + 1][j] + previous[i][j - 1] + previous[i][j + 1]) / 2 - current[i][j];
      current[i][j] *= dampening;

      int index = i + j * cols;
      offscreenBuffer.pixels[index] = color(current[i][j]) + offscreenBuffer.pixels[index];
    }
  }

  offscreenBuffer.updatePixels();
  offscreenBuffer.endDraw();

  float[][] temp = previous;
  previous = current;
  current = temp;
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/size")) {
    touchDesignerWidth = msg.get(0).floatValue();
    touchDesignerHeight = msg.get(1).floatValue();
    println("Updated canvas size: " + touchDesignerWidth + " x " + touchDesignerHeight);
  }

  for (int i = 0; i < 10; i++) {
    String txAddress = "/human" + i + ":tx";
    String tyAddress = "/human" + i + ":ty";

    if (msg.checkAddrPattern(txAddress)) {
      oscX[i] = msg.get(0).floatValue();
    } else if (msg.checkAddrPattern(tyAddress)) {
      oscY[i] = msg.get(0).floatValue();
    }
  }
}

void simulateMousePress(int x, int y) {
  int mouseXIndex = int(map(x, 0, cols - 1, 0, cols));
  int mouseYIndex = int(map(y, 0, rows - 1, 0, rows));

  if (mouseXIndex >= 0 && mouseXIndex < cols && mouseYIndex >= 0 && mouseYIndex < rows) {
    previous[mouseXIndex][mouseYIndex] = 1000;

    if (!isAudioStarted) {
      // Check if the audio is ready to play and loop it
      if (player != null) {
        player.loop();
        isAudioStarted = true;
        println("Audio started.");
      } else {
        println("Audio file not loaded, cannot start.");
      }
    }
  }
}






/* 
  Copyright (c) Maria Orciuoli [2023]

  This code is the property of Maria Orciuoli and is protected under copyright law. 
  No part of this code may be reproduced, distributed, or transmitted in any form 
  or by any means, including photocopying, recording, or other electronic or 
  mechanical methods, without the prior written permission of the author, 
  except in the case of brief quotations embodied in critical reviews and 
  certain other noncommercial uses permitted by copyright law.

  For permission requests, contact: maria.orciuoli@gmail.com

  Unauthorized use of this code is strictly prohibited.
*/
