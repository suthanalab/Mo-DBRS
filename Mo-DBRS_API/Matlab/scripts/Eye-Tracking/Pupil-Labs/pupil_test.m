
pupil = pupil_initialize('127.0.0.1', '50020');
pause(1);
pupil_set_timestamp(pupil);
pause(1);
pupil_start_recording(pupil);
 pause(5);
 pupil_send_mark(pupil);
 pause(3);
 pupil_send_mark(pupil);
pause(5);
pupil_stop_recording(pupil);
