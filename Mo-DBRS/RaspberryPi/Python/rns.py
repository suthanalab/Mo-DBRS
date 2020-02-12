#!/usr/bin/python

import serial
import time
import sys

PORT = "/dev/ttyACM0"

SSR_MSG = b'r'
MAG_MSG = b'm'
STIM_MSG = b's'
MARK_MSG = b't'

START_MSG = b'e'
STOP_MSG = b'x'

SSR_RECEIPT = b'SSR trigger from Serial'
MAG_RECEIPT = b'Magnet trigger'
MARK_RECEIPT = b'Mark trigger'
STIM_RECEIPT = b'Stimulation trigger'
START_RECEIPT = b'Start trigger'
STOP_RECEIPT = b'Stop trigger'


class InvalidReceiptError(Exception) :
    pass

class ResearchController() :
    def __init__(self, rns_device) :

        BAUD = 9600
        if rns_device == '300M':
            BAUD = 9600
        elif rns_device == '320':
            BAUD = 57600
        else:
            raise ValueError('RNS Device model incorrect')

        self.pgmacc = serial.Serial(port = PORT, baudrate =  BAUD, timeout = 1, bytesize = serial.EIGHTBITS, parity = serial.PARITY_NONE, stopbits = serial.STOPBITS_ONE)

        time.sleep(1)
        n = 5
        while(n>0):
            response = self.pgmacc.readline()
            print(response)
            n = n - 1

    def close(self):

        self.pgmacc.close()

    def _send_message_check_reply_(self, message, receipt = None) :
        self.pgmacc.write(message)
        self.pgmacc.flush()
#        response = self.pgmacc.readline()
#        print(response)

    def send_ssr(self):
        self._send_message_check_reply_(SSR_MSG, SSR_RECEIPT)

    def send_magnet(self) :
        self._send_message_check_reply_(MAG_MSG, MAG_RECEIPT)

    def send_stim(self):
        self._send_message_check_reply_(STIM_MSG, STIM_RECEIPT)

    def send_mark(self):
        self._send_message_check_reply_(MARK_MSG, MARK_RECEIPT)

    def send_start(self):
        self._send_message_check_reply_(START_MSG, START_RECEIPT)

    def send_stop(self):
        self._send_message_check_reply_(STOP_MSG, STOP_RECEIPT)


