from datetime import datetime
from datetime import timedelta
from smbus import SMBus
import struct
import time

start_time = datetime.now()
address=0x04
def millis():
    dt = datetime.now()-start_time
    ms = (dt.days*24*60*60 + dt.seconds)*1000+dt.microseconds / 1000.0  
    return ms

#inicia escravo i2c
bus = SMBus(1) #
arduinoAddress = 0x04

#intervalo de execu
interval = 150

temperatura = 10.2
vazao = 5.3
command = 20
teste = 30


def get_data():
   return bus.read_i2c_block_data(address, 0,8);

def get_float(data, index):
   bytes1 = data[4*index:(index+1)*4]
#   return struct.unpack('f', "".join(map(chr, bytes1)))[0]
   return struct.unpack('f', bytes(bytes1))[0]



if __name__ == '__main__':
    prevmillis = millis()

    while True:
        currentmillis = millis()
        if(currentmillis - prevmillis > interval):
		#write
                try:
                        prevmillis = currentmillis
                        bytescommand = struct.pack('=2fbb',temperatura,vazao,command,teste) #para evitar o ajuste
                        bus.write_block_data(arduinoAddress,1,list(bytescommand))
                        print(list(bytescommand))
                        data = get_data()
                        print(get_float(data,0))
                        print(get_float(data,1))

                except:
                        continue
                        
                #request

                #block = bus.read_i2c_block_data(arduinoAddress,2,27)
                #output = struct.unpack('6f3b',bytes(block))
                #print(output)
                #print(datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])



