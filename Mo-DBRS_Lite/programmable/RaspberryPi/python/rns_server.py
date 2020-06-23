#!/usr/bin/python
import socket
import time
import timeit
import sys
import signal
import datetime
import multiprocessing
import RPi.GPIO as GPIO
PUPIL_LED_GPIO          = 40
EXTERNAL_MAGNET_GPIO    = 38
pupil_led               = 0
external_magnet         = 0

EXTERNAL_MAGNET_MSG = b'm'
RESTART_MSG = b'u'
CLOSE_MSG = b'q'


# Define GPIOs
GPIO.setmode(GPIO.BOARD)
if external_magnet is not 0:
    GPIO.setup(EXTERNAL_MAGNET_GPIO, GPIO.OUT)
if pupil_led is not 0:
    GPIO.setup(PUPIL_LED_GPIO, GPIO.OUT)

def TimestampWriter(dest_filename, some_queue, some_stop_token):
    with open(dest_filename, 'a+') as dest_file:
        while True:
            line = some_queue.get()
            if line == some_stop_token:
                return
            dest_file.write(line)
def PupilLED(mark_trigger, pupil_led, TimestampQueue):
    while(1):
        if pupil_led is not 0:
            magnet_trigger.wait()
            GPIO.output(PUPIL_LED_GPIO, GPIO.HIGH)
            time.sleep(0.05)
            GPIO.output(PUPIL_LED_GPIO, GPIO.LOW)
            timestamp = datetime.datetime.now()
            msg = 'Pupil LED: ' + str(timestamp)
            TimestampQueue.put(msg)
            magnet_trigger.clear()

def SendExternalMagnet(magnet_trigger, external_magnet, TimestampQueue):
    while(1):
        if external_magnet is not 0:
            magnet_trigger.wait()
            GPIO.output(EXTERNAL_MAGNET_GPIO, GPIO.LOW)
            time.sleep(0.550)
            GPIO.output(EXTERNAL_MAGNET_GPIO, GPIO.HIGH)
            timestamp = datetime.datetime.now()
            msg = 'External magnet: ' + str(timestamp)
            TimestampQueue.put(msg)
            magnet_trigger.clear()

STOP_TOKEN="STOP"
TimestampQueue = multiprocessing.Queue()
TimestampWriteProcess = multiprocessing.Process(target = TimestampWriter, args=("./rp_timestamps/stamps_" + str(datetime.datetime.now()) + ".log", TimestampQueue, STOP_TOKEN))
TimestampWriteProcess.start()

init = 0


# If marking event requires running several routines 'simultaneously' we create separate processes for each

magnet_trigger = multiprocessing.Event()

if external_magnet is not 0:
    MagnetProcess = multiprocessing.Process(target=SendExternalMagnet, args=(magnet_trigger, external_magnet, TimestampQueue))
    MagnetProcess.start()

if pupil_led is not 0:
    PupilLEDProcess = multiprocessing.Process(target=PupilLED, args=(magnet_trigger, pupil_led, TimestampQueue))
    PupilLEDProcess.start()

# ...


backlog = 1
size = 1

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
timestamp = datetime.datetime.now()
msg = 'Server created: ' + str(timestamp)
TimestampQueue.put(msg)
print(msg)

s.bind(('192.168.0.2', 50000))
s.listen(backlog)
timestamp = datetime.datetime.now()
msg = 'Server listening: ' + str(timestamp)
TimestampQueue.put(msg)
print(msg)


client, address = s.accept()
timestamp = datetime.datetime.now()
msg = 'Client connected: ' + str(timestamp)
TimestampQueue.put(msg)
print(msg)




def signal_handler(sig, frame):
        timestamp = datetime.datetime.now()
        msg = 'Server closing: ' + str(timestamp)
        TimestampQueue.put(msg)
        print(msg)
        if controller is not 0:
            RNSProcess.terminate()
            controller.close()

        if pupil_led is not 0:
            PupilLEDProcess.terminate()

        TimestampQueue.put(STOP_TOKEN)
        TimestampWriter.terminate()
        client.close()
        s.close()
        sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

try:
    while 1:
        if init == 1:
            s.listen(backlog)
            print('Server is running...')
            client, address = s.accept()

        init = 1

        try:
            while 1:
                data = client.recv(size)
                print('RECEIVED DATA' + str(data))
                if not data:
                    timestamp = datetime.datetime.now()
                    msg = 'Client closed: ' + str(timestamp)
                    TimestampQueue.put(msg)
                    print(msg)
                    client.close()
                    break
                print(data)

                if data == EXTERNAL_MAGNET_MSG:
                    magnet_trigger.set()
                    timestamp = datetime.datetime.now()
                    msg = 'External magnet: ' + str(timestamp)
                    TimestampQueue.put(msg)
                    print(msg)
                elif data == RESTART_MSG:
                    timestamp = datetime.datetime.now()
                    msg = 'Server restart: ' + str(timestamp)
                    TimestampQueue.put(msg)
                    print(msg)
                    client.close()
                    break
                elif data == CLOSE_MSG:
                    timestamp = datetime.datetime.now()
                    msg = 'Server closing: ' + str(timestamp)
                    TimestampQueue.put(msg)
                    print(msg)
                    controller.close()
                    client.close()
                    s.close()
                    sys.exit(0)

        except:
                timestamp = datetime.datetime.now()
                msg = 'Server restart: ' + str(timestamp)
                TimestampQueue.put(msg)
                print(msg)
                client.close()
                break
except:
        timestamp = datetime.datetime.now()
        msg = 'Server closing: ' + str(timestamp)
        TimestampQueue.put(msg)
        print(msg)
        controller.close()
        client.close()
        s.close()
        sys.exit(0)
