from smbus2 import SMBus
from datetime import datetime

I2C_BUS = 3
RTC_ADDR = 0x68


def dec_to_bcd(x):
    return ((x // 10) << 4) | (x % 10)


def main():
    now = datetime.utcnow()   # store UTC in RTC

    seconds = dec_to_bcd(now.second)
    minutes = dec_to_bcd(now.minute)
    hours = dec_to_bcd(now.hour)          # 24-hour mode
    day_of_week = dec_to_bcd(now.isoweekday())  # 1=Mon ... 7=Sun
    day = dec_to_bcd(now.day)
    month = dec_to_bcd(now.month)
    year = dec_to_bcd(now.year - 2000)

    data = [seconds, minutes, hours, day_of_week, day, month, year]

    with SMBus(I2C_BUS) as bus:
        bus.write_i2c_block_data(RTC_ADDR, 0x00, data)

    print("RTC set to UTC:", now.strftime('%Y-%m-%d %H:%M:%S'))


if __name__ == "__main__":
    main()
