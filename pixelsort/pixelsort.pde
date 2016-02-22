/*
    *********************************************
                  TUTORIAL PART 2 
    *********************************************
  
                       ,
                      dM
                      MMr
                     4MMML                  .
                     MMMMM.                xf
     .              "M6MMM               .MM-
      Mh..          +MM5MMM            .MMMM
      .MMM.         .MMMMML.          MMMMMh
       )MMMh.        MM5MMM         MMMMMMM
        3MMMMx.     'MMM3MMf      xnMMMMMM"
        '*MMMMM      MMMMMM.     nMMMMMMP"
          *MMMMMx    "MMM5M\    .MMMMMMM=
           *MMMMMh   "MMMMM"   JMMMMMMP
             MMMMMM   GMMMM.  dMMMMMM            .
              MMMMMM  "MMMM  .MMMMM(        .nnMP"
   ..          *MMMMx  MMM"  dMMMM"    .nnMMMMM*
    "MMn...     'MMMMr 'MM   MMM"   .nMMMMMMM*"
     "4MMMMnn..   *MMM  MM  MMP"  .dMMMMMMM""
       ^MMMMMMMMx.  *ML "M .M*  .MMMMMM**"
          *PMMMMMMhn. *x > M  .MMMM**""
             ""**MMMMhx/.h/ .=*"
                      .3P"%....
                     nP"     "*MMnx 
    
    1. Run the program to see if it works.
    2. Read through the code.
    3. Detailed explanations on the right.
    4. Modify the code.
    5. Hack the mainframe 420blazeit.
    
    NOTES:
    
    1. Don't modify the files "funcs", "pixel",
       and "sorter". Open them and masturbate
       over the code if you want (especially
       funcs.pde that shit is tight), but
       change anything and there's a 99% chance
       the program will break.
          
    2. Class/ function syntax looks like this:
    
       className.functionName( );
       
       *Arguments* go between the parantheses
       separated, by, commas. A function that
       accepts three int (data type for integer)
       arguments could look like this:
       
       className.functionName(2, 5, 3);
       
       Or you can *declare* the ints first:
       
       int argument1 = 3;
       int arg2      = 7;
       int whatever  = 400;
       className.functionName(argument1, arg2, whatever);
    
    *********************************************
                  TUTORIAL PART 2
    *********************************************
*/

PImage sourceImage;                                                            // image container (data type for images is PImage)

void setup()
{
  sourceImage = loadImage("img/input.jpg");                                    // load your input image here (change to whatever you like)
                                                                               // for example, put an image called nye.jpg in the img folder
                                                                               // and change to loadImage("img/nye.jpg");
                                                                         
  surface.setSize(sourceImage.width, sourceImage.height);                      // sets the size of the drawing surface (don't change)
}

void draw()
{
  pixelSorter sorter = new pixelSorter(sourceImage);                           // pixel sorting class
                                                                               // opens functions from the other files
  
  /* ########## START SAFE EDITING AREA ########### */                         // I've included all possible functions in this area for demo purposes
  /* ########## START SAFE EDITING AREA ########### */                         // None of them are mandatory. You can delete anything in the safe area.
  /* ########## START SAFE EDITING AREA ########### */                         // Recommend saving a copy of this tutorial (in another folder) and  //<>//
                                                                               // then deleting everything in this area to give you a clean slate.
  
  /* --- MASK FUNCTIONS --- */
  
  sorter.setMaskImage(loadImage("img/mask.jpg"));                              // description: load a mask image (must have same dimensions as input image)
  
  int len = 100;
  sorter.setMaskFunction(MASK_SEGMENT_LENGTH, len);                            // options:
                                                                               //   argument 1: MASK_SEGMENT_LENGTH, MASK_SEGMENT_ANGLE
                                                                               //   argument 2: positive integer
                                                                               //
                                                                               // description:
                                                                               //   set the mask to modify the length of segments
  
  double angle = Math.toRadians(90);                                     
  sorter.setMaskFunction(MASK_SEGMENT_ANGLE, angle);                           // options:
                                                                               //   argument 1: MASK_SEGMENT_LENGTH, MASK_SEGMENT_ANGLE
                                                                               //   argument 2: angle (in radians)
                                                                               //
                                                                               // description:
                                                                               //   set the mask to modify the angle of segments
                                                                               //
                                                                               // note:
                                                                               //   all the angles in the program are in radians
                                                                               //   to convert degrees to radians use Math.toRadians();
  
  sorter.disableMask();                                                        // description: disable the mask
  sorter.enableMask();                                                         // description: enable the mask
                                                                               //
                                                                               // note: mask is enabled automatically on sorter.setMaskImage();
                                                                               //   just put these functions here so you know they exist
  
  /* --- SORTING SETTINGS --- */
  
  sorter.ignoreSorted(false);                                                  // options: true, false
                                                                               //
                                                                               // description: if set to (true), the algorithm will ignore
                                                                               //   previously sorted pixels and will not re-sort them.
                                                                               //   both options produces slightly different results but
                                                                               //   (true) makes the program run faster (less pixels to sort)
                                                                         
  sorter.setSearchFunction(  SORT_KEY_BRIGHTNESS, LESS_THAN, 200);             // options:
                                                                               //   argument 1: SORT_KEY_BRIGHTNESS, SORT_KEY_HUE, SORT_KEY_RED,
                                                                               //               SORT_KEY_BLUE, SORT_KEY_GREEN, SORT_KEY_CYAN,
                                                                               //               SORT_KEY_MAGENTA, SORT_KEY_YELLOW
                                                                               //   argument 2: LESS_THAN, GREATER_THAN
                                                                               //   argument 3: integer between -1 and 256
                                                                               // 
                                                                               // description:
                                                                               //   set the initial search conditions as described in STEP 1 (tutorial pt 1)
                                                                         
  sorter.setCompareFunction( SORT_KEY_BRIGHTNESS, GREATER_THAN );              // options:
                                                                               //   argument 1: SORT_KEY_BRIGHTNESS, SORT_KEY_HUE, SORT_KEY_RED,
                                                                               //               SORT_KEY_BLUE, SORT_KEY_GREEN, SORT_KEY_CYAN,
                                                                               //               SORT_KEY_MAGENTA, SORT_KEY_YELLOW
                                                                               //   argument 2: LESS_THAN, GREATER_THAN
                                                                               //
                                                                               // description:
                                                                               //   set the compare function as described in STEP 2
                                                                         
  sorter.setCompareModifier(0);                                                // options: integer between -256 and +256
                                                                               //
                                                                               // description:
                                                                               //   modifier for the compare function as described in STEP 2
                                                                               //
                                                                               // example:
                                                                               //   if compare func is SORT_KEY_RED, LESS_THAN
                                                                               //   and modifier is -10, the function will be
                                                                               //   (exitpixel.red) < (initialpixel.red - 10)
                                                                         
  sorter.setSortFunction(    SORT_KEY_BRIGHTNESS, ORDER_ASCENDING );           // options:
                                                                               //   argument 1: SORT_KEY_BRIGHTNESS, SORT_KEY_HUE, SORT_KEY_RED,
                                                                               //               SORT_KEY_BLUE, SORT_KEY_GREEN, SORT_KEY_CYAN,
                                                                               //               SORT_KEY_MAGENTA, SORT_KEY_YELLOW
                                                                               //   argument 2: ORDER_ASCENDING, ORDER_DESCENDING, ORDER_PEAK, ORDER_TROUGH
                                                                               //   
                                                                               // description:
                                                                               //   set the sorting order as described in STEP 3
  
  
  /* --- SORTING FUNCTIONS --- */
  
  int segmentLength = 40;                                                      // set up some variables
  double segmentAngle = Math.toRadians(180);                                   // (not actually necessary)
  double curve = 0.01;
  
  sorter.sortDirection(segmentLength, segmentAngle, curve);                    // options:
                                                                               //   argument 1: max segment length (positive int)
                                                                               //   argument 2: direction to sort (radians)
                                                                               //   argument 3: curvature of vector (radians)
                                                                               //
                                                                               // description:
                                                                               //   sort the image in a certain direction!
                                                                               
  sorter.sortRadial(40, sourceImage.width / 2, sourceImage.height / 2, 0);     // options:
                                                                               //   argument 1: max segment length (positive int)
                                                                               //   argument 2: x coordinate (int)
                                                                               //   argument 3: y coordinate (int)
                                                                               //   argument 4: curvature (radians)
                                                                               //
                                                                               // description:
                                                                               //   sort the image radially outward from XY coordinates
                                                                               //   in this example I'm sorting from the centre of the
                                                                               //   image by setting X to width / 2 and Y to height / 2
  
  sorter.sortRing(4, sourceImage.width / 2, sourceImage.height / 2, false);    // options:
                                                                               //   argument 1: max segment length (positive int) 
                                                                               //   argument 2: x coord (int)
                                                                               //   argument 3: y coord (int)
                                                                               //   argument 4: true, false (clockwise or anti-clockwise)
                                                                               // 
                                                                               // description:
                                                                               //   sort the image in a ring around XY coords
  
  /* ####### END SAFE AREA ######## */
  /* ####### END SAFE AREA ######## */
  /* ####### END SAFE AREA ######## */
  
  image(sorter.getSortedImage(), 0, 0);                                        // draw the sorted image on the screen
  save("img/image_output.tif");                                                // save the image (change to whatever you like)
  
  noLoop();                                                                    // prevent the program from looping (don't change)
}