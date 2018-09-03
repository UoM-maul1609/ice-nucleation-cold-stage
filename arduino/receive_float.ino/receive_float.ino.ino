#include <Wire.h>

#define FLOATS_SENT 2

float temperature = 10.5;
float luminosity = 5.2;
float data_s[FLOATS_SENT];


byte data[12];
int command;

typedef struct processData{
  float temp1;
  float temp2;
  float temp3;
  float temp4;
  float vazao_quente;
  float vazao_fria;
  byte pump_speed;
  //bool  pump_status;
  byte bstatus;
  //bool heater_status;
  byte chksum;
};

typedef union I2C_Send{
  processData data;
  byte I2C_packet[sizeof(processData)];
};

//declaracao da variável de envio
I2C_Send send_info;


void parseValues(byte data[]){
  union float_tag{
    byte b[4];
    float fval;
  }ft;

  ft.b[0] =data[1];
  ft.b[1] = data[2];
  ft.b[2] = data[3];
  ft.b[3] = data[4];

  Serial.println(ft.fval);
}


void setup()
{
  Wire.begin(0x04);                // join i2c bus with address #4
  data_s[0] = temperature;
  data_s[1] = luminosity;
  Wire.onReceive(receiveEvent); // register event
  //Wire.onRequest(requestEvent);
  Wire.onRequest(sendData);
  Serial.begin(9600);           // start serial for output
  //setrnddata();
}

void loop()
{
  delay(100);
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany)
{
  command = Wire.read();
  if (command==1){
    int i=0;
    while(1 <= Wire.available()) // loop through all but the last
    {
      data[i] = Wire.read(); // receive byte as a character
      i = i+1;
    }
    Serial.println(i);
    parseValues(data);
  }
}

void sendData(){
  Wire.write((byte*) &data_s[0], FLOATS_SENT*sizeof(float));
}

