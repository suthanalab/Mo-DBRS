% pupil_remote_control.m

% (*)~----------------------------------------------------------------------------------
%  Pupil Helpers
%  Copyright (C) 2012-2016  Pupil Labs
% 
%  Distributed under the terms of the GNU Lesser General Public License (LGPL v3.0).
%  License details are in the file license.txt, distributed as part of this software.
% ----------------------------------------------------------------------------------~(*)
javaclasspath('/Users/urostopalovic/Downloads/jeromq-master/target/jeromq-0.5.2-SNAPSHOT.jar')
import org.zeromq.*

% Pupil Remote address
endpoint =  'tcp://127.0.0.1:63704';

% Setup zmq context and remote helper
context = ZContext();
socket = context.createSocket(SocketType.REQ);

% set timeout to 1000ms in order to not get stuck in a blocking
% mex-call if server is not reachable, see
% http://api.zeromq.org/4-0:zmq-setsockopt#toc19
%socket.setsockopt(socket, 'ZMQ_RCVTIMEO', 1000);

fprintf('Connecting to %s\n', endpoint);
%zmq.core.connect(socket, endpoint);
socket.connect(endpoint);

tic; % Measure round trip delay
socket.send(uint8('t'));
result = socket.recv(1);
fprintf('%s\n', char(result));
fprintf('Round trip command delay: %s\n', toc);

% set current Pupil time to 0.0
% socket.send(uint8('T 0.0'));
% result = socket.recv(1);
% fprintf('%s\n', char(result));

% start recording
pause(1.0);
socket.send(uint8('R'), 0);
result = socket.recv(0);
fprintf('Recording should start: %s\n', char(result));

pause(5.0);
socket.send(uint8('r'), 0);
result = socket.recv(0);
fprintf('Recording stopped: %s\n', char(result));

% test notification, note that you need to listen on the IPC to receive notifications!
send_notification(socket, containers.Map({'subject'}, {'calibration.should_start'}))
result =socket.recv(0);
fprintf('Notification received: %s\n', char(result));
% 
% send_notification(socket, containers.Map({'subject'}, {'calibration.should_stop'}))
% result = socket.recv(1);
% fprintf('Notification received: %s\n', char(result));

socket.disconnect(endpoint);
socket.close();

context.close();
% socket.ctx_shutdown(context);
% socket.ctx_term(context);