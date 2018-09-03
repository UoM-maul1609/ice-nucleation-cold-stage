import RPi.GPIO as gpio
import smbus
import time
import sys
import struct

bus = smbus.SMBus(1)
address = 0x04

def main():
	gpio.setmode(gpio.BCM)
        gpio.setup(17,gpio.OUT)
	status = False
	while 1:
		try:
			gpio.output(17,status)	
			status = not status
			bus.write_byte(address, 1 if status else 0)
			print 'Arduino answer to RPi:', bus.read_byte(address)
		except:
			continue
		time.sleep(1)
def get_data():
   return bus.read_i2c_block_data(address,0x00,4);

def get_float(data, index):
   bytes = data[4*index:(index+1)*4]
   return struct.unpack('f', "".join(map(chr, bytes)))[0]

if __name__ == '__main__':
	try:
		main()
	except KeyboardInterrupt:
		print 'Interrupted'
		gpio.cleanup()
		sys.exit(0)
