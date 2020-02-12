function [ ] = send_notification( socket, notification )
%NOTIFY Use socket to send notification
%   Notifications are container.Map objects that contain
%   at least the key 'subject'.
topic = strcat('notify.', notification('subject'));
payload = dumpmsgpack(notification);
socket.send(uint8(topic), 2);
socket.send(payload);
end