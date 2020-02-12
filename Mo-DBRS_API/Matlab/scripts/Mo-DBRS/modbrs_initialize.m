function modbrs_socket = modbrs_initialize(ip_address, port)
    modbrs_socket = tcpclient(ip_address, port);
end

