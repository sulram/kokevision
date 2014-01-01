// - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
// - BlobDetection library

import processing.video.*;
import blobDetection.*;
import controlP5.*;
import megamu.mesh.*;

Capture cam;
BlobDetection theBlobDetection;
ControlP5 controlP5;
CheckBox checkbox;

PImage img;
boolean newFrame=false;
boolean flip_x = true;
boolean video = true;
boolean edges = true;
boolean blobs = true;
boolean meshes = false;
boolean submeshes = false;
boolean attractors = false;
int skip_blobs = 1;

// ==================================================
// setup()
// ==================================================
void setup()
{
  // Size of applet
  size(640, 480);
  // Capture
  cam = new Capture(this, 40*4, 30*4, 15);
  // Comment the following line if you use Processing 1.5
  cam.start();

  controlP5 = new ControlP5(this);

  controlP5.addSlider("luminosity", 0.0, 1.0, 0.5, 20, 20, 100, 10);
  controlP5.addSlider("skip_blobs", 1, 20, skip_blobs, 20, 40, 100, 10);

  checkbox = controlP5.addCheckBox("checkbox", 20, 60);
  checkbox.addItem("flip_x", flip_x?1:0);
  checkbox.addItem("video", video?1:0);
  checkbox.addItem("blobs", blobs?1:0);
  checkbox.addItem("edges", edges?1:0);
  checkbox.addItem("meshes", meshes?1:0);
  checkbox.addItem("submeshes", submeshes?1:0);
  checkbox.addItem("attractors", attractors?1:0);

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
      video = (int)theEvent.group().arrayValue()[1] == 1;
      blobs = (int)theEvent.group().arrayValue()[2] == 1;
      edges = (int)theEvent.group().arrayValue()[3] == 1;
      meshes = (int)theEvent.group().arrayValue()[4] == 1;
      submeshes = (int)theEvent.group().arrayValue()[5] == 1;
      attractors = (int)theEvent.group().arrayValue()[6] == 1;
    }
  }
}


// ==================================================
// captureEvent()
// ==================================================
void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
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
  if (flip_x) {
    pushMatrix();
    translate(width, 0);
    scale(-1, 1);
  }
  if (newFrame)
  {
    newFrame=false;
    if (video) {
      image(cam, 0, 0, width, height);
    } 
    else {
      background(0);
    }
    img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height);

    fastblur(img, 2);
    theBlobDetection.computeBlobs(img.pixels);
    drawShapes(blobs, edges, meshes, submeshes, attractors);
  }
  if (flip_x) {
    popMatrix();
  }
}

