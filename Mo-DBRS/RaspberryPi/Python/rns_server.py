#!/usr/bin/python
import socket
import time
from rns import ResearchController
import timeit
import sys
import signal
import datetime

PUPIL_LED_GPIO          = 38
EXTERNAL_MAGNET_GPIO    = 40
pupil_led               = 0
external_magnet_led     = 0

# Define GPIOs
GPIO.setmode(GPIO.BOARD)
if external_magnet_led is not 0:
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

def RNSMark(mark_trigger, controller, msg):
    while(1):
        if controller is not 0:
            mark_trigger.wait()
            controller.send_mark()
            timestamp = datetime.datetime.now()
            msg = 'RNS Mark: ' + str(timestamp)
            TimestampQueue.put(msg)
            print(msg)
            mark_trigger.clear()

def PupilLED(mark_trigger, pupil_led):
    while(1):
        if pupil_led is not 0:
            mark_trigger.wait()
            GPIO.output(PUPIL_LED_GPIO, GPIO.HIGH)
            time.sleep(0.05)
            GPIO.output(PUPIL_LED_GPIO, GPIO.LOW)
            mark_trigger.clear()

def SendExternalMagnet():
    if external_magnet_led is not 0:
            GPIO.output(EXTERNAL_MAGNET_GPIO, GPIO.LOW)
            time.sleep(0.550)
            GPIO.output(EXTERNAL_MAGNET_GPIO, GPIO.HIGH)

STOP_TOKEN="STOP"
TimestampQueue = multiprocessing.Queue()
TimestampWriteProcess = multiprocessing.Process(target = TimestampWriter, args=("./rp_timestamps/stamps_" + datetime.datetime.now() + ".log", TimestampQueue, STOP_TOKEN))
TimestampWriteProcess.start()

init = 0
controller  = 0

rns_device = '300M' #or '320'

# If Research Accessories are connected open serial port for sending marks.
#
try:
    controller = ResearchController(rns_device)
except:
    print('\nCheck USB connection between RPi and Arduino!\n')
    print('\nContinuing without RNS!\n')


# If marking event requires running several routines 'simultaneously' we create separate processes for each

mark_trigger = multiprocessing.Event()

if controller is not 0:
    RNSProcess = multiprocessing.Process(target=RNSMark, args=(mark_trigger,controller))#controller, msg))
    RNSProcess.start()

if pupil_led is not 0:
    PupilLEDProcess = multiprocessing.Process(target=PupilLED, args=(e,))
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

                if data == STORE_MSG:
                    controller.send_store()
                    timestamp = datetime.datetime.now()
                    msg = 'Store: ' + str(timestamp)
                    TimestampQueue.put(msg)
                    print(msg)
                elif data == MARK_MSG:
                    mark_trigger.set()
                elif data == MAGNET_MSG:
                    controller.send_magnet()
                    timestamp = datetime.datetime.now()
                    msg = 'Magnet: ' + str(timestamp)
                    TimestampQueue.put(msg)
                    print(msg)
                elif data == STIM_MSG:
                    controller.send_stim()
                    timestamp = datetime.datetime.now()
                    msg = 'Stim: ' + str(timestamp)
                    TimestampQueue.put(msg)
                    print(msg)
                elif data == EXTERNAL_MAGNET_MSG:
                    SendExternalMagnet()
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
