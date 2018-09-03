from datetime import datetime
from datetime import timedelta
from smbus import SMBus
import struct
import time
import numpy as np


bus = SMBus(1) #
arduinoAddress = 0x04

# interval to send setpoint to Arduino
interval = 1000
command = 20
test = 30
temperature_init=5. # cool to 5 degrees before starting ramp
time_init=30. # take 30 seconds to get to 5 degrees

"""
    time into the ramp
"""
def millis():
    dt = datetime.now()-start_time
    ms = (dt.days*24*60*60 + dt.seconds)*1000+dt.microseconds / 1000.0  
    return ms




"""
    get one floating point variable (4 bytes) from the Arduino
"""
def get_data():
   return bus.read_i2c_block_data(arduinoAddress, 0,4);





"""
    convert the bytes to a floating point (top line is python2, bottom python3)
"""
def get_float(data, index):
   bytes1 = data[4*index:(index+1)*4]
#   return struct.unpack('f', "".join(map(chr, bytes1)))[0]
   return struct.unpack('f', bytes(bytes1))[0]





"""
    read in the temperature ramp from the file
"""
def readRamp():
    arr=np.zeros((3,1))
    
    fp = open('ramp.txt')
    dat=fp.readlines()
    fp.close()
    for i in range(3):
        arr[i]=float(dat[i])
    print(arr)
    return arr
    
    
    
    

""" 
    code to read in a temperature ramp and send the set point at regular 
    intervals to the Arduino.
"""
if __name__ == '__main__':

    arr=readRamp() # read the ramp file
    gradient=-arr[0,0] / 60.
    seconds_until_ramp_finished=time_init+(arr[1,0]-temperature_init) / gradient
    seconds_until_end=seconds_until_ramp_finished+arr[2,0]
    
    
    start_time = datetime.now()
    prevmillis = millis()
    
    print(gradient,seconds_until_ramp_finished,seconds_until_end)
    

    """
        loop over indefinitely - well, until we break out of the loop 
    """
    while True:
        currentmillis = millis()
        
        # for first time_init seconds set the temperature to temperature_init
        if(currentmillis <= time_init*1000):
            temperature=temperature_init
        elif((currentmillis > time_init*1000) and 
            (currentmillis <= seconds_until_ramp_finished*1000)):
            temperature = temperature_init+gradient*(currentmillis/1000.-time_init)
        elif((currentmillis > seconds_until_ramp_finished*1000) and
            (currentmillis <= seconds_until_end*1000)):
            temperature = arr[1]
        elif((currentmillis > seconds_until_end*1000)):
            temperature = 100.
        
        
        
        # write every "interval"
        if(currentmillis - prevmillis > interval):
                try:
                        prevmillis = currentmillis
                        
                        # pack float and 2 bytes into a byte array
                        bytescommand = struct.pack('1fbb',temperature,command,test) 
                        
                        # write this data
                        bus.write_block_data(arduinoAddress,1,list(bytescommand))
                        #print(list(bytescommand))
                        
                        # get the temperature from the arduino
                        data = get_data()
                        print(currentmillis/1000.,temperature,get_float(data,0))
                        #print(get_float(data,1))
                        if((currentmillis > seconds_until_end*1000)):
                            break
                except:
                        continue
    
