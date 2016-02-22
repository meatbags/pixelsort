class pixelData
{
  int index;
  int x;
  int y;
  color colour;
  float r;
  float g;
  float b;
  int red;
  int green;
  int blue;
  int cyan;
  int magenta;
  int yellow;
  int brightness;
  int hue;
  boolean flagAsSorted;
  
  pixelData(int index, int x, int y, int colour)
  {
    this.index        = index;
    this.x            = x;
    this.y            = y;
    this.colour       = colour;
    this.r            = ((colour >> 16) & 0xff) / 255.0;
    this.g            = ((colour >> 8) & 0xff) / 255.0;
    this.b            = (colour & 0xff) / 255.0;
    this.brightness   = (int)(((this.r + this.g + this.b) / 3.0) * 255);
    this.red          = (int)((this.r - (this.g + this.b) / 2.0) * 127) + 128;
    this.green        = (int)((this.g - (this.r + this.b) / 2.0) * 127) + 128;
    this.blue         = (int)((this.b - (this.r + this.g) / 2.0) * 127) + 128;
    this.cyan         = 255 - this.red;
    this.magenta      = 255 - this.green;
    this.yellow       = 255 - this.blue;
    this.hue          = (int)(atan2(sqrt(3.0) * (this.g - this.b), 2 * (this.r - this.g - this.b)) * (180 / PI));
    this.flagAsSorted = false;
  }
}