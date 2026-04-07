#include <util/atomic.h>

#include <Wire.h> // for i2c communication between RPi and Arduino
#include <PID_v1.h> // for PID control by Arduino

#define ADDRESS 0x04
#define sampletime 1000 // time for printing to Serial 
#define rpi true
#define writeserial false
#define FLOATS_SENT 1 // number of floating-point variables sent to RPi
#define high_freq true
float factor = 1.; // was 62
#define MPIN 6

volatile float data_s[FLOATS_SENT]; // buffer to send variables to RPi
volatile float tstore=0.;
volatile float tstore2;
byte data[12]; // buffer to read variables sent from RPi (as bytes)
int command,potVal;

unsigned long  starttime,newmillis,starttime2,newmillis2; // variable to determine when Serial IO occurs




/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 variables for PID https://playground.arduino.cc/Code/PIDLibaryBasicExample
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 */
volatile float temperature_read = 0.0,Setpoint=100.0, Output, OutputC; // set point initially high, so current off
volatile float temperature_pid = 0.0;
volatile int numr=0,numrs=0;
#define OUTPUT_MIN 235
#define OUTPUT_MAX 5
//PID myPID((double *) &temperature_read, (double *) &Output,
//  (double *) &Setpoint, 2, 5, 1, P_ON_E, REVERSE);

// tuned at 5 C using Ziegler-Nichols method
// http://www.pcbheaven.com/wikipages/PID_Theory/?p=1
// set i and d to zero, slowly increase kc
//  until oscillation centered about set-point
// note period of oscillation in seconds - this is pc
/*#define pc 30. // seconds
#define kc 21. // critical gain
PID myPID((double *) &temperature_pid, (double *) &Output,
  (double *) &Setpoint, 0.6*kc/15.0, 0.5*pc, pc/8., P_ON_M, REVERSE);*/
/*#define kp 0.18
#define ki 0.015
#define kd 0.0*/

#define kpw 15.0
#define kiw 0.5
#define kdw 0.1

#define kpc kpw
#define kic kiw
#define kdc kdw

PID myPID((double *) &temperature_pid, (double *) &Output,
  (double *) &Setpoint, kpw,kiw,kdw, P_ON_E, REVERSE);
/* ------------------------------------------------------------------
*/

void setup ()
{
  
  Serial.begin(9600);
  Serial.println("Peltier Controller Code for Cold Stage 000 (2026-04-03)");
  
  pinMode(MPIN, OUTPUT); // output pin for OCR2B
  pinMode(5,INPUT);
  pinMode(4,INPUT);
  pinMode(A1,INPUT); // pot read

  if(high_freq) {
    /*TCCR0B=TCCR0B & B11111000 | B00000001; // set timer 0 divisor to     1 for PWM frequency of 62500.00 Hz
    factor=62.; // shoudl be 64 */
    //TCCR1B = TCCR1B & B11111000 | B00000001; // set timer 1 divisor to     1 for PWM frequency of 31371.55 Hz
    /*factor=31.;
    TCCR0A = _BV(COM0A1) | _BV(COM0B1) | _BV(WGM01) | _BV(WGM00);
    TCCR0B = _BV(CS01); // Prescaler 8 -> 16MHz / (8 * 64) = 31.25kHz*/

    // 7.8kHz
    TCCR0B = (TCCR0B & B11111000) | B00000010;
    factor = 8.;
} 
    
  starttime = millis()/factor;   // get the current time;
  starttime2 = millis()/factor;   // get the current time;

  // turn PID on
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(OUTPUT_MAX, OUTPUT_MIN);
  myPID.SetSampleTime(30*factor);
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
  value=analogRead(A0);
//  temperature_read=(float(value)/1023.*5.)*203.5837-508.7424;
//  temperature_read=float(value)*1.0528-540.5262;
// temperature_read=(float(value)/1023.*5.-1.25)/5.e-3 - 6.3;
 temperature_read=float(value)*1.060998-282.715;
 
// low-pass filter
temperature_pid = 0.9*temperature_pid + 0.1*temperature_read; //Serial.println(value);

  ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
  {    
      numr++;
      data_s[0]+=temperature_read;
  }
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
  {    
      tstore+=temperature_read;
      numrs++;
  }
}




void loop ()
{
  int mosfetSwitch, usePot, value;

  // read the temperature
  readTemp();
  
  newmillis = millis()/factor;
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
        if (Setpoint > -20.0) {
          myPID.SetTunings(kpw,kiw,kdw);
        } else {
          myPID.SetTunings(kpc,kic,kdc);
        }
        //temperature_read=data_s[0] / numr;
        myPID.Compute(); // call every loop, updates automatically at the time interval set
        OutputC = Output;
        OutputC=min(OutputC,OUTPUT_MIN);
        OutputC=max(OutputC,OUTPUT_MAX);
        if(isnan(OutputC)) OutputC = 0.;
        if(Setpoint > 50.) OutputC = 0.;
        analogWrite(MPIN,OutputC);
        //Serial.println(Output);
        //delay(500*factor);
      } else {
        analogWrite(MPIN,200); 
      }
    } else {              // use potential divider to 
                          // determine PWM for buck converter / Peltier
      potVal=analogRead(A1);
      potVal=map(potVal,0,1023,0,OUTPUT_MIN);
      potVal=min(potVal,OUTPUT_MIN);
      analogWrite(MPIN,potVal);
    }
    //delay(100*factor);
  }
  /* ------------------------------------------------------------------
  */
  /*newmillis2=millis()/factor;
  if((newmillis2-starttime2 >= sampletime)) {
    float temp;
    Serial.print("Temperature is ");
    temp=tstore / numrs;
    Serial.print(temp);
    Serial.print("; Output is ");
    Serial.print(Output);
    Serial.println("");
    starttime2=millis()/factor;
    tstore=0.;
    numrs=0;
  }*/






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
  ft.b[0] = data[2];
  ft.b[1] = data[3];
  ft.b[2] = data[4];
  ft.b[3] = data[5];

  if(!isnan(ft.fval)) Setpoint = float(ft.fval);
  
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
  
  
  //if((newmillis-starttime) >= sampletime) {
//    data_s[0] /= numr;
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
    {    
      tstore2=(float)data_s[0] / numr;

    byte *b = (byte*)&tstore2;
    uint8_t checksum = b[0] ^ b[1] ^ b[2] ^ b[3];
    Wire.write((uint8_t *) &tstore2, FLOATS_SENT*sizeof(float));
    Wire.write(checksum);      // send checksum byte
    
    data_s[0]=0.;
    numr=0;

#if writeserial
    Serial.print("Temperature is ");
    Serial.print(tstore2);
    Serial.print(" ");
    Serial.print(Setpoint);
    Serial.print(" ");
    Serial.print(Output);
    Serial.print(" ");
    Serial.print(starttime);
    Serial.print(" ");
    Serial.print(newmillis);
    Serial.println();
#endif

    starttime=newmillis;
//    delay(1*factor);
    }
  //}
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
void receiveEvent1(int howMany)
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
   //myPID.SetTunings(0.6*kc, 0.5*pc, pc/8.);
} 

void receiveEvent(int howMany)
{
  int count = 0;

  while (Wire.available()) {
    byte b = Wire.read();

    if (count < 8) {
      data[count] = b;
    } else {
      // shift left and keep only the newest 8 bytes
      data[0] = data[1];
      data[1] = data[2];
      data[2] = data[3];
      data[3] = data[4];
      data[4] = data[5];
      data[5] = data[6];
      data[6] = data[7];
      data[7] = b;
    }
    count++;
  }

  // Ignore the 1-byte transaction sent before Pi reads
  if (count == 1 && data[0] == 0) return;

  // Expect the last 8 bytes to be: 1, 6, f0, f1, f2, f3, command, test
  if (count >= 8 && data[0] == 1 && data[1] == 6) {
    parseValues(data);
  }
}
/* ------------------------------------------------------------------
*/





