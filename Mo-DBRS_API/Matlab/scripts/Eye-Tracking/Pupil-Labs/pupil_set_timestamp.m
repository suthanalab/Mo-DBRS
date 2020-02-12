function pupil_set_timestamp(socket,timestamp)
%PUPIL_SET_TIMESTAMP Summary of this function goes here
%   Detailed explanation goes here
    
    %timestamp_str = strcat('T ', timestamp);
    %socket.send(uint8(timestamp_str));
    socket.send(uint8('T 0.0'));
    result = socket.recv(0);
    fprintf('%s\n', char(result));
end

