class pixelSorter
{
  PImage           src;
  pixelData[]      data;
  sortingFunctions func;
  
  pixelSorter(PImage img)
  {
    this.src  = createImage(img.width, img.height, RGB);
    this.data = new pixelData[img.pixels.length];
    this.func = new sortingFunctions();
    
    for (int i=0; i<img.pixels.length; i++) {
      this.src.pixels[i] = img.pixels[i];
      this.data[i] = new pixelData(i, i % img.width, i / img.width, img.pixels[i]);
    }
    
    print("Source image loaded: (" + img.width + " x " + img.height + ")\n");
  }
  
  void setSearchFunction(int key, int func, int val)
  {
    this.func.searchOperation = func;
    this.func.searchKey = key;
    this.func.searchValue = val;
  }
  
  void setCompareFunction(int key, int func)
  {
    this.func.compareOperation = func;
    this.func.compareKey = key;
  }
  
  void setCompareModifier(int modifier)
  {
    this.func.compareModifier = modifier;  
  }
  
  void setSortFunction(int key, int func)
  {
    this.func.sortOrder = func;
    this.func.sortKey = key;
  }
  
  void ignoreSorted(boolean ignore)
  {
    this.func.ignoreSortedPixels = ignore;
  }
  
  void disableMask()
  {
    this.func.useMask = false;  
  }
  
  void enableMask()
  {
    if (this.func.mask.length == this.src.pixels.length)
      this.func.useMask = true;  
  }
  
  void resetSortedFlags()
  {
    for (int i=0; i<this.data.length; i++)
      data[i].flagAsSorted = false;
  }
  
  void setMaskImage(PImage img)
  {
    if (img.width != this.src.width || img.height != this.src.height)
      print("Error: Mask dimensions must equal source image dimensions. (Src: " + this.src.width + " x " + this.src.height + ") (Mask: " + img.width + " x " + img.height + ")\n");
    else
    {
      this.func.useMask = true;
      this.func.mask = new float[img.pixels.length];
      
      for (int i=0; i<img.pixels.length; i++) {
        int val = img.pixels[i];
        this.func.mask[i] = (((val >> 16) & 0xff) + ((val >> 8) & 0xff) + (val & 0xff)) / 3.0 / 255.0;
      }
      
      print("Mask image loaded: (" + img.width + " x " + img.height + ")\n");
    }
  }
  
  void setMaskFunction(int func, double scale)
  {
    if (func == MASK_SEGMENT_LENGTH)
    {
      this.func.maskSegmentLength = MASK_SEGMENT_LENGTH;
      this.func.maskLengthScale = (float)scale;
    }
    else if (func == MASK_SEGMENT_ANGLE)
    {
      this.func.maskSegmentAngle = MASK_SEGMENT_ANGLE;
      this.func.maskAngleScale = (float)scale;
    }
  }
  
  void sortDirection(int segmentMaxLength, double angle, double curvature)
  {
    print("Sorting directionally ANGLE " + (int)(angle / PI * 180) + "°, MAX LENGTH " + segmentMaxLength + ", CURVE " + (int)(curvature / PI * 180) + "°, MASK " + ((this.func.useMask) ? "ON" : "OFF") + "...");
    
    int start = 0;
    int stop  = data.length;
    int iter  = +1;
    
    // reverse iteration for upward vectors
    if (angle > 0 && angle <= PI) {
      start = data.length - 1;
      stop  = -1;
      iter  = -1;
    }
    
    for (int i=start; i!=stop; i+=iter)
      if (this.func.testInitialPixel(data[i]))
      {
        this.func.sortPixelArray(
           this.src,
           this.func.getPixelArray(this.data, this.data[i].index, this.data[i].x, this.data[i].y, this.src.width, this.src.height, segmentMaxLength, (float)angle, (float)curvature)
        );
      }
    
    this.copySortedPixelsToImage();
    this.resetSortedFlags();
    
    print(" DONE\n");
  }
  
  void sortRadial(int segmentMaxLength, int x, int y, double curvature)
  {
    print("Sorting radially CENTRE (" + x + ", " + y + "), CURVE " + (int)(curvature / PI * 180) + "°, MASK " + ((this.func.useMask) ? "ON" : "OFF") + "...");
    
    int start, stop, iter;
    
    // above y, iterate from top-left
    if (y >= 0)
    {
      start = 0;
      stop  = (y >= this.src.height) ? data.length : (y + 1) * this.src.width;
      iter  = 1;
      this.radialSegment(segmentMaxLength, x, y, curvature, start, stop, iter);
    }
    
    // below y, iterate from bottom-right
    if (y < this.src.height)
    {
      start = data.length - 1;
      stop  = (y < 0) ? -1 : (y + 1) * this.src.width;
      iter  = -1;
      this.radialSegment(segmentMaxLength, x, y, curvature, start, stop, iter);
    }
    
    this.copySortedPixelsToImage();
    this.resetSortedFlags();
    
    print(" DONE\n");
  }
  
  void radialSegment(int segmentMaxLength, int x, int y, double curvature, int start, int stop, int iter)
  {
      for (int i=start; i!=stop; i+=iter)
        if (this.func.testInitialPixel(data[i]))
        {
          float angle = atan2(y - this.data[i].y, this.data[i].x - x);
          
          this.func.sortPixelArray(
             this.src,
             this.func.getPixelArray(this.data, this.data[i].index, this.data[i].x, this.data[i].y, this.src.width, this.src.height, segmentMaxLength, angle, (float)curvature)
          );
        }
  }
  
  void sortRing(int segmentMaxLength, int x, int y, boolean clockwise)
  {
    print("Sorting " + ((clockwise) ? "clockwise" : "anti-clockwise") + " ring CENTRE (" + x + ", " + y + "), MASK " + ((this.func.useMask) ? "ON" : "OFF") + "...");
    
    for (int i=0; i<data.length; i++)
      if (this.func.testInitialPixel(data[i]))
      {
        float angle = atan2(y - this.data[i].y, this.data[i].x - x) + ((clockwise) ? -PI * 0.5 : PI * 0.5);
        float Q = sqrt(pow(y - this.data[i].y, 2) + pow(this.data[i].x - x, 2));
        float curvature = (Q == 0.0) ? 0 : 1 / Q;
        
        this.func.sortPixelArray(
           this.src,
           this.func.getPixelArray(this.data, this.data[i].index, this.data[i].x, this.data[i].y, this.src.width, this.src.height, segmentMaxLength, angle, curvature)
        );
      }
    
    this.copySortedPixelsToImage();
    this.resetSortedFlags();
    
    print(" DONE\n");
  }
  
  void copySortedPixelsToImage()
  {
      for (int i=0; i<this.data.length; i++)
        this.src.pixels[i] = this.data[i].colour;
  }
  
  PImage getSortedImage()
  {
    print("Sorting complete.\n");
    return this.src;
  }
}