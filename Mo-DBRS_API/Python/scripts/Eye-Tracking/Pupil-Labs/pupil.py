import zmq
from time import sleep, time
import msgpack as serializer


label = "pupil_annotation"
duration = 0.

def new_trigger(label, duration):
    return {
        "topic": "annotation",
        "label": label,
        "timestamp": time_fn(),
        "duration": duration,
    }
def notify(notification, pupil_client):
    """Sends ``notification`` to Pupil Remote"""
    topic = "notify." + notification["subject"]
    payload = serializer.dumps(notification, use_bin_type=True)
    pupil_client.send_string(topic, flags=zmq.SNDMORE)
    pupil_client.send(payload)
    return pupil_client.recv_string()

def send_trigger(trigger, pupil_client_pub):
    payload = serializer.dumps(trigger, use_bin_type=True)
    pupil_client_pub.send_string(trigger["topic"], flags=zmq.SNDMORE)
    print(trigger["topic"])
    print(payload)
    pupil_client_pub.send(payload)

def pupil_initialize(ip_address, port):
    ctx = zmq.Context()
    socket = zmq.Socket(ctx, zmq. REQ)
    socket.connect('tcp://' + str(ip_address) + ':' + str(port))

    socket.send_string("PUB_PORT")
    pub_port = socket.recv_string()
    pub_socket = zmq.Socket(ctx, zmq.PUB)
    pub_socket.connect('tcp://' + str(ip_address) + ':{}'.format(pub_port))

    return socket

def pupil_start_recording(pupil_client):
    notify({"subject": "start_plugin", "name": "Annotation_Capture", "args": {}}, pupil_client)
    time_fn = time
    pupil_client.send_string('T {}'.format(time_fn()))
    print(pupil_client.recv_string())
    pupil_client.send_string('R')
    print(pupil_client.recv_string())

def pupil_stop_recording(pupil_client):
    pupil_client.send_string('r')
    print(pupil_client.recv_string())

def pupil_start_calibration(pupil_client):
    pupil_client.send_string('C')
    print(pupil_client.recv_string())

def pupil_start_calibration(pupil_client):
    pupil_client.send_string('c')
    print(pupil_client.recv_string())

def pupil_reset_time(pupil_client):
    pupil_client.send_string('T 0.0')
    print(pupil_client.recv_string())

def pupil_send_annotation(pupil_client_pub):
    minimal_trigger = new_trigger(label, duration)
    send_trigger(minimal_trigger, pupil_client_pub)
