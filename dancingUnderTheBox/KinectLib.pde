class KinectLib {

  
  float threshold = 810;
  float bandWidth = 5;
  float stepDepthCalib = 0.5f;
  int spotSize = 100;

  int[] depth;
  PImage display;
  
  
   
  KinectLib() {
 
    kinect.initDepth();
    kinect.enableMirror(true);
    display = createImage(kinect.width, kinect.height, RGB);
     
  }
  
  float hotSpot(float pX, float pY, float pZ) {
    
    float matchAverage;
    depth = kinect.getRawDepth();
    
    pX = map(pX, 0, width, 0, kinect.width);
    pY = map(pY, 0, height, 0, kinect.height);
    float mappedSpotSize = map(spotSize, 0, width, 0, kinect.width);
 
    if (depth == null) return 0;

   
    int count = 0;

    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {
        
        int offset =  (kinect.width - x -1) + y * kinect.width;
      
        int rawDepth = depth[offset];

      
        if (x > (pX - mappedSpotSize/2) && x < (pX + mappedSpotSize/2) && 
            y > (pY - mappedSpotSize/2) && y < (pY + mappedSpotSize/2) && 
            rawDepth  >= pZ - bandWidth && rawDepth  <= pZ + bandWidth
            ) {
         
          count++;
        }
      }
    }
   
    matchAverage = map(count, 0, (mappedSpotSize * mappedSpotSize)* 0.75, 0, 100); 
    if(matchAverage > 100) matchAverage = 100;
    return matchAverage;
 
  }
  
  
  
  void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    
    display.loadPixels();
    
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = (kinect.width - x -1) + y * kinect.width;
        
        // Raw depth
        int rawDepth = depth[offset];
        
        int pix = x + y * display.width;
        
        if (rawDepth  >= threshold-bandWidth && rawDepth  <= threshold + bandWidth) {
 
          display.pixels[pix] = color(180, 80, 10);
        } else {
          display.pixels[pix] = color(20,25,30, 0); // =  img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Draw the image
    image(display, 0, 0, width, height);
  }
  
  
  

  
  void calibrateDepth(){
   if(keyPressed){
      
      if (keyCode == UP) {
          threshold +=  stepDepthCalib;
          println(threshold);
    
      } else if (keyCode == DOWN) {
          threshold -=  stepDepthCalib;
          println(threshold);
    
      } else if (keyCode == LEFT) {
          if(bandWidth > 0) bandWidth -=  stepDepthCalib;
          println(bandWidth);
    
      } else if (keyCode == RIGHT) {
          bandWidth +=  stepDepthCalib;
          println(bandWidth);
      } 
   }
  
}




}