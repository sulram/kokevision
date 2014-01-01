// ==================================================
// drawBlobsAndEdges()
// ==================================================
void drawShapes(boolean drawBlobs, boolean drawEdges, boolean drawMeshes, boolean drawSubmeshes, boolean drawAttractors)
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0 ; n<theBlobDetection.getBlobNb() ; n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges

      strokeWeight(3);
      stroke(0, 255, 0);

      int k = 0;
      int max = 5000;

      float[][] mypoints = new float[max][2];


      for (int m=0;m<b.getEdgeNb();m+=skip_blobs)
      {
        eA = b.getEdgeVertexA(m);
        eB = b.getEdgeVertexB(m);
        if (eA !=null && eB !=null) {
          if (drawEdges)
          {
            //line(eA.x*width, eA.y*height,eB.x*width, eB.y*height);
            ellipse(eA.x*width, eA.y*height, 10, 10);
            //ellipse(eB.x*width, eB.y*height, 10,10);
          }
          if (k<max) {
            mypoints[k][0] = eA.x*width;
            mypoints[k][1] = eA.y*height;
            k++;
          }
        }
      }

      // 1st delaunay pass – triangulate and subdivide

      Delaunay myDelaunay = new Delaunay( mypoints );
      float[][] myEdges = myDelaunay.getEdges();

      for (int i=0; i<myEdges.length; i++)
      {
        int min_dist = 40;

        float startX = myEdges[i][0];
        float startY = myEdges[i][1];
        float endX = myEdges[i][2];
        float endY = myEdges[i][3];
        
        float dist_x = startX - endX;
        float dist_y = startY - endY;
        
        boolean inside = startX>0 && startY>0 && endX>0 && endY>0;
        
        if(!drawSubmeshes && drawMeshes && inside){
          line( startX, startY, endX, endY );
        }
        
        if (k<max && drawSubmeshes && inside && abs(dist_x) > min_dist && abs(dist_y) > min_dist) {
          mypoints[k][0] = (startX+endX)*.5;
          mypoints[k][1] = (startY+endY)*.5;
          if (drawAttractors){
            float dist = sqrt(dist_x*dist_x+dist_y*dist_y)*.5;
            ellipse(mypoints[k][0], mypoints[k][1], dist, dist);
          }
          k++;
        }
        
      }
      
      // 2nd delaunay pass - subdivide again
      
      strokeWeight(1);
      
      myDelaunay = new Delaunay( mypoints );
      myEdges = myDelaunay.getEdges();

      for (int i=0; i<myEdges.length; i++)
      {
        float startX = myEdges[i][0];
        float startY = myEdges[i][1];
        float endX = myEdges[i][2];
        float endY = myEdges[i][3];
        
        float dist_x = startX - endX;
        float dist_y = startY - endY;
        
        int min_dist = 20;
        
        boolean inside = startX>0 && startY>0 && endX>0 && endY>0;
        
        if (drawMeshes && drawSubmeshes && inside) {
          line( startX, startY, endX, endY );
        }
        
        if (k<max && drawSubmeshes && drawAttractors && inside && abs(dist_x) > min_dist && abs(dist_y) > min_dist) {
          mypoints[k][0] = (startX+endX)*.5;
          mypoints[k][1] = (startY+endY)*.5;
          if (drawAttractors){
            float dist = sqrt(dist_x*dist_x+dist_y*dist_y)*.5;
            ellipse(mypoints[k][0], mypoints[k][1], dist, dist);
          }
          k++;
        }
        
      }

      
      // Blobs
      if (drawBlobs)
      {
        strokeWeight(3);
        stroke(255, 0, 0);
        rect(
        b.xMin*width, b.yMin*height, 
        b.w*width, b.h*height
          );
      }
    }
  }
}

