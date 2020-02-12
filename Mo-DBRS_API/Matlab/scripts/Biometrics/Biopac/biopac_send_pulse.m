function biopac_send_pulse(biopac_serial, pulse_duration)
    default_duration = 0.4;
    if pulse_duration == 0
        pulse_duration = default_duration;
    end
    fprintf(biopac_serial, '01');
    pause(pulse_duration);
    fprintf(biopac_serial, '00');
end

