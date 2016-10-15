#include "shared.h"

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
