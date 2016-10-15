#include "shared.h"

//--------------------------------------------------------------
// Main loop functions
//--------------------------------------------------------------
bool startMelonSlicer(void) {
  return 0==pthread_create(&slicerThread, NULL, melonSlicerLoop, NULL);
}

bool startMelonThrower(void) {
  return 0==pthread_create(&throwerThread, NULL, melonThrowerLoop, NULL);

}

void waitForStopSignalFromKeyboard(void) {
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
  
  waitForStopSignalFromKeyboard();
  
  sendMelonThrowerStopSignal();
  waitForMelonThrowerStop();

  sendMelonSlicerStopSignal();
  waitForMelonSlicerStop();

  
  cleanupAllResources();
  return 0;
}
