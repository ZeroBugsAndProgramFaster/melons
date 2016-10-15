#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>

extern int melonThrowerShouldStop;
extern int melonSlicerShouldStop;
extern int melonThrowerDidStop;
extern int melonSlicerDidStop;
extern pthread_t slicerThread;
extern pthread_t throwerThread;
extern pthread_mutex_t rawMutex;
extern pthread_mutex_t slicedMutex;

//returns a random number in the interval, inclusive
int randomInterval(int start, int end);

//When this function is called, it sets 'rawMelon'
//to -1. That is, the value can only be retrieved once.
int getRawMelon();

void putRawMelon(int melonSize);



//When this function is called, it sets 'slicedMelon'
//to -1. That is, the value can only be retrieved once.
int getSlicedMelon();

void putSlicedMelon(int sliceLocation);



//-------------------------------------------
// Methods to start the main loops
//-------------------------------------------
void *melonThrowerLoop(void*);
void *melonSlicerLoop(void*);
