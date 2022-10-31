from datetime import datetime
from datetime import timedelta
from smbus2 import SMBus
import struct
import time
import numpy as np
import os


bus = SMBus(1) #
arduinoAddress = 0x04


command = 20
test = 30



"""
    get one floating point variable (4 bytes) from the Arduino
"""
def get_data():
   data=bus.read_i2c_block_data(arduinoAddress, 0,8);
   #print(data)
   return data;





"""
    convert the bytes to a floating point (top line is python2, bottom python3)
"""
def get_float(data, index):
   bytes1=data[0:4]

   #print (bytes1)
   return float(struct.unpack("<f", bytes(bytes1))[0])



    
    
    
    

""" 
    code to switch off the peltier by setting set point to 100 degC
"""
if __name__ == '__main__':

        temperature=100.
        # write every "interval"
        
        # pack float and 2 bytes into a byte array
        #bytescommand = struct.pack('<1fbb',round(temperature,2),int(command),int(test)) 
        # write this data
        fn=np.nan
        while np.isnan(fn):
           try:
              #bus.write_block_data(arduinoAddress,1,list(bytescommand))
              time.sleep(0.1)
              data = get_data()
              time.sleep(0.1)
              data = get_data()
              fn=get_float(data,0)
           except:
              pass
        
        print("Peltier value " + format(fn,"0.2f"))            


