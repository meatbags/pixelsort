// example

PImage source;

void setup() {
    source = loadImage("./images/spock.jpg");
    surface.setSize(source.width, source.height);
}

void draw() {
    pixelSorter PS = new pixelSorter(source);
    
    // set up
    
    PS.setSearchOptions(KEY_BRIGHTNESS, GREATER_THAN, 0);
    PS.setCompareOptions(KEY_HUE, GREATER_THAN, 100);
    PS.setSortOptions(KEY_BRIGHTNESS, ORDER_PEAK);
    
    // create a mask
    
    PS.useMask(loadImage("./images/mask.jpg"));
    //PS.setMaskOptions(MASK_VEC_LENGTH, 0);
    PS.setMaskOptions(MASK_VEC_ANGLE, PI/6);
    PS.disableMask();
    
    // example sort
    
    int len = 100;
    double angle = 0;
    double curve = 0;
    
    //PS.sortRing(len, source.width/2, source.height/2, false);
    PS.sortRadial(len, source.width/2, source.height/2, curve);
    //PS.sortRadial(len/4, source.width/2, 0, curve);
    //PS.sortDirectional(len, angle, curve);
    
    // display output
    image(PS.getImage(), 0, 0);
    save("./images/output.tif");
    noLoop();
}