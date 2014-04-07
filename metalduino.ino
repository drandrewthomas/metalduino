#define batterypin 0
#define pushpin 8
#define potpin 1

unsigned long ltime;
volatile int pulses=0;
unsigned int battery=0,pot=0,push=0;
char inbyte;

void setup()
{
  Serial.begin(9600);
  pinMode(2,INPUT);
  attachInterrupt(0,isr,RISING); // 0=Digital Pin 2
  ltime=micros();
}

void isr()
{
  pulses++;
}

void loop()
{
  if(((micros()-ltime)>=50000)||(micros()<ltime))
  {
    detachInterrupt(0); // 0=Digital Pin 2
    battery=analogRead(batterypin);
    pot=analogRead(potpin);
    push=0;
    if(digitalRead(pushpin)==HIGH) push=1;
    Serial.print(pulses,DEC);
    Serial.print(",");
    Serial.print(micros()-ltime,DEC);
    Serial.print(",");
    Serial.print(push,DEC);
    Serial.print(",");
    Serial.print(pot,DEC);
    Serial.print(",");
    Serial.println(battery,DEC);
    if(Serial.available()>0)
    {
      inbyte=Serial.read();
      switch(inbyte)
      {
      }
    }
    pulses=0;
    attachInterrupt(0,isr,RISING); // 0=Digital Pin 2
    ltime=micros();
  }
}

