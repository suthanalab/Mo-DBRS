import biopac
import modbrs
import pupil
import time

modbrs_ip = 192.168.0.2
modbrs_port = 50000

pupil_ip = 192.168.0.10
pupil_port = 50000

biopac_port = '/dev/USB...'

modbrs_client = modbrs_initialize(modbrs_ip, modbrs_port)
pupil_client, pupil_client_pub = pupil_initialize(pupil_ip, pupil_port)
biopac_client = biopac_initialize(biopac_port)

pupil_start_recording(pupil_client)

time.sleep(5)


modbrs_send_mark(modbrs_client)
biopac_send_pulse(biopac_client, 0.4)
pupil_send_annotation(pupil_client_pub)

time.sleep(5)

pupil_stop_recording(pupil_client)
pupil_client.close()
pupil_cilent_pub.close()
modbrs_client.close()
biopac_client.close()

