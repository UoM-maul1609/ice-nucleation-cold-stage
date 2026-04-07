from smbus2 import SMBus
from datetime import datetime
import subprocess

I2C_BUS = 3
RTC_ADDR = 0x68


def bcd_to_dec(x):
    return ((x >> 4) * 10) + (x & 0x0F)


def read_ds3231(bus, addr):
    # DS3231 time registers start at 0x00
    data = bus.read_i2c_block_data(addr, 0x00, 7)

    seconds = bcd_to_dec(data[0] & 0x7F)
    minutes = bcd_to_dec(data[1] & 0x7F)
    hours = bcd_to_dec(data[2] & 0x3F)   # assumes 24-hour mode
    day = bcd_to_dec(data[4] & 0x3F)
    month = bcd_to_dec(data[5] & 0x1F)
    year = 2000 + bcd_to_dec(data[6])

    return datetime(year, month, day, hours, minutes, seconds)


def main():
    with SMBus(I2C_BUS) as bus:
        dt = read_ds3231(bus, RTC_ADDR)

    date_str = dt.strftime('%Y-%m-%d %H:%M:%S')
    print("RTC time:", date_str)

    # Set system time
    subprocess.check_call(["sudo", "date", "-s", date_str])


if __name__ == "__main__":
    main()

