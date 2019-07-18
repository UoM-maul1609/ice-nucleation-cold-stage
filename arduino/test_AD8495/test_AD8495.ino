




unsigned long  starttime,newmillis; // variable to determine when Serial IO occurs

double temperature_read = 0.0, Setpoint=100.0, Output; // set point initially high, so current off
/* ------------------------------------------------------------------
*/

void setup ()
{
  //pinMode(A0,INPUT);
  Serial.begin(9600);
  
  starttime = millis();   // get the current time;

  // read the temperature
  readTemp();
}





void readTemp() {
  int value;
   value=analogRead(A0);
   Serial.println(value);
  temperature_read=(float(value)/1023.*5.-1.25)/5.e-3;
 //temperature_read=(float(value)/1023.*5.)*203.5837-508.7424;
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



