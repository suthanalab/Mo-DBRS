function [] = pupil_send_mark(pupil)
%PUPIL_SEND_MARK Summary of this function goes here
%   Detailed explanation goes here
send_trigger(pupil, containers.Map({'topic', 'label', 'timestamp' 'duration'}, {'annotation', 'Custom Mark', tic, 0}))
result =pupil.recv(0);
fprintf('Annotation Notification received: %s\n', char(result));

end

