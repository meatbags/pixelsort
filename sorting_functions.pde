import java.util.Arrays;
import java.util.Comparator;

final int GREATER_THAN = 1;
final int LESS_THAN = 2;
final int KEY_BRIGHTNESS = 3;
final int KEY_HUE = 4;
final int KEY_GREEN = 5;
final int KEY_BLUE = 6;
final int KEY_RED = 7;
final int KEY_CYAN = 8;
final int KEY_MAGENTA = 9;
final int KEY_YELLOW = 10;
final int ORDER_ASCEND = 11;
final int ORDER_DESCEND = 12;
final int ORDER_PEAK = 16;
final int ORDER_TROUGH = 17;
final int MASK_VEC_LENGTH = 13;
final int MASK_VEC_ANGLE = 14;
final int MASK_DISABLE = 15;

public class pixelSorter
{
    PImage image;
    pixelData[] data;
    sortingFunctions func;
    
    pixelSorter(PImage image) {
        // convert and store image data
        
        this.image = createImage(image.width, image.height, RGB);
        this.data = new pixelData[image.pixels.length];
        this.func = new sortingFunctions();
        
        for (int i=0; i<image.pixels.length; i++) {
            this.data[i] = new pixelData(i, i % image.width, i / image.width, image.pixels[i]);
            this.image.pixels[i] = image.pixels[i];
        }
    }
    
    // Setup functions
    
    void setSearchOptions(int key, int func, int val) {
        // segment start point
        
        this.func.searchOperation = func;
        this.func.searchKey = key;
        this.func.searchValue = val;
    }
    
    void setCompareOptions(int key, int func, int modifier) {
        // include pixels in segment
        
        this.func.compareOperation = func;
        this.func.compareKey = key;
        this.func.compareModifier = modifier;
    }
    
    void setSortOptions(int key, int func) {
        // sort segment
        
        this.func.sortOrder = func;
        this.func.sortKey = key;
    }
    
    void ignoreSortedPixels(boolean ignore) {
        // ignore previously sorted pixels
        
        this.func.ignoreSortedPixels = ignore;   
    }
    
    void useMask(PImage image) {
        // set a mask
        
        if (image.width != this.image.width || image.height != this.image.height) {
             print("Mask dimensions must equal source image dimensions");
        } else {
             this.func.useMask = true;
             this.func.mask = new float[image.pixels.length];
              
             // get mask brightness values
             
             for (int i=0; i<image.pixels.length; i++) {
                 int val = image.pixels[i];
                 this.func.mask[i] = (((val >> 16) & 0xff) + ((val >> 8) & 0xff) + (val & 0xff)) / 3.0 / 255.0;
             }
        }
    }
    
    void setMaskOptions(int func, double scale) {
        if (func == MASK_VEC_LENGTH) {
            this.func.maskVectorLength = MASK_VEC_LENGTH;
            this.func.maskLengthScale = (float)scale;
        }
        else if (func == MASK_VEC_ANGLE) {
            this.func.maskVectorAngle = MASK_VEC_ANGLE;
            this.func.maskAngleScale = (float)scale;
        }
    }
    
    void disableMask() {
         this.func.useMask = false;   
    }
    
    void enableMask() {
         this.func.useMask = (this.func.mask.length == this.image.pixels.length);
    }
    
    // Sorting functions
    
    void sortDirectional(int maxLength, double angle, double curve) {
        boolean up = (angle > 0 && angle <= PI);
        int start = (up) ? this.data.length - 1 : 0;
        int stop = (up) ? -1 : this.data.length;
        int step = (up) ? -1 : 1;
        
        for (int i=start; i!=stop; i+=step)
            if (this.func.testInitialPixel(data[i]))
                this.func.sortPixelArray(
                    this.image,
                    this.func.getPixelArray(
                        this.data, this.data[i].index, this.data[i].x, this.data[i].y, this.image.width, this.image.height, maxLength, (float)angle, (float)curve)
                    );
                    
        this.copyDataToImage();
        this.resetSortedFlags();
    }
    
    void sortRadial(int maxLength, int x, int y, double curve)
    {
        int start, stop, iter;

        // above y iterate from top-left
        if (y >= 0)
        {
            start = 0;
            stop  = (y >= this.image.height) ? data.length : (y + 1) * this.image.width;
            iter  = 1;
            this.radialSegment(maxLength, x, y, curve, start, stop, iter);
        }

        // below y, iterate from bottom-right
        if (y < this.image.height)
        {
            start = data.length - 1;
            stop  = (y < 0) ? -1 : (y + 1) * this.image.width;
            iter  = -1;
            this.radialSegment(maxLength, x, y, curve, start, stop, iter);
        }

        this.copyDataToImage();
        this.resetSortedFlags();
    }
    
    void radialSegment(int maxLength, int x, int y, double curve, int start, int stop, int iter) {
        for (int i=start; i!=stop; i+=iter)
            if (this.func.testInitialPixel(data[i])) {
                float angle = atan2(y - this.data[i].y, this.data[i].x - x);
                this.func.sortPixelArray(
                    this.image,
                    this.func.getPixelArray(this.data, this.data[i].index, this.data[i].x, this.data[i].y, this.image.width, this.image.height, maxLength, angle, (float)curve)
                );
            }
    }
  
    void sortRing(int maxLength, int x, int y, boolean clockwise)
    {    
        for (int i=0; i<data.length; i++)
            if (this.func.testInitialPixel(data[i])) {
                float angle = atan2(y - this.data[i].y, this.data[i].x - x) + ((clockwise) ? -PI * 0.5 : PI * 0.5);
                float Q = sqrt(pow(y - this.data[i].y, 2) + pow(this.data[i].x - x, 2));
                float curve = (Q == 0.0) ? 0 : 1 / Q;
                
                this.func.sortPixelArray(
                    this.image,
                    this.func.getPixelArray(this.data, this.data[i].index, this.data[i].x, this.data[i].y, this.image.width, this.image.height, maxLength, angle, curve)
                );
            }
    
        this.copyDataToImage();
        this.resetSortedFlags();
    }
  
    
    void copyDataToImage() {
        for (int i=0; i<this.data.length; i++)
            this.image.pixels[i] = this.data[i].c;
    }
    
    void resetSortedFlags()
    {
        for (int i=0; i<this.data.length; i++)
          data[i].sorted = false;
    }
    
    PImage getImage() {
        return this.image;    
    }
}

class pixelData
{
    int index, x, y;
    color c;
    float r, g, b;
    int red, green, blue, cyan, magenta, yellow, brightness, hue;
    boolean sorted;
    
    pixelData(int index, int x, int y, int c) {
        this.index = index;
        this.x = x;
        this.y = y;
        this.c = c;
        this.r = ((c >> 16) & 0xff) / 255.0;
        this.g = ((c >> 8) & 0xff) / 255.0;
        this.b = (c & 0xff) / 255.0;
        this.brightness = (int)(((this.r + this.g + this.b) / 3.0) * 255);
        this.red = (int)((this.r - (this.g + this.b) / 2.0) * 127) + 128;
        this.green = (int)((this.g - (this.r + this.b) / 2.0) * 127) + 128;
        this.blue = (int)((this.b - (this.r + this.g) / 2.0) * 127) + 128;
        this.cyan = 255 - this.red;
        this.magenta = 255 - this.green;
        this.yellow = 255 - this.blue;
        this.hue = (int)(atan2(sqrt(3.0) * (this.g - this.b), 2 * (this.r - this.g - this.b)) * (180 / PI));
        this.sorted = false;
    }
}

class sortingFunctions
{
    float[] mask;
    int searchKey = KEY_BRIGHTNESS;
    int searchOperation = GREATER_THAN;
    int searchValue = -1;
    int compareKey = KEY_BRIGHTNESS;
    int compareOperation = GREATER_THAN;
    int compareModifier = 0;
    int sortKey = KEY_BRIGHTNESS;
    int sortOrder = ORDER_ASCEND;
    int maskVectorLength = MASK_DISABLE;
    int maskVectorAngle = MASK_DISABLE;
    float maskLengthScale = 1.;
    float maskAngleScale = 1.;
    boolean useMask = false;
    boolean ignoreSortedPixels = true;
    
    sortingFunctions(){}
    
    pixelData[] getPixelArray(
        pixelData[] data, int index, int x, int y, int w, int h, int maxLength, float angle, float curve
    ){
        // return array of pixels starting at specified index
        
        if (this.useMask) {
            if (this.maskVectorLength == MASK_VEC_LENGTH)
                maxLength += (int)(this.mask[index] * this.maskLengthScale);
            if (this.maskVectorAngle == MASK_VEC_ANGLE)
                angle += this.mask[index] * this.maskAngleScale;
        }
        
        pixelData[] array = new pixelData[maxLength];
        array[0] = data[index];
        
        boolean complete = false;
        int iter = 1;
        int currentIndex = index;
        
        // get centre of pixel +<0.5
        float currentX = x + 0.499;
        float currentY = y + 0.499;
        float stepX = cos(angle);
        float stepY = -sin(angle);
        
        while (!complete && iter < maxLength) {
            // get next sample coords
            
            while (round(currentX) == x && round(currentY) == y) {
                currentX += stepX;
                currentY += stepY;
                if (curve != 0) {
                    angle += curve;
                    stepX = cos(angle);
                    stepY = -sin(angle);
                }
            }
            
            x = round(currentX);
            y = round(currentY);
            currentIndex = y * w + x;
            
            // check for exit conditions
            if ((x > -1 && y > -1 && x < w && y < h) && !this.comparePixels(data[index], data[currentIndex])) {
                array[iter] = data[currentIndex];
                iter += 1;
            } else
                complete = true;
        }
        
        // trim empty array elements
        
        if (iter < maxLength) {
            pixelData[] trim = new pixelData[iter];
            
            for (int i=0; i<trim.length; i++)
                trim[i] = array[i];
                
            return trim;
        }
        
        return array;
    }
    
    boolean comparePixels(pixelData a, pixelData b) {
        if (this.compareOperation == GREATER_THAN)
            return (this.getPixelValue(b, this.compareKey) > this.getPixelValue(a, this.compareKey) + this.compareModifier);
        else
            return (this.getPixelValue(b, this.compareKey) < this.getPixelValue(a, this.compareKey) + this.compareModifier);
    }
    
    boolean testInitialPixel(pixelData p) {
        if (this.ignoreSortedPixels && p.sorted)
            return false;
            
        int val = this.getPixelValue(p, this.searchKey);
        
        if (this.searchOperation == GREATER_THAN && val > this.searchValue)
            return true;
        if (this.searchOperation == LESS_THAN && val < this.searchValue)
            return true;
        return false;
    }
    
    void sortPixelArray(PImage src, pixelData[] array) {
        // sort the pixels!!
        
        int[][] sort = this.getValueArray(array, this.sortKey);

        Arrays.sort(sort, new Comparator<int[]>() {
            @Override
            public int compare(final int[] A, final int[] B) {
                return Integer.compare(A[0], B[0]);
            }
        });

        // re-arrange
        if (this.sortOrder == ORDER_DESCEND) {
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
            array[i].c = src.pixels[sort[i][1]];
            array[i].sorted = true;
        }
    }
    
    int[][] getValueArray(pixelData[] p, int key) {
        int[][] array = new int[p.length][2];

        if (key == KEY_BRIGHTNESS)
          for (int i=0; i<p.length; i+=1) {
              array[i][0] = p[i].brightness;
              array[i][1] = p[i].index;
          }
        else if (key == KEY_RED)
          for (int i=0; i<p.length; i+=1) {
              array[i][0] = p[i].red;
              array[i][1] = p[i].index;
          }
        else if (key == KEY_GREEN)
          for (int i=0; i<p.length; i+=1) {
              array[i][0] = p[i].green;
              array[i][1] = p[i].index;
          }
        else if (key == KEY_BLUE)
          for (int i=0; i<p.length; i+=1) {
              array[i][0] = p[i].blue;
              array[i][1] = p[i].index;
          }
        else if (key == KEY_CYAN)
          for (int i=0; i<p.length; i+=1) {
              array[i][0] = p[i].cyan;
              array[i][1] = p[i].index;
          }
        else if (key == KEY_MAGENTA)
          for (int i=0; i<p.length; i+=1) {
              array[i][0] = p[i].magenta;
              array[i][1] = p[i].index;
          }
        else if (key == KEY_YELLOW)
          for (int i=0; i<p.length; i+=1) {
              array[i][0] = p[i].yellow;
              array[i][1] = p[i].index;
          }
        else if (key == KEY_HUE)
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
    
    int getPixelValue(pixelData p, int key) {
        if (key == KEY_BRIGHTNESS)
          return p.brightness;
        if (key == KEY_RED)
          return p.red;
        if (key == KEY_GREEN)
          return p.green;
        if (key == KEY_BLUE)
          return p.blue;
        if (key == KEY_CYAN)
          return p.cyan;
        if (key == KEY_MAGENTA)
          return p.magenta;
        if (key == KEY_YELLOW)
          return p.yellow;
        if (key == KEY_HUE)
          return p.hue;
        
        return p.brightness;
    }
}