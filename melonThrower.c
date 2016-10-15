#include "shared.h"

//--------------------------------------------------------------
// Melon thrower functions
//--------------------------------------------------------------
int chooseMelon(void) {
  return randomInterval(5, 10); //pick a melon from the pile
}

void throwMelon(int melonSize) {
  putRawMelon(melonSize);
}

int getMelonHalfs(void) {
  return getSlicedMelon();
}

void evaluateSlice(int sliceLocation, int melonSize) {
  if(sliceLocation == melonSize/2) {
    printf("Perfect slice!\n");
  }
  else if(abs(melonSize/2-sliceLocation)<=2) {
    printf("Great slice!\n");
  }
  else
    printf("Keep practicing slicing!\n");
}

void *melonThrowerLoop(void *unused) {
  int melonSize = -1;
  bool readyToThrow = true;
  do {
    if(readyToThrow) {
      melonSize = chooseMelon();
      throwMelon(melonSize);
      readyToThrow = false;
    }
    
    int sliceLocation = getMelonHalfs();
    if(sliceLocation>0) {
      evaluateSlice(sliceLocation, melonSize);
      readyToThrow = true;
    }
  }while(!melonThrowerShouldStop);

  melonThrowerDidStop = true;

  return NULL;
}
