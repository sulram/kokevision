// - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
// - BlobDetection library

import SimpleOpenNI.*;
import blobDetection.*;
import controlP5.*;
import megamu.mesh.*;
import codeanticode.syphon.*;

SyphonServer server;
SimpleOpenNI  context;
BlobDetection theBlobDetection;
ControlP5 controlP5;
CheckBox checkbox;

PImage img;
boolean newFrame=false;
boolean flip_x = false;
boolean flip_y = false;
boolean video = true;
boolean edges = true;
boolean blobs = false;
boolean meshes = true;
boolean submeshes = true;
boolean attractors = false;

float depth_min = 0, depth_max = 256.0;
int skip_blobs = 5;

// ==================================================
// setup()
// ==================================================
void setup()
{
  // Size of applet
  size(640, 480, P2D);
  // Capture
  context = new SimpleOpenNI(this);

if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }

  controlP5 = new ControlP5(this);

  controlP5.addSlider("luminosity", 0.0, 1.0, 0.5, 20, 20, 100, 10);
  controlP5.addSlider("skip_blobs", 1, 20, skip_blobs, 20, 40, 100, 10);
  controlP5.addSlider("depth_min", 0.0, 256.0, depth_min, 20, 60, 100, 10);
  controlP5.addSlider("depth_max", 0.0, 256.0, depth_max, 20, 80, 100, 10);
  
  checkbox = controlP5.addCheckBox("checkbox", 20, 100);
  checkbox.addItem("flip_x", flip_x?1:0);
  checkbox.addItem("flip_y", flip_y?1:0);
  checkbox.addItem("video", video?1:0);
  checkbox.addItem("blobs", blobs?1:0);
  checkbox.addItem("edges", edges?1:0);
  checkbox.addItem("meshes", meshes?1:0);
  checkbox.addItem("submeshes", submeshes?1:0);
  checkbox.addItem("attractors", attractors?1:0);
  
  server = new SyphonServer(this, "Processing Syphon");
  
  // BlobDetection
  // img which will be sent to detection (a smaller copy of the cam frame);
  img = new PImage(80, 60); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(0.5f); // will detect bright areas whose luminosity > 0.2f;
}

void luminosity(float val) {
  theBlobDetection.setThreshold(val);
}

void controlEvent(ControlEvent theEvent) {

  if (theEvent.isGroup()) {
    String groupname = theEvent.group().name();
    if (groupname.equals("checkbox") == true) {
      flip_x = (int)theEvent.group().arrayValue()[0] == 1;
      flip_y = (int)theEvent.group().arrayValue()[1] == 1;
      video = (int)theEvent.group().arrayValue()[2] == 1;
      blobs = (int)theEvent.group().arrayValue()[3] == 1;
      edges = (int)theEvent.group().arrayValue()[4] == 1;
      meshes = (int)theEvent.group().arrayValue()[5] == 1;
      submeshes = (int)theEvent.group().arrayValue()[6] == 1;
      attractors = (int)theEvent.group().arrayValue()[7] == 1;
    }
  }
}

void mousePressed()
{
  if (mouseButton == RIGHT) {
    if (controlP5.isVisible()) {
      controlP5.hide();
    } 
    else {
      controlP5.show();
    }
  }
}

// ==================================================
// draw()
// ==================================================
void draw()
{
  context.update();
  
  
  if (flip_x) {
    pushMatrix();
    translate(width, 0);
    scale(-1, 1);
  }
  
  if (flip_y) {
    pushMatrix();
    translate(0, height);
    scale(1, -1);
  }
  
  //img = context.depthImage().get();
  //image(context.depthImage(),0,0);
 
    if (video) {
    image(context.depthImage(),0,0);

    } 
    else {
      background(0);
    }
    //img.copy(context.depthImage(), 0, 0, context.depthImage().width, context.depthImage().height, 0, 0, img.width, img.height);
    
    int w = img.width;
    int h = img.height;
    float dw = context.depthImage().width / w;
    float dh = context.depthImage().height / h;
    float depw = context.depthImage().width;
    float rcp_delta = 1.0f/(depth_max-depth_min); 
    int t = w * h;
    float min_depth = Float.POSITIVE_INFINITY;
    float max_depth = Float.NEGATIVE_INFINITY;
    for(int y = 0; y < h; y++) {
      for(int x = 0; x < w; x++) {
        float p = - (context.depthImage().pixels[(int)(x*dw + (y*dh*depw))] / (256.0 * 256.0));
        min_depth = min(min_depth, p);
        max_depth = max(max_depth, p);
        float c = (p - depth_min)*rcp_delta*255.0;
        img.pixels[x+y*w] = color(c, c, c);
      }
    }
    
    //println("min: " + min_depth + " max: " + max_depth);
    fastblur(img, 2);
    theBlobDetection.computeBlobs(img.pixels);
    drawShapes(blobs, edges, meshes, submeshes, attractors);
    //image(img, 0, 0);
  
  if (flip_y) {
    popMatrix();
  }
  
  
  if (flip_x) {
    popMatrix();
  }
  server.sendScreen();
}

