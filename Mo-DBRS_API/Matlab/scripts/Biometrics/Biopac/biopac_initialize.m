function [biopac_serial] = biopac_initialize(dev_port)

    serial_port = serial(dev_port);
    set(serial_port,'BaudRate',115200,'DataBits',8, 'StopBits', 1,'Parity', 'none');
    fopen(serial_port);
    biopac_serial = serial_port;
end

