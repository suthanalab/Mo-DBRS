function [pupil] = pupil_initialize(IP,PORT)
%PUPIL_INITIALIZE Summary of this function goes here
%   Detailed explanation goes here

javaclasspath('./jeromq-0.5.2-SNAPSHOT.jar')

import org.zeromq.*

endpoint =  strcat('tcp://', IP, ':', PORT);
% Setup zmq context and remote helper
context = ZContext();
pupil = context.createSocket(SocketType.REQ);
fprintf('Connecting to %s\n', endpoint);
pupil.connect(endpoint);
pause(1.0);
send_notification(pupil, containers.Map({'subject', 'name'}, {'start_plugin', 'Annotation_Capture'}))
result =pupil.recv(0);
fprintf('Annotation Notification received: %s\n', char(result));

end

