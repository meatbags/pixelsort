PImage sourceImage;
PImage maskImage;

void setup()
{
  sourceImage = loadImage("image_input.jpg");
  maskImage   = loadImage("mask.jpg");
  surface.setSize(sourceImage.width, sourceImage.height);
}

void draw()
{
  pixelSorter sorter = new pixelSorter(sourceImage);
  
  //mask settings
  sorter.disableMask();
  //sorter.setMaskImage(maskImage);
  //sorter.setMaskFunction(MASK_SEGMENT_LENGTH, 10);
  //sorter.setMaskFunction(MASK_SEGMENT_ANGLE, Math.toRadians(90));
  
  // sorter settings
  sorter.ignoreSorted(true);
  sorter.setSearchFunction( SORT_KEY_BRIGHTNESS, LESS_THAN, 256 );
  sorter.setCompareFunction(SORT_KEY_BRIGHTNESS, GREATER_THAN );
  sorter.setCompareModifier(255);
  sorter.setSortFunction(   SORT_KEY_HUE, ORDER_PEAK );
  
  // sort
  sorter.sortDirection(sourceImage.width, 0, 0);
  
  sorter.setSortFunction(SORT_KEY_BRIGHTNESS, ORDER_ASCENDING );
  
  sorter.sortDirection(sourceImage.width, 0, 0);
  //sorter.sortRadial(sourceImage.width, sourceImage.width / 2, sourceImage.height / 2, 0);
  //sorter.sortRing(100, sourceImage.width / 2, sourceImage.height / 2, true);
  
  // display & save image
  image(sorter.getSortedImage(), 0, 0);
  save("image_output.tif");
  
  noLoop();
}