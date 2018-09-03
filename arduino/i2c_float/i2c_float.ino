#include <Wire.h>

#define SLAVE_ADDRESS 0x04

#define FLOATS_SENT 2

float temperature = 10.5;
float luminosity = 5.2;
float data[FLOATS_SENT];

byte number;

void setup() {
    //pinMode(13, OUTPUT);
    Serial.begin(9600);
    
    data[0] = temperature;
    data[1] = luminosity;
    
    // initialize i2c as slave
    Wire.begin(SLAVE_ADDRESS);

    // define callbacks for i2c communication
    Wire.onReceive(receiveData);
    Wire.onRequest(sendData);
}

void loop() {
    delay(100);
    Serial.println(number);
}

void sendData(){
  Wire.write((byte*) &data[0], FLOATS_SENT*sizeof(float));
}

void receiveData(int byteCount) {
//  Serial.print("receiveData");

  while (Wire.available()) {
    number = Wire.read();
//    Serial.print("data received: ");
//    Serial.println(number);
  }
}

