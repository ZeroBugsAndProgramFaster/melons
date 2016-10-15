#include "shared.h"

//--------------------------------------------------------------
// Melon slicer functions
//--------------------------------------------------------------
int catchMelon(void) {
  return getRawMelon();
}

int sliceMelon(int melonSize) {
  return randomInterval(1, melonSize);
}

void discardHalfs(int sliceLocation) {
  putSlicedMelon(sliceLocation);
}


void *melonSlicerLoop(void *unused) {
  do {
    int melon = catchMelon();
    if(melon>0) {
      int sliceLocation = sliceMelon(melon);
      discardHalfs(sliceLocation);
    }
  }while(!melonSlicerShouldStop);

  melonSlicerDidStop = true;
  return NULL;
}

