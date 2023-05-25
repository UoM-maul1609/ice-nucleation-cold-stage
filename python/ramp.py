from datetime import datetime
from datetime import timedelta
from smbus2 import SMBus
import struct
import time
import numpy as np
import os


bus = SMBus(1) #
arduinoAddress = 0x04

# interval to send setpoint to Arduino
interval = float(1000.)
command = 20
test = 30
temperature_init=5. # cool to 5 degrees before starting ramp
time_init=30. # take 30 seconds to get to 5 degrees

video1=2 # 0 no show; 1 show; 2 show and record

"""
    time into the ramp
"""
def millis():
    dt = datetime.now()-start_time
    ms = (dt.days*24*60*60 + dt.seconds)*1000+dt.microseconds / 1000.0  
    return float(ms)




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
        open file
    """
    
    filename1=start_time.strftime('%Y%m%d-%H%M%S')
    fp = open('../../output/' + filename1 +'.txt','w')
    
    fp.write("{:f}".format(gradient) + " " \
                +"{:f}".format(seconds_until_ramp_finished) + " "\
                +"{:f}".format(seconds_until_end) + "\n")
    fp.write("time set-point t_instant\n")
    fp.close()
    
    """
        record video
    """
    
    if video1==2:
            returned=os.system("raspivid -o ../../output/"  + \
                filename1 + ".h264 --preview 50,50,300,200  -fps 5 -drc high -t " \
                        + str(round((seconds_until_end+1)*1000,0)) + "&")
    elif video1==1:
        returned=os.system("raspivid --preview 50,50,500,250 -fps 5 -drc high -t " \
                        + str(round((seconds_until_end+1)*1000,0)) + "&")
    
    """
        loop over indefinitely - well, until we break out of the loop 
    """
    i=1
    while True:
        currentmillis = millis()
        #if(currentmillis  >= ((prevmillis % interval)*interval+interval)):
        if(currentmillis  - prevmillis >= (interval-0.5)):
                try:
                
                    # for first time_init seconds set the temperature to temperature_init
                    if(currentmillis <= time_init*1000):
                        temperature=temperature_init
                    elif((currentmillis > time_init*1000) and 
                        (currentmillis <= seconds_until_ramp_finished*1000)):
                        temperature = temperature_init+gradient*(currentmillis/1000.-time_init)
                    elif((currentmillis > seconds_until_ramp_finished*1000) and
                        (currentmillis <= seconds_until_end*1000)):
                        temperature = arr[1,0]
                    elif((currentmillis > seconds_until_end*1000)):
                        temperature = 100.
        

                    # pack float and 2 bytes into a byte array
                    bytescommand = struct.pack('<1fbb',round(temperature,2),int(command),int(test)) 
                    # write this data
                    fn=np.nan
                    while np.isnan(fn) or np.abs(fn-temperature)> 10.:
                            bus.write_block_data(arduinoAddress,1,list(bytescommand))
                            time.sleep(0.01)
                            data = get_data()
                            fn=get_float(data,0)
                            if currentmillis > seconds_until_end*1000:
                                break
                                
                    print(format(currentmillis/1000.,"0.2f"),format(temperature,"0.2f"),format(fn,"0.2f"))

                    """
                       write to a file
                    """
                        
                    fp=open("../../output/" + filename1 +".txt","a")
                    fp.write("{:f}".format(currentmillis/1000.) + " " \
                                +"{:f}".format(temperature) + " " \
                                +"{:f}".format(fn) + "\n")
                    fp.close()
                        
                    prevmillis = prevmillis+interval
                        
                    if((currentmillis >= seconds_until_end*1000)):
                         break
                except:
                    continue
    

