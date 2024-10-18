

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
import oscP5.*; // Import the oscP5 library
import netP5.*; // Import netP5 for network communication

Minim minim;
AudioPlayer player;

int cols, rows;
float[][] current;
float[][] previous;
float dampening = 0.95; // 1-0 values, controls how long the ripples remain
PGraphics offscreenBuffer;
boolean isAudioStarted = false;

// OSC settings
OscP5 oscP5; // Create an oscP5 object
int oscPort = 10100; // Port to listen for incoming OSC messages

// Arrays to store OSC values for each human
float[] oscX = new float[10]; // Array for X values (tx)
float[] oscY = new float[10]; // Array for Y values (ty)

// TouchDesigner canvas dimensions (will be updated dynamically)
float touchDesignerWidth = 13.8; // Width of TouchDesigner canvas
float touchDesignerHeight = 7.9;  // Height of TouchDesigner canvas

void setup() {
  size(3840, 2160, P2D); // Set Processing window size to 3840x2160
  
  // Graphics
  cols = 3840; // Number of columns
  rows = 2160; // Number of rows
  current = new float[cols][rows];
  previous = new float[cols][rows];

  offscreenBuffer = createGraphics(cols, rows, P2D); // Offscreen buffer for rendering

  // Audio
  minim = new Minim(this);
  player = minim.loadFile("raindrop.wav");

  // Initialize OSC
  oscP5 = new OscP5(this, oscPort); // Start listening on the specified port

  // Initialize OSC values to zero
  for (int i = 0; i < oscX.length; i++) {
    oscX[i] = 0;
    oscY[i] = 0;
  }
}

void draw() {
  println(frameRate);

  // Loop through each human and update the ripple effect
  for (int i = 0; i < oscX.length; i++) {
    // Normalize OSC values to the Processing canvas size based on the received TouchDesigner dimensions
    float normalizedX = map(oscX[i], -touchDesignerWidth / 2, touchDesignerWidth / 2, 0, width); // Map from TouchDesigner width
    float normalizedY = map(oscY[i], -touchDesignerHeight / 2, touchDesignerHeight / 2, height, 0); // Inverted Y-axis

    // Ensure the normalized values are within bounds before simulating mouse press
    if (oscX[i] != 0 || oscY[i] != 0) {
      simulateMousePress(int(normalizedX), int(normalizedY));
    }
  }

  // Continue with the ripple effect rendering
  offscreenBuffer.beginDraw();
  offscreenBuffer.fill(0, 0, 0, 6); // Apply translucent rectangle to dissipate lines
  offscreenBuffer.rect(0, 0, cols, rows); // Apply translucent rectangle to dissipate lines
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

  // Display offscreen buffer on the canvas
  image(offscreenBuffer, 0, 0, width, height);
}

// Method to handle incoming OSC messages
void oscEvent(OscMessage msg) {
  // Check if the message contains the canvas size data
  if (msg.checkAddrPattern("/size")) {
    // Update the TouchDesigner width and height based on the incoming message
    touchDesignerWidth = msg.get(0).floatValue();
    touchDesignerHeight = msg.get(1).floatValue();
    println("Updated canvas size: " + touchDesignerWidth + " x " + touchDesignerHeight);
  }

  // Check for each human's OSC addresses
  for (int i = 0; i < 10; i++) {
    String txAddress = "/human" + i + ":tx"; // Construct the tx address
    String tyAddress = "/human" + i + ":ty"; // Construct the ty address

    if (msg.checkAddrPattern(txAddress)) {
      oscX[i] = msg.get(0).floatValue(); // Get the value for *tx*
    } else if (msg.checkAddrPattern(tyAddress)) {
      oscY[i] = msg.get(0).floatValue(); // Get the value for *ty*
    }
  }
}

// Simulate mouse press at a specific position
void simulateMousePress(int x, int y) {
  // Normalize indices to ensure they stay within bounds
  int mouseXIndex = int(map(x, 0, width - 1, 0, cols));
  int mouseYIndex = int(map(y, 0, height - 1, 0, rows));

  // Ensure the indices are within bounds before accessing the array
  if (mouseXIndex >= 0 && mouseXIndex < cols && mouseYIndex >= 0 && mouseYIndex < rows) {
    previous[mouseXIndex][mouseYIndex] = 1000; // Create a ripple effect at the position

    // Start playing audio if not already started
    if (!isAudioStarted) {
      player.loop(); // Start audio loop
      isAudioStarted = true; // Set the flag to indicate audio has started
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
