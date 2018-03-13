  /*INF1805
  Filipe Ferraz Franco e Costa 1711109
  Rodrigo Pumar Alves de Souza 1221007*/
#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

static int pin_used[4] = {0,0,0,0};
static unsigned long tempo=0;
static unsigned long old = 0;

void button_listen (int pin){
  pin_used[pin]=1;
}
void timer_set (int ms){
  tempo= (unsigned long) ms;
}


void setup(){
  appinit();
}

void loop () {
 // button_changed(int p, int v);
 unsigned long now = millis();
 if(now >= old + tempo){
    old = now;
    timer_expired();
    }
    if (pin_used[0]==1)
      if(!digitalRead(A1)){
        button_changed (0,1);
      }
    if (pin_used[1]==1)
      if(!digitalRead(A2)){
        button_changed (1,1);
      }
    }
