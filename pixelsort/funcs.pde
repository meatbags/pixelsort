import java.util.Arrays;
import java.util.Comparator;

final int GREATER_THAN        = 0x01;
final int LESS_THAN           = 0x02;
final int SORT_KEY_BRIGHTNESS = 0x03;
final int SORT_KEY_RED        = 0x04;
final int SORT_KEY_GREEN      = 0x05;
final int SORT_KEY_BLUE       = 0x06;
final int SORT_KEY_CYAN       = 0x07;
final int SORT_KEY_MAGENTA    = 0x08;
final int SORT_KEY_YELLOW     = 0x09;
final int SORT_KEY_HUE        = 0x0a;
final int ORDER_ASCENDING     = 0x0b;
final int ORDER_DESCENDING    = 0x0c;
final int ORDER_PEAK          = 0x0d;
final int ORDER_TROUGH        = 0x0e;
final int MASK_SEGMENT_LENGTH = 0x0f;
final int MASK_SEGMENT_ANGLE  = 0x10;
final int MASK_DISABLE        = 0x11;

class sortingFunctions
{
  pixelData[] data;
  float[]     mask;
	
  int searchKey              = SORT_KEY_BRIGHTNESS;
  int searchOperation        = GREATER_THAN;
  int searchValue            = -1;
  int compareKey             = SORT_KEY_BRIGHTNESS;
  int compareOperation       = GREATER_THAN;
  int compareModifier        = 0;
  int sortKey                = SORT_KEY_BRIGHTNESS;
  int sortOrder              = ORDER_ASCENDING;
  boolean useMask            = false;
  int maskSegmentLength      = MASK_DISABLE;
  int maskSegmentAngle       = MASK_DISABLE;
  float maskLengthScale      = 1;
  float maskAngleScale       = 1;
  boolean ignoreSortedPixels = true;
  
  sortingFunctions(){}
  
  int[][] getValueArray(pixelData[] p, int key)
  {
    int[][] array = new int[p.length][2];
    
    if (key == SORT_KEY_BRIGHTNESS)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].brightness;
          array[i][1] = p[i].index;
      }
    else if (key == SORT_KEY_RED)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].red;
          array[i][1] = p[i].index;
      }
    else if (key == SORT_KEY_GREEN)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].green;
          array[i][1] = p[i].index;
      }
    else if (key == SORT_KEY_BLUE)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].blue;
          array[i][1] = p[i].index;
      }
    else if (key == SORT_KEY_CYAN)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].cyan;
          array[i][1] = p[i].index;
      }
    else if (key == SORT_KEY_MAGENTA)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].magenta;
          array[i][1] = p[i].index;
      }
    else if (key == SORT_KEY_YELLOW)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].yellow;
          array[i][1] = p[i].index;
      }
    else if (key == SORT_KEY_HUE)
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].hue;
          array[i][1] = p[i].index;
      }
    else
      for (int i=0; i<p.length; i+=1) {
          array[i][0] = p[i].brightness;
          array[i][1] = p[i].index;
      }
      
    return array;
  }
  
  int getPixelValue(pixelData p, int key)
  {
    if (key == SORT_KEY_BRIGHTNESS)
      return p.brightness;
    if (key == SORT_KEY_RED)
      return p.red;
    if (key == SORT_KEY_GREEN)
      return p.green;
    if (key == SORT_KEY_BLUE)
      return p.blue;
    if (key == SORT_KEY_CYAN)
      return p.cyan;
    if (key == SORT_KEY_MAGENTA)
      return p.magenta;
    if (key == SORT_KEY_YELLOW)
      return p.yellow;
    if (key == SORT_KEY_HUE)
      return p.hue;
    
    return p.brightness;
  }
  
  pixelData[] getPixelArray(
    pixelData[] data,
    int index,
    int x,
    int y,
    int width,
    int height,
    int segmentMaxLength,
    float angle,
    float curvature
  ){
    // apply mask
    if (this.useMask) {
      segmentMaxLength += (this.maskSegmentLength == MASK_SEGMENT_LENGTH) ? (int)(mask[index] * this.maskLengthScale) : 0;
      angle += (this.maskSegmentAngle == MASK_SEGMENT_ANGLE) ? mask[index] * this.maskAngleScale : 0;
    }
    
    // create empty data array
    pixelData[] array = new pixelData[segmentMaxLength];
    array[0] = data[index];
    
    boolean complete = false;
    int iteration    = 1;
    int currentIndex = index;
    
    // trace from "centre" of pixel
    float currentX   = x + 0.5;
    float currentY   = y + 0.5;
    float stepX      = cos(angle);
    float stepY      = -sin(angle);
    
    // populate array
    while (!complete && iteration < segmentMaxLength)
    {
        while(floor(currentX) == x && floor(currentY) == y)
        {
          currentX += stepX;
          currentY += stepY;
          
          if (curvature != 0) {
            angle += curvature;
            stepX  = cos(angle);
            stepY  = -sin(angle);
          }
        }
        
        // resolve coordinates
        x = floor(currentX);
        y = floor(currentY);
        currentIndex = y * width + x;
        
        // check end conditions
        if ((x > -1 && y > -1 && x < width && y < height) &&
          !this.comparePixels(data[index], data[currentIndex]))
        {
          array[iteration] = data[currentIndex];
          iteration += 1;
        } else {
          complete = true;  
        }
    }
    
    // trim empty array data
    if (iteration < segmentMaxLength)
    {
      pixelData[] trimmed = new pixelData[iteration];
      
      for (int i=0; i<trimmed.length; i++)
        trimmed[i] = array[i];
        
      return trimmed;
    }
    return array;
  }
  
  boolean comparePixels(pixelData a, pixelData b)
  { 
    int valA = this.getPixelValue(a, this.compareKey),
        valB = this.getPixelValue(b, this.compareKey);
        
    return ( 
      (this.compareOperation == GREATER_THAN && valB > valA + this.compareModifier) ||
      (this.compareOperation == LESS_THAN && valB < valA + this.compareModifier)
    );
  }
  
  boolean testInitialPixel(pixelData p)
  {
    if (this.ignoreSortedPixels && p.flagAsSorted) {
      return false;
    }
    
    int val = this.getPixelValue(p, this.searchKey);
    
    if ((this.searchOperation == GREATER_THAN && val > this.searchValue) ||
      (this.searchOperation == LESS_THAN && val < this.searchValue)) {
      return true;
    } else {
      return false;
    }
  }
  
  void sortPixelArray(PImage src, pixelData[] array)
  {
    // [sort key, index]
    int[][] sort = this.getValueArray(array, this.sortKey);
    
    Arrays.sort(sort, new Comparator<int[]>() {
      @Override
      public int compare(final int[] A, final int[] B) {
        return Integer.compare(A[0], B[0]);
      }
    });
    
    // re-arrange
    if (this.sortOrder == ORDER_DESCENDING)
    {
      int[][] desc = new int[sort.length][2];
      
      for (int i=0; i<sort.length; i++) {
        desc[desc.length - 1 - i] = sort[i];
      }
      
      sort = desc;
    }
    else if (this.sortOrder == ORDER_PEAK)
    {
      int[][] peak = new int[sort.length][2];
      
      for (int i=0; i<peak.length; i++) {
        if (i % 2 == 0)
          peak[i / 2] = sort[i];
        else
          peak[peak.length - 1 - i / 2] = sort[i];
      }
      
      sort = peak;
    }
    else if (this.sortOrder == ORDER_TROUGH)
    {
      int[][] trough = new int[sort.length][2];
      
      int splitA = (sort.length % 2 == 0) ? sort.length / 2 - 1 : sort.length / 2;
      int splitB = splitA + 1;
      
      for (int i=0; i<trough.length; i++)
        if (i % 2 == 0)
          trough[splitA - i/2] = sort[i];
        else
          trough[splitB + i/2] = sort[i];
          
      sort = trough;
    }
    
    // transfer colour values
    for (int i=0; i<sort.length; i++)
    {
      //print("val: " + sort[i][0] + " " + sort[i][1] + " \n");
      
      array[i].colour = src.pixels[sort[i][1]];
      array[i].flagAsSorted = true;
    }
  }
}
