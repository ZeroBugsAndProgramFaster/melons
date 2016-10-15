#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>

int melonThrowerShouldStop;
int melonSlicerShouldStop;
int melonThrowerDidStop;
int melonSlicerDidStop;
pthread_t slicerThread;
pthread_t throwerThread;
pthread_mutex_t rawMutex;
pthread_mutex_t slicedMutex;

//returns a random number in the interval. Inclusive
int randomInterval(int start, int end) {
  return (random() % (end-start)) + start;
}

//--------------------------------------------------------------
// Any function that needs locks
//--------------------------------------------------------------
int rawMelon = -1;

void putRawMelon(int melonSize) {
  pthread_mutex_lock(&rawMutex);
  rawMelon = melonSize;
  pthread_mutex_unlock(&rawMutex);
}

int getRawMelon() {
  pthread_mutex_lock(&rawMutex);
  int t = rawMelon;
  rawMelon = -1;
  pthread_mutex_unlock(&rawMutex);
  return t;
}


int slicedMelonLocation = -1;
void putSlicedMelon(int sliceLocation) {
  pthread_mutex_lock(&slicedMutex);
  slicedMelonLocation = sliceLocation;
  pthread_mutex_unlock(&slicedMutex);
}

int getSlicedMelon() {
  pthread_mutex_lock(&slicedMutex);
  int t = slicedMelonLocation;
  slicedMelonLocation = -1;
  pthread_mutex_unlock(&slicedMutex);
  return t;
}


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



//--------------------------------------------------------------
// Main loop functions
//--------------------------------------------------------------
bool startMelonSlicer(void) {
  return 0==pthread_create(&slicerThread, NULL, melonSlicerLoop, NULL);
}

bool startMelonThrower(void) {
  return 0==pthread_create(&throwerThread, NULL, melonThrowerLoop, NULL);

}

void waitForStopSignal(void) {
  char s[100];
  
  //any input from user is a stop signal
  fgets(s, sizeof(s)-1, stdin);
}

void sendMelonThrowerStopSignal(void) {
  melonThrowerShouldStop = true;
}


void waitForMelonThrowerStop(void) {
  //spin wait
  while(!melonThrowerDidStop)
    ;
}

void sendMelonSlicerStopSignal(void){
  melonSlicerShouldStop = true;
}

void waitForMelonSlicerStop(void) {
  //spin wait
  while(!melonSlicerDidStop)
    ;
}

void cleanupAllResources(void) {
  pthread_join(slicerThread, NULL);
  pthread_join(throwerThread, NULL);
  pthread_mutex_destroy(&rawMutex);
  pthread_mutex_destroy(&slicedMutex);
}

void initializeAllResources(void) {
  melonThrowerShouldStop = false;
  melonSlicerShouldStop = false;
  melonThrowerDidStop = false;
  melonSlicerDidStop = false;
  pthread_mutex_init(&rawMutex, NULL);
  pthread_mutex_init(&slicedMutex, NULL);
}


int main(void) {
  initializeAllResources();
  
  startMelonSlicer();
  startMelonThrower();
  
  waitForStopSignal();
  
  sendMelonThrowerStopSignal();
  waitForMelonThrowerStop();

  sendMelonSlicerStopSignal();
  waitForMelonSlicerStop();

  
  cleanupAllResources();
  return 0;
}
