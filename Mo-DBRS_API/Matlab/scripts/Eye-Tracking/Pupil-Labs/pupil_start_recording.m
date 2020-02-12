function pupil_start_recording(socket)
%PUPIL_START_RECORDING Summary of this function goes here
%   Detailed explanation goes here
socket.send(uint8('R'), 0);
result = socket.recv(0);
fprintf('Recording should start: %s\n', char(result));
end

