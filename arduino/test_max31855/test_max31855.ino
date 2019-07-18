#include "Adafruit_MAX31855.h" // thermocouple


// MAX31855
const int maxSO =  12;
const int maxCS = 11;
const int maxSCK = 10;
//Create a MAX31855 reference and tell it what pin does what
Adafruit_MAX31855 kTC(maxSCK, maxCS, maxSO);



unsigned long  starttime,newmillis; // variable to determine when Serial IO occurs

double temperature_read = 0.0, Setpoint=100.0, Output; // set point initially high, so current off
/* ------------------------------------------------------------------
*/

void setup ()
{
  
  Serial.begin(9600);
  
  starttime = millis();   // get the current time;

  // read the temperature
  readTemp();
}





void readTemp() {
  int value;
  temperature_read=kTC.readCelsius();
  
  /* ------------------------------------------------------------------
  */
}




void loop ()
{

  // read the temperature
  readTemp();
  


    Serial.print("Temperature is ");
    Serial.print(temperature_read);
    Serial.println("");

}



