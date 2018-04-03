/* --------------------------------------------------------------------------
 * Dancing Under The Box
 * --------------------------------------------------------------------------
 * Processing solution for videomapping triggered by Kinect hotspots
 * http://www.huerfanas.studio/work/dancing-under-the-box
 * --------------------------------------------------------------------------
 * prog:  Gonzalo Moyano / Interaction Design 
 * date:  04/03/2018 (mm/dd/yy)
 * ----------------------------------------------------------------------------
 * This code allows: 
 * - mapping each face of each box for projecting videoart
 * - create Kinect hotspots (x / y / z)  that trigger the videoprojection when 
 * the performer is dancing under the box
 * ----------------------------------------------------------------------------
 */

import processing.video.*;
import deadpixel.keystone.*;

import org.openkinect.freenect.*;
import org.openkinect.processing.*;


/* ########################################### CONFIG VARIABLES ###### */

int nVideos = 2; // amount of videos/boxes
boolean hotSpotMode = true; // true = HotSPOT mode // toggle it by pressing 'H'



/* ########################################### GENERAL DECLARATIONS ###### */

Kinect kinect;
KinectLib kinectLib;

ArrayList<Movie> myMovies = new ArrayList<Movie>();
Keystone ks;
int i; 
int nSurfaces = nVideos * 3; // 3 faces by box 

String[] coords = new String[3]; // X, Y, Z
String[] boxLocations = new String[nVideos];
float[] faders = new float[nVideos]; // alpha of the black fill that hide each video
PVector[] boxesXYZ = new PVector[nVideos];

CornerPinSurface[] surfaces = new CornerPinSurface[nSurfaces]; // mapping stuff
PGraphics[] offscreens  = new PGraphics[nSurfaces]; // mapping stuff




/* ##################################################### SETUP ######### */

void setup() {

  //fullScreen(P3D);
  size(1000, 700, P3D);
  for (i=0; i<nVideos; i++) {

    Movie movie = new Movie(this, "video"+(i+1)+".mov"); 
    movie.loop();
    myMovies.add(movie);
    faders[i] = 100;
  }

  ks = new Keystone(this);

  for (i=0; i<nSurfaces; i++) {
    surfaces[i] = ks.createCornerPinSurface(200, 200, 5);
    offscreens[i] = createGraphics(200, 200, P2D);
  }




  kinect = new Kinect(this);
  kinect.initDepth();
 
  kinectLib = new KinectLib();

  boxLocations = loadStrings("boxLocations.txt"); 

  updateboxesXYZ();
}




/* ##################################################### DRAW ######### */

void draw() {
  
  background(0);
  noStroke();
  cursor();

  if (hotSpotMode) {
    kinectLib.display();
    kinectLib.calibrateDepth();
    noCursor();
  }

  int v = -1;

  if (!hotSpotMode) {
    
    for (i=0; i<nSurfaces; i++) {
  
      if (i%3==0) { 
        v++;
        for (int n = 0; n < nVideos; n++)
          faders[n] = map(kinectLib.hotSpot(boxesXYZ[n].x, boxesXYZ[n].y, boxesXYZ[n].z),0,100,255,0);
      }

      offscreens[i].beginDraw();
      offscreens[i].fill(0, 0, 0, faders[v]);
      offscreens[i].image(myMovies.get(v), 0, 0, offscreens[i].width, offscreens[i].height);
      offscreens[i].rect(0, 0, offscreens[i].width, offscreens[i].height);
      
      if (hotSpotMode) {
        offscreens[i].fill(255);
        offscreens[i].noStroke();
        offscreens[i].rect(0, 0, offscreens[i].width, offscreens[i].height);
        offscreens[i].fill(0);
        offscreens[i].textSize(offscreens[i].width/2); 
        offscreens[i].text((v+1), offscreens[i].width/2, offscreens[i].height/2);
      }
  
      offscreens[i].endDraw();
    }
  
    for (i=0; i<nSurfaces; i++) {
      surfaces[i].render(offscreens[i]);
    }
  
  }

  if (hotSpotMode) {

    for (i=0; i<nVideos; i++) {

      noFill();
      stroke(255,100,0);
      
      rect(boxesXYZ[i].x- kinectLib.spotSize/2, boxesXYZ[i].y - kinectLib.spotSize/2, kinectLib.spotSize, kinectLib.spotSize);
      
      fill(255,100,0);
      noStroke();
      rect(boxesXYZ[i].x - kinectLib.spotSize/2, boxesXYZ[i].y - kinectLib.spotSize/2 - 20, kinectLib.spotSize - kinectLib.spotSize/5, 20);
      fill(255);
      text("BOX #" + (i+1), boxesXYZ[i].x - kinectLib.spotSize/2 + 10, boxesXYZ[i].y - kinectLib.spotSize/2 - 5);
      text("Z: " +  (int)boxesXYZ[i].z, boxesXYZ[i].x - kinectLib.spotSize/2 + 10, boxesXYZ[i].y - kinectLib.spotSize/2 +20);
      text("Match: " +  (int)kinectLib.hotSpot(boxesXYZ[i].x, boxesXYZ[i].y, boxesXYZ[i].z) + " %", boxesXYZ[i].x - kinectLib.spotSize/2 + 10, boxesXYZ[i].y - kinectLib.spotSize/2 + 40);
 
    }
    
    fill(255,255,255,50);
    noStroke();
    rect(mouseX + kinectLib.spotSize/2 + 3, mouseY - kinectLib.spotSize/2, 100, 100);
    fill(255);
    stroke(100);
    text("Location //" , mouseX + 20 + kinectLib.spotSize/2, mouseY + 20 - kinectLib.spotSize/2);
    text("X: "+mouseX , mouseX + 20 + kinectLib.spotSize/2, mouseY + 40 - kinectLib.spotSize/2);
    text("Y: "+mouseY , mouseX + 20 + kinectLib.spotSize/2, mouseY + 60 - kinectLib.spotSize/2);
    text("Z: "+(int)kinectLib.threshold , mouseX + 20 + kinectLib.spotSize/2, mouseY + 80 - kinectLib.spotSize/2);
    
    
    stroke(255);
    line(mouseX, mouseY - kinectLib.spotSize/3, mouseX, mouseY + kinectLib.spotSize/3);
    line(mouseX - kinectLib.spotSize/3, mouseY, mouseX + kinectLib.spotSize/3, mouseY);
    noFill();
    rect(mouseX - kinectLib.spotSize/2, mouseY - kinectLib.spotSize/2, kinectLib.spotSize, kinectLib.spotSize);
  }

}

void movieEvent(Movie m) {
  m.read();
}

void keyPressed() {

  switch(key) {

  case 'c': 
    ks.toggleCalibration(); 
    break;

  case 'l': 
    ks.load(); 
    break;

  case 's': 
    ks.save(); 
    break;

  case 'h': 
    hotSpotMode = !hotSpotMode; 
    break;
  }

  int val = digitToNum(key);
  if (hotSpotMode && val >= 1 &&  val <= nVideos) saveBoxLocation(val);
}


void saveBoxLocation(int i) {
  
  float calibrateX = 0;
  float calibrateY = 0;
  float calibrateZ = 0;

  calibrateX = mouseX;
  calibrateY = mouseY;
  calibrateZ = kinectLib.threshold;

  boxLocations[(i-1)] = calibrateX + "," + calibrateY + "," + calibrateZ;
  println("Set box " + i + ": " + boxLocations[(i-1)]);
  updateboxesXYZ();
  saveStrings("boxLocations.txt", boxLocations);
}

void updateboxesXYZ() {
  for (i=0; i<nVideos; i++) {
    coords = split(boxLocations[i], ',');
    boxesXYZ[i] = new PVector(Float.parseFloat(coords[0]), Float.parseFloat(coords[1]), Float.parseFloat(coords[2]));
  }
}

static final int digitToNum(char ch) {
  int num = ch - '0';
  return num >= 0 & num <= 9? num : -1;
}