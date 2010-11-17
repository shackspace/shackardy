
int initLeds[] = {
B00001111,
B00000000,
B00001111,
B00000000,
B00001000,
B00000100,
B00000010,
B00000001,
B00000011,
B00000110,
B00001100,
B00001110,
B00000111,
B00001111,
};

void setup() {
  
  Serial.begin(9600);
  
// outputs 8-11
DDRB = DDRB | B00001111;

// inputs 4-7
DDRD = DDRD & B00001111;

// pullup
PORTD = B11110000;


for(int i=0; i<sizeof(initLeds)/sizeof(*initLeds); ++i)
{
  PORTB = initLeds[i];
  delay(50);
}
for(int i=sizeof(initLeds)/sizeof(*initLeds)-1; i>=0; --i)
{
  PORTB = initLeds[i];
  delay(50);
}

}


int LEDS=0;
int BCUR=0;
int BSTATE=0;
unsigned long DEBOUNCE = 10;
unsigned long lastButtonEvent[4] = {0,0,0,0};
boolean lastButtonState[4] = {false,false,false,false};
int buttonChange = 0;

void loop() {
  if(Serial.available() > 0)
  {
    int data =  Serial.read();
    PORTB = data & B00001111;
  }


  BCUR = ~(PIND >> 4);
  
  for(int i=0; i<4; ++i)
  {
    if(BCUR & (1<<i))
    {
      // button high
      if(lastButtonState[i] == false)
      {
        lastButtonState[i] = true;
        lastButtonEvent[i] = millis();
      }
      else if(lastButtonEvent[i] != 0 && (millis() - lastButtonEvent[i]) > DEBOUNCE)
      {
        lastButtonEvent[i] = 0;
        BSTATE = BSTATE | (1<<i);
        buttonChange = buttonChange | 1;
      }
      else
      {
        // debounce
      }
    }
    else
    {
      // button low
      if(lastButtonState[i] == true)
      {
        lastButtonState[i] = false;
        lastButtonEvent[i] = millis();
      }
      else if(lastButtonEvent[i] != 0 && (millis() - lastButtonEvent[i]) > DEBOUNCE)
      {
        lastButtonEvent[i] = 0;
        BSTATE = BSTATE & ~(1<<i);
        buttonChange = buttonChange | 2; 
      }
      else
      {
        // debounce
      }
    }
  }
  if(buttonChange > 0)
  {
    Serial.print(buttonChange,HEX);
    Serial.println(BSTATE,HEX);
    buttonChange = 0;
  }
}


