import struct
import smbus
import time
import sys

# for Rpi v 1 use "bus = smbus.SMBus(0)"
bus = smbus.SMBus(1)

# This is the address we setup in the Arduino program
address = 0x04

def get_data():
   return bus.read_i2c_block_data(address, 0,8);

def get_float(data, index):
   bytes1 = data[4*index:(index+1)*4]
#   return struct.unpack('f', "".join(map(chr, bytes1)))[0]
   return struct.unpack('f', bytes(bytes1))[0]

def main():
	i=1
	while True:
		try:
			data = get_data()
			print(get_float(data,0))
			print(get_float(data,1))
			bus.write_byte(address, i)
			i+=1
		except:
	 		continue
		time.sleep(1);

if __name__ == '__main__':
	try:
		main()
	except KeyboardInterrupt:
		print ('Interrupted')
		bus.write_byte(address, 0)
		time.sleep(1)
		sys.exit(0)
