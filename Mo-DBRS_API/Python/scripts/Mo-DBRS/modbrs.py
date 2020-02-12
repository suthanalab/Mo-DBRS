import socket

def modbrs_initialize(ip_address, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip_address, port))

def modbrs_send_magnet(modbrs_client):
    modbrs_client.send(b'm')

def modbrs_send_store(modbrs_client):
    modbrs_client.send(b'r')

def modbrs_send_stim(modbrs_client):
    modbrs_client.send(b's')

def modbrs_send_mark(modbrs_client):
    modbrs_client.send(b't')

def modbrs_send_external_magnet(modbrs_client):
    modbrs_client.send(b'd')

def modbrs_restart(modbrs_client):
    modbrs_client.send(b'y')

def modbrs_close(modbrs_client):
    modbrs_client.send(b'u')
    modbrs_client.close()
