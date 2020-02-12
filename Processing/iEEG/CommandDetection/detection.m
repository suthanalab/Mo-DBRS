test_data_mag = load('./RNSData0910/test_data_mag.mat');
test_data_real = load('./RNSData0910/test_data_real.mat');
test_data_mag = test_data_mag.data_mag;
test_data_real = test_data_real.data_real;

Fs = 250;
time_mag = 0:length(test_data_mag) - 1;
time_mag = time_mag / Fs;

time_real = 0 : length(test_data_real) - 1;
time_real = time_real / Fs;

offset = 8.7080;

time_real = time_real + offset;
format long g
fileID = fopen('./rp_timestamps/mark.txt','r');
marks = fscanf(fileID,'%f');
fileID = fopen('./rp_timestamps/mag_off.txt','r');
mag_off = fscanf(fileID,'%f');
fileID = fopen('./rp_timestamps/mag_on.txt','r');
mag_on = fscanf(fileID,'%f');
fileID = fopen('./rp_timestamps/pulse_off.txt','r');
pulse_off = fscanf(fileID,'%f');
fileID = fopen('./rp_timestamps/pulse_on.txt','r');
pulse_on = fscanf(fileID,'%f');
fileID = fopen('./rp_timestamps/ssr.txt','r');
ssr = fscanf(fileID,'%f');




mark_temp = [0 -1 -1 0 0 -1 -1 0 0 0 0 0 0 -1 -1 0];
mark_temp1 = [0 -1 -1 0 0 0 0 0 0  -1 -1 0];
mark_temp2 = [0 -1 -1 0 0 0 0 0 0 0 0 0 0  -1 -1 0];
mark_temp3 = [0 -1 -1 0 0 -1 -1 0];
mark_temp4 = [0 -1 -1 0 ];
[a,l] = xcorr(test_data_real, mark_temp);
a = a(length(test_data_real):end);
[a1,l1] = xcorr(test_data_real, mark_temp1);
[a2,l2] = xcorr(test_data_real, mark_temp2);
[a3,l3] = xcorr(test_data_real, mark_temp3);
[a4,l4] = xcorr(test_data_real, mark_temp4);
a1 = a1(length(test_data_real):end);
a2 = a2(length(test_data_real):end);
a3 = a3(length(test_data_real):end);
a4 = a4(length(test_data_real):end);

I = a > 0.9 * (max(abs(a)));
I1 = a1 > 0.9 * (max(abs(a1)));
I1 = logical([I1(5:end) zeros(1,4)]);
I2 = a2 > 0.9 * (max(abs(a2)));
I3 = a3 > 0.9 * (max(abs(a3)));
I4 = a4 > 0.9 * (max(abs(a4)));

J = logical([0 I(1:end-1)]);

marks_real_time = time_real(J);
marks = marks(1:5)';



first_mark_time = marks_real_time(1);
mark_offset = first_mark_time - marks(1);

marks = marks + mark_offset;
total_offset = marks(1);
mag_off = mag_off + mark_offset- marks(1);
mag_on = mag_on + mark_offset - marks(1);
pulse_on = pulse_on + mark_offset - marks(1);
pulse_off =  pulse_off + mark_offset - marks(1);
ssr = ssr + mark_offset - marks(1);


time_real = time_real - marks(1);
time_mag = time_mag - marks(1);
marks_real_time = marks_real_time - marks(1);
marks = marks - marks(1);




time = 0:1:length(marks)-1;
P_pi = polyfit(time,marks,1);
yfit_pi = P_pi(1)*time+P_pi(2);

P_rns = polyfit(time,marks_real_time,1);
yfit_rns = P_rns(1)*time+P_rns(2);


marks = marks*P_rns(1)/P_pi(1);
mag_off = mag_off*P_rns(1)/P_pi(1);
mag_on = mag_on*P_rns(1)/P_pi(1);
pulse_on = pulse_on*P_rns(1)/P_pi(1);
pulse_off =  pulse_off*P_rns(1)/P_pi(1);
ssr = ssr*P_rns(1)/P_pi(1);




Ipulse_on = test_data_mag(1:8750) < -80;
Ipulse_off = test_data_mag(1:8750) > 80;

i = 1;
while i<length(Ipulse_on)
   
    if(Ipulse_on(i) == 1)
        Ipulse_on(i-1) = 1;
        while Ipulse_on(i) == 1
            Ipulse_on(i) = 0;
            i=i+1;
        end
    end
    i = i + 1;
end
%pulse_on = pulse_on(1:5)';
pulse_on_mag_time = time_mag(Ipulse_on);

i = 1;
while i<length(Ipulse_off)
   
    if(Ipulse_off(i) == 1)
        Ipulse_off(i-1) = 1;
        while Ipulse_off(i) == 1
            Ipulse_off(i) = 0;
            i=i+1;
        end
    end
    i = i + 1;
end
%pulse_off = pulse_off(1:5)';
pulse_off_mag_time = time_mag(Ipulse_off);


ssr_real_time = time_real(end);

p1 = plot(time_real, (abs(test_data_real)), 'Color', [39/255 116/255 174/255]);
p1.LineWidth = 2;
hold on
p2 = plot(time_mag, (abs(test_data_mag)-120), 'Color', [0/255 59/255 92/255]);
p2.LineWidth = 2;


hold on

for i =1:5
    l = line([marks(i) marks(i)], [-600 600], 'Color', 'black', 'LineStyle','--');
    l.LineWidth = 1;
end

for i =1:6
    l = line([pulse_on(i) pulse_on(i)], [-600 600], 'Color', 'red', 'LineStyle','--');
    l.LineWidth = 1;
end

   l = line([ssr ssr], [-600 600], 'Color', 'blue', 'LineStyle','--');
    l.LineWidth = 1;

       l = line([mag_on mag_on], [-600 600], 'Color', 'green', 'LineStyle','--');
    l.LineWidth = 1;
    
        l = line([mag_off mag_off], [-600 600], 'Color', 'green', 'LineStyle','--');
    l.LineWidth = 1;
lgd = legend('RTE iEEG','Magnet iEEG', 'Mark sent', 'Pulse sent', 'Store sent', 'Magnet sent')
lgd.FontSize = 20;

fprintf('\n\n\n');
fprintf('\nMark offsets:\n');
for i = 1:5
 
   fprintf('\t%f\n', marks(i) - marks_real_time(i));
end

fprintf('\nPulse offsets:\n');
for i = 1:5
    fprintf('\t%f\n', -(pulse_on(i) - pulse_on_mag_time(i)));
end

fprintf('\nSSR offsets: %f\n', ssr_real_time - ssr);
fprintf('\nMag_on: %f\n', test_hdr_mag.PreTrigger - total_offset - mag_on);


fprintf('\n\n\n');