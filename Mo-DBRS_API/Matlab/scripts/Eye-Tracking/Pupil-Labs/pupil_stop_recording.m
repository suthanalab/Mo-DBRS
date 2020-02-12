function pupil_stop_recording(socket)
%PUPIL_STOP_RECORDING Summary of this function goes here
%   Detailed explanation goes here
socket.send(uint8('r'), 0);
result = socket.recv(0);
fprintf('Recording stopped: %s\n', char(result));
end

