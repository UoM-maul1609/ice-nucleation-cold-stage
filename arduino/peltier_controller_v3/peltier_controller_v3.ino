#include <AutoPID.h>

#define sampletime 250
#define rpi true
unsigned int  starttime;

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 variables for PID http://ryandowning.net/AutoPID/
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 */
double temperature_read = 0.0, Setpoint=-5.0, Output;
#define OUTPUT_MIN 235
#define OUTPUT_MAX 0
#define KP .012
#define KI .03
#define KD 0.1
AutoPID myPID(&temperature_read, &Setpoint, &Output,OUTPUT_MIN,OUTPUT_MAX, KP, KI, KD);
unsigned long lastTempUpdate; //tracks clock time of last temp update
/* ------------------------------------------------------------------
*/

void setup ()
{
  Serial.begin(9600);
  pinMode(6, OUTPUT); // output pin for OCR2B
  pinMode(5,INPUT);
  pinMode(4,INPUT);
  pinMode(A1,INPUT); // pot read

  TCCR0B=TCCR0B & B11111000 | B00000001; // set timer 0 divisor to     1 for PWM frequency of 62500.00 Hz
  starttime = millis();   // get the current time;

  //if temperature is more than 4 degrees below or above setpoint, 
  // OUTPUT will be set to min or max respectively
  myPID.setBangBang(1);
  //set PID update interval to 200ms
  myPID.setTimeStep(4000);
}



void loop ()
{
  int mosfetSwitch, usePot, potVal, value;

  
  /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   * AD8495 thermocouple
   * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  */
  value=analogRead(A0);
  temperature_read=(float(value)/1023.*5)*203.5837-508.7424;
  /* ------------------------------------------------------------------
  */


  /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   * Power to Peltier
   * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  */
  mosfetSwitch=digitalRead(4); 
  if(mosfetSwitch==LOW) { // turn off current to Peltier
    analogWrite(6,0);
  } else {                // turn on current to Peltier
    usePot=digitalRead(5);
    
    if(usePot == LOW) {   // default set-point for PWM to 
                          // buck converter / Peltier

      if(rpi) {
        myPID.run(); // call every loop, updates automatically at the time interval set
        analogWrite(6,Output);
        Serial.println(Output);
      } else {
        analogWrite(6,200); 
      }
    } else {              // use potential divider to 
                          // determine PWM for buck converter / Peltier
      potVal=analogRead(A1);
      potVal=map(potVal,0,1023,0,235);
      potVal=min(potVal,235);
      analogWrite(6,potVal);
    }
  }
  /* ------------------------------------------------------------------
  */










  /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   * Serial 
   * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  */
  if(millis()-starttime >= sampletime) {
    Serial.print("Temperature is ");
    Serial.print(temperature_read);
    Serial.print(" ");
    Serial.print(value);
    Serial.println("");
    starttime=millis();
  }
  /* ------------------------------------------------------------------
  */

}


