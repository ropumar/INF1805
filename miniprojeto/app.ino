  /*INF1805
  Filipe Ferraz Franco e Costa 1711109
  Rodrigo Pumar Alves de Souza 1221007
  
  Com codigo de:
    ARD_Multifunction_Shield_Buzzer_Example
    ARD_Multifunction_Shield_Seven_Segment_Example
  Do site: HobbyComponents.com*/

#include "miniprojeto.h"
#include "app.h"
#include "pindefs.h"

/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8

#define POT_DIO 0

/* Define the digital pin used to control the buzzer */
#define BUZZER_DIO 3

#define OFF HIGH
#define ON LOW

/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

static int Hora;
static int Seg=0;
static int Hora_Set;
static int Hora_Set_Old;
static int Alarme = 0; //Hora do alarme
static int Alarme_Old = 0; //Hora do alarme
static int Mode = 2; //Modo relogio = 0, set alarme = 1, set relogio = 2
static int Toque = 0;
static int Snooze = 0;
static int SnoozeFlag = 0;
static int AlarmeFlag = 0;

static int value = LOW;
//static unsigned long speed1=1000;
//static unsigned long b0=0;
//static unsigned long b1=0;
//static unsigned long b=0;
static int cal[4]={1,1,1,1};

void appinit(void) {
  Serial.begin(9600);
  /* Set DIO pins to outputs */
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT); 
  
  pinMode(KEY1,INPUT_PULLUP);
  pinMode(KEY2,INPUT_PULLUP);
  pinMode(KEY3,INPUT_PULLUP);
  
  button_listen(0); //listen A1
  button_listen(1); //listen A2
  button_listen(2); //listen A3
  
  pinMode(LED4,OUTPUT);
  pinMode(LED3,OUTPUT);
  pinMode(LED2,OUTPUT);
  pinMode(LED1,OUTPUT);

  digitalWrite(LED4, 1);
  digitalWrite(LED3, 1);
  digitalWrite(LED2, 0);
  digitalWrite(LED1, 1);

  /* Initiliase the registers used to store the crrent time and count */
  Hora = 0;

  timer_set(1000);

  pinMode(BUZZER_DIO, OUTPUT);
  digitalWrite(BUZZER_DIO, OFF);
  
  }

void button_changed(int p, int v) {
  switch (p){
    case 0: //botao 1
      if(Toque==0){
        if(v==0){
          if(Mode<2)
            Mode++;
          else
            Mode=0;
        }
        switch (Mode){
          case 0:
            if(Hora_Set_Old!=Hora_Set){
              Hora=Hora_Set;
              Seg=0;
            }
            digitalWrite(LED4, 0);
            digitalWrite(LED2, 1);
            break;
           case 1:
            digitalWrite(LED4, 1);
            digitalWrite(LED3, 0);
            break;
           case 2:
            if(Alarme_Old!=Alarme)
            {
              Alarme_Old=Alarme;
              AlarmeFlag=1;
              digitalWrite(LED1, !AlarmeFlag);
            }
            Hora_Set_Old=Hora_Set;
            digitalWrite(LED3, 1);
            digitalWrite(LED2, 0);
            break;
      }
    } 
    break;
    case 1: //botao 2
      if(v==0)
        switch(Mode){
          case 0:
          if (Toque==1){
            Snooze=Hora+5;
            if(Snooze%100==60)
             {
               Snooze = Snooze+40;
             } else if(Snooze/100==24)
             {
               Snooze = Snooze - 2400;
             }
              digitalWrite(BUZZER_DIO, OFF);
              SnoozeFlag=1;
              Toque=0;
          }
          break;
          case 1:
              Alarme=Alarme+100;
              if(Alarme/100==24)
                Alarme=Alarme-2400;
          break;
          case 2:
              Hora_Set=Hora_Set+100;
              if(Hora_Set/100==24)
                Hora_Set=Hora_Set-2400;
          break;
        }
      break;
    case 2: //botao 3
      if(v==0)
        switch(Mode){
          case 0:
          if(Toque==1){
            digitalWrite(BUZZER_DIO, OFF);
            Toque=0;
            SnoozeFlag=0;
          }
          else{
             AlarmeFlag = !AlarmeFlag;
             digitalWrite(LED1, !AlarmeFlag);
          }
          break;
          case 1:
              Alarme++;
              if(Alarme%100==60)
                Alarme=Alarme-60;
          break;
          case 2:
              Hora_Set++;
              if(Hora_Set%100==60)
                Hora_Set=Hora_Set-60;
          break;
        }
      break;
  }
}  

void timer_expired(void) {
   Seg++;
   Serial.print(Seg);
   if(Seg==60){
    Hora++;
    Seg=0;
     if(Mode!=2){
      Hora_Set=Hora;
     }
     if(Hora%100==60)
     {
       Hora = Hora+40;
     } if(Hora/100==24)
     {
       Hora = Hora - 2400;
     }
     if(AlarmeFlag==1&&Hora==Alarme&&Mode==0){
        digitalWrite(BUZZER_DIO, ON);
        Toque=1;
     }
     else if(AlarmeFlag==1&&SnoozeFlag==1&&Hora==Snooze&&Mode==0)
     {
        digitalWrite(BUZZER_DIO, ON);
        Toque=1;
     }  
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

