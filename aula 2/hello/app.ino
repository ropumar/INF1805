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
  button_listen(0); //listen A1
  pinMode(LED1, OUTPUT); // Enable pin 10 for digital output
  digitalWrite(LED1, 1);
  }
void button_changed(int p, int v) {
  digitalWrite(LED1, v);
}
void timer_expired(void) {
  }
