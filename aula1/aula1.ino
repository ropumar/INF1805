
  /*INF1805
  Filipe Ferraz Franco e Costa 1711109
  Rodrigo Pumar Alves de Souza 1221007*/
#define LED_PIN 13
#define BUT_PIN A1
#define KEY2 A2
#define KEY3 A3
void setup() {
  pinMode(LED_PIN,OUTPUT);
  pinMode(BUT_PIN,INPUT_PULLUP);
  pinMode(KEY2,INPUT_PULLUP);
  pinMode(KEY3,INPUT_PULLUP);

}
  unsigned long speed1 = 0;
  int state  = 1;
  unsigned long old=0;
  unsigned long old2 = 0;
  int but1 = 1;
  int but2 = 1;
  void loop() {
  unsigned long now = millis();
  if(now >= old + 1000 + speed1) {
    old = now;
    state = !state;
    digitalWrite(LED_PIN, state);
  }

  if(now >= old2 + 500) {
    old2 = now;
    
    if(!but1&&!but2) {
      while(1);
    }
    else if(!but1){
      if(speed1 < 500){
        speed1 = 0;
      }
     else{ 
      speed1 = speed1 - 500;
     }
    }
    else if(!but2){
      speed1 = speed1 + 500;
    }
    but1=1;
    but2=1;
  }
  else {
    if(!digitalRead(BUT_PIN)) {
      but1=0;
    }
    if(!digitalRead(KEY2)) {
      but2=0;
    }    
  }
}
