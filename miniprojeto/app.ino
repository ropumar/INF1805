  /*INF1805
  Filipe Ferraz Franco e Costa 1711109
  Rodrigo Pumar Alves de Souza 1221007*/

#include "miniprojeto.h"
#include "app.h"
#include "pindefs.h"

/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8

/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

static int Hora;
static int Hora_Set;
static int Alarme = 0; //Hora do alarme
static int Mode = 0; //Modo relogio = 0, set alarme = 1, set relogio = 2

static int value = LOW;
//static unsigned long speed1=1000;
//static unsigned long b0=0;
//static unsigned long b1=0;
//static unsigned long b=0;
static int cal[4]={1,1,1,1};

void appinit(void) {
  /* Set DIO pins to outputs */
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT); 
  
  pinMode(KEY1,INPUT_PULLUP);
  pinMode(KEY2,INPUT_PULLUP);
  pinMode(KEY3,INPUT_PULLUP);
  
  button_listen(0); //listen A1
  
  pinMode(LED4,OUTPUT);
  pinMode(LED3,OUTPUT);
  pinMode(LED2,OUTPUT);

  digitalWrite(LED4, 0);
  digitalWrite(LED3, 1);
  digitalWrite(LED2, 1);

  /* Initiliase the registers used to store the crrent time and count */
  Hora = 0;

  timer_set(100);
  
  }

void button_changed(int p, int v) {
  switch (p){
    case 0:
      if(v==0){
        if(Mode<2)
          Mode++;
        else
          Mode=0;
      }
      switch (Mode){
        case 0:
          digitalWrite(LED4, 0);
          digitalWrite(LED2, 1);
          break;
         case 1:
          digitalWrite(LED4, 1);
          digitalWrite(LED3, 0);
          break;
         case 2:
          digitalWrite(LED3, 1);
          digitalWrite(LED2, 0);
          break;
    } 
  }
}  

void timer_expired(void) {
   Hora++;
   if(Mode!=2)
    Hora_Set=Hora;
   if(Hora%100==60)
   {
     Hora = Hora+40;
   } else if(Hora/100==24)
   {
     Hora = 0;
   }
}

void loop_action(void){
  if(Mode==0) //relogio
    WriteNumber(Hora);
  else if(Mode==1) //set alarme
    WriteNumber(Alarme);
  else if(Mode==2) //set hora
    WriteNumber(Hora_Set);
}


void WriteNumber(int Number)
{
  WriteNumberToSegment(0 , Number / 1000);
  WriteNumberToSegment(1 , (Number / 100) % 10);
  WriteNumberToSegment(2 , (Number / 10) % 10);
  WriteNumberToSegment(3 , Number % 10);
}

/* Wite a ecimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value)
{
  digitalWrite(LATCH_DIO,LOW); 
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]/*-0x80*/);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);    
}

