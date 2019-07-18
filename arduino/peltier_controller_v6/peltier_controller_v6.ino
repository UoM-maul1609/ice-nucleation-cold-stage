#include <Wire.h> // for i2c communication between RPi and Arduino
#include <PID_v1.h> // for PID control by Arduino - Brett Beauregard
#include "Adafruit_MAX31855.h" // thermocouple

#define ADDRESS 0x04
#define sampletime 1000 // time for printing to Serial 
#define rpi true
#define FLOATS_SENT 1 // number of floating-point variables sent to RPi
#define high_freq true
float factor = 1.; // was 62
#define MPIN 6

// MAX31855
const int maxSO =  12;
const int maxCS = 11;
const int maxSCK = 10;
//Create a MAX31855 reference and tell it what pin does what
Adafruit_MAX31855 kTC(maxSCK, maxCS, maxSO);



float data_s[FLOATS_SENT]; // buffer to send variables to RPi
byte data[12]; // buffer to read variables sent from RPi (as bytes)
int command,potVal;

unsigned long  starttime,newmillis; // variable to determine when Serial IO occurs

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 variables for PID https://playground.arduino.cc/Code/PIDLibaryBasicExample
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 */
double temperature_read = 0.0, Setpoint=100.0, Output; // set point initially high, so current off
int numr=0;
#define OUTPUT_MIN 235
#define OUTPUT_MAX 10
PID myPID(&temperature_read, &Output,&Setpoint, 2, 5, 1, P_ON_M, REVERSE);
/* ------------------------------------------------------------------
*/

void setup ()
{
  
  Serial.begin(9600);
  pinMode(MPIN, OUTPUT); // output pin for OCR2B
  pinMode(5,INPUT);
  pinMode(4,INPUT);
  pinMode(A1,INPUT); // pot read
  pinMode(9,OUTPUT);
  digitalWrite(9,HIGH);

  if(high_freq) {
    TCCR0B=TCCR0B & B11111000 | B00000001; // set timer 0 divisor to     1 for PWM frequency of 62500.00 Hz
    factor=62.;
    //TCCR1B = TCCR1B & B11111000 | B00000001; // set timer 1 divisor to     1 for PWM frequency of 31371.55 Hz
    //factor=32.;
  } 
    
  starttime = millis()/factor;   // get the current time;

  // turn PID on
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(OUTPUT_MIN, OUTPUT_MAX);
  myPID.SetSampleTime(200*factor);
  data_s[0]=0.;
  // read the temperature
  readTemp();
  // i2c comms
  Wire.begin(ADDRESS);
  Wire.onReceive(receiveEvent); // Register event: receive set point from RPi
  Wire.onRequest(sendData); // send temperature to RPi
}





void readTemp() {
  int value;
  /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   * AD8495 thermocouple
   * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  */
//  value=analogRead(A0);
//  temperature_read=(float(value)/1023.*5.)*203.5837-508.7424;
//  temperature_read=float(value)*1.0528-540.5262;
  temperature_read=kTC.readCelsius();
  
  numr++;
  data_s[0]+=temperature_read;
  /* ------------------------------------------------------------------
  */
}




void loop ()
{
  int mosfetSwitch, usePot, value;

  // read the temperature
  readTemp();
  

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
        //temperature_read=data_s[0] / numr;
        myPID.Compute(); // call every loop, updates automatically at the time interval set
        Output=min(Output,OUTPUT_MIN);
        Output=max(Output,OUTPUT_MAX);
        if(isnan(Output)) Output = 0.;
        if(Setpoint > 50.) Output = 0.;
        analogWrite(MPIN,Output);
        //Serial.println(Output);
        //delay(500*factor);
      } else {
        analogWrite(MPIN,200); 
      }
    } else {              // use potential divider to 
                          // determine PWM for buck converter / Peltier
      potVal=analogRead(A1);
      potVal=map(potVal,0,1023,0,235);
      potVal=min(potVal,235);
      analogWrite(MPIN,potVal);
    }
    //delay(100*factor);
  }
  /* ------------------------------------------------------------------
  */


    Serial.print("Temperature is ");
    Serial.print(temperature_read);
    Serial.print("; Output is ");
    Serial.print(Output);
    Serial.println("");







}



/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * Parse values that have been read in, into a float
 * in this case the set point temperature
 * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
void parseValues(byte data[]) {
  union float_tag {
    byte b[4];
    float fval;
  } ft;
  ft.b[0] = data[1];
  ft.b[1] = data[2];
  ft.b[2] = data[3];
  ft.b[3] = data[4];

  if(!isnan(ft.fval)) Setpoint = double(ft.fval);
  
}
/* ------------------------------------------------------------------
*/



/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * Send data to RPi
 * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
void sendData(){
  /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   * Serial 
   * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  */
  newmillis = millis()/factor;
  if((newmillis-starttime >= sampletime)) {
    data_s[0] /= numr;
    Serial.print("Temperature is ");
    Serial.print(data_s[0]);
    Wire.write((byte*) &data_s[0], FLOATS_SENT*sizeof(float));
    Serial.print(" ");
    Serial.print(Setpoint);
    Serial.print(" ");
    Serial.print(Output);
    Serial.print(" ");
    Serial.print(starttime);
    Serial.print(" ");
    Serial.print(newmillis);
    Serial.println();
    
    starttime=millis()/factor;
    data_s[0]=0.;
    numr=0;
  }
  /* ------------------------------------------------------------------
  */
  //delay(1*factor);
}
/* ------------------------------------------------------------------
*/



/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * function that executes whenever data is received from master 
 * this function is registered as an event, see setup()
 * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
void receiveEvent(int howMany)
{
  byte test, command=0,tmp;
  if(howMany == 0) return;
/*  while (command != 255) {
    command = Wire.read();
    Serial.println(command);
  }
  while (command != 1) {
    command = Wire.read();
    Serial.println(command);
  }*/
  //command = Wire.read();
  //if (command==1){
    int i=0;
    //if(howMany >= 4) {
      while(1 <= Wire.available()) // loop through all but the last
      {
        data[i] = Wire.read(); // receive byte as a character
        if(data[i] == 1) i=-1;
        i = i+1;
        //i=min(i,10);
      }
/*      Serial.print(data[0]);
      Serial.print(" ");
      Serial.print(data[1]);
      Serial.print(" ");
      Serial.print(data[2]);
      Serial.print(" ");
      Serial.print(data[3]);
      Serial.print(" ");
      Serial.print(data[4]);
      Serial.print(" ");*/
      parseValues(data);
   //}
}
/* ------------------------------------------------------------------
*/
