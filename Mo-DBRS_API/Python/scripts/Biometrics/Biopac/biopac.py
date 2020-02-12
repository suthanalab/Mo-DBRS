import serial
import time

def biopac_initialize(dev_port):
    serial_port = serial.Serial(dev_port, baudrate=115200, bytesize=8, stopbits=1, parity='N')
    return serial_port

def biopac_send_pulse(biopac_serial, pulse_duration):
    biopac_serial.write(b'01')
    time.sleep(pulse_duration)
    biopac_serial.write(b'00')

