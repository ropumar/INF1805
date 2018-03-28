  /*INF1805
  Filipe Ferraz Franco e Costa 1711109
  Rodrigo Pumar Alves de Souza 1221007*/
#include "miniprojeto.h"
#include "app.h"
#include "pindefs.h"

static int pin_used[3] = {0,0,0};
static unsigned long tempo = 0;
static unsigned long old = 0;
static int pin_changed[3] = {1,1,1};

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
  unsigned long now = millis();
  if(now >= old + tempo){
    old = now;
    timer_expired();
    }
 
   if (pin_used[0]==1){
    if(pin_changed[0]!=digitalRead(A1)){
      pin_changed[0]=digitalRead(A1);
      button_changed (0,pin_changed[0]);
      }
   }
   
   if (pin_used[1]==1){
    if(pin_changed[1]!=digitalRead(A2)){
      pin_changed[1]=digitalRead(A2);
      button_changed (0,pin_changed[1]);
      }
   }
   
   if (pin_used[2]==1){
    if(pin_changed[2]!=digitalRead(A3)){
      pin_changed[2]=digitalRead(A3);
      button_changed (0,pin_changed[2]);
      }
    }
  loop_action();
}
