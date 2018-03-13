  /*INF1805
  Filipe Ferraz Franco e Costa 1711109
  Rodrigo Pumar Alves de Souza 1221007*/
#include "hello.h"
#include "app.h"
#include "pindefs.h"

static int value = LOW;
static unsigned long speed1=1000;
static unsigned long b0=0;
static unsigned long b1=0;
static unsigned long b=0;
void appinit(void) {
  pinMode(KEY1,INPUT_PULLUP);
  pinMode(KEY2,INPUT_PULLUP);
  pinMode(KEY3,INPUT_PULLUP);
  button_listen(0); //listen A1
  button_listen(1); //listen A2
  timer_set (speed1);
  pinMode(LED1, OUTPUT); // Enable pin 10 for digital output
  pinMode(LED4, OUTPUT); // Enable pin 13 for digital output
  }
void button_changed(int p, int v) {
  if(v==1) switch(p){
    case 0: 
         b0=millis();
        if (b0-b1<500) while(1);
        else if(b0-b>500){
          if(speed1 == 0){
            speed1 = 0;
          }
          else speed1 =speed1 - 500;
          timer_set(speed1);
        }
        b=millis();
          break;
    case 1:
        b1=millis();
        if (b1-b0<500) while(1);
        else if (b1-b>500) {
          speed1 =speed1 + 500;
          timer_set(speed1);
        }
        b=millis();
          break;
  }
}
void timer_expired(void) {
  digitalWrite(LED1, !value);
  digitalWrite(LED4, !value);
  value=!value;
  }
