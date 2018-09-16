void setup ()
{
  Serial.begin(9600);
  pinMode(6, OUTPUT); // output pin for OCR2B
  pinMode(5,INPUT);
  pinMode(4,INPUT);
  pinMode(A1,INPUT); // pot read
//  TCCR0A = _BV(COM0A1) | _BV(COM0B1) | _BV(WGM01) | _BV(WGM00); 
//  TCCR0B = _BV(CS00); 
//  //analogWrite(5,int(0.3*255));  
//  // Set up the 250KHz output
//  TCCR2A = _BV(COM2A1) | _BV(COM2B1) | _BV(WGM21) | _BV(WGM20);
//  TCCR2B = _BV(WGM22) | _BV(CS20);
//  OCR2A = 63;
//  OCR2B = int(0.5*63);
//  TCCR2B = TCCR2B & B11111000 | B00000001;    // pin 3 and 11 PWM frequency of 31372.55 Hz
  TCCR0B=TCCR0B & B11111000 | B00000001;
//  analogWrite(6,225);
  
//  analogWrite(6,100);
  //digitalWrite(3,HIGH);
}

void loop ()
{
  int mosfetSwitch, usePot, potVal, value;
  float T;

  /*mosfetSwitch=digitalRead(4);
  if(mosfetSwitch==LOW) {
    analogWrite(6,0);
  } else {
    usePot=digitalRead(5);
    
    if(usePot == LOW){
      analogWrite(6,200);
    } else {
      potVal=analogRead(A1);
      potVal=map(potVal,0,1023,0,235);
      potVal=min(potVal,235);
      analogWrite(6,potVal);
      //Serial.println(potVal);
    }
  }
*/
  analogWrite(6,200);

  // ad8495 TC:
  value=analogRead(A0);
  delay(250);

  //T=(float(value)/1023.*4.64-2.43)/5.e-3;
  T=(float(value)/1023.*5)*203.5837-508.7424;
//  T=(float(value)/1023.*5.-1.25)/5.e-3;
//  T=(float(value)/1023.*3.293-1.25)/0.003293;
  Serial.print("Temperature is ");
  Serial.print(T);
  Serial.print(" ");
  Serial.print(value);
  Serial.println("");

  // here you can set the duty cycle by writing values between 0 and 160 to 
  // OCR2B
}


