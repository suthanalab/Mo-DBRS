function [] = send_trigger(socket, notification)
%SEND_TRIGGER Summary of this function goes here
%   Detailed explanation goes here
topic = notification('topic');
payload = dumpmsgpack(notification);
socket.send(uint8(topic), 2);
socket.send(payload);
end

