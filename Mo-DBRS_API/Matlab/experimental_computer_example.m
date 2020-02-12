
%% Initialize
%%
%% Biometrics
biopac_client = biopac_initialize('/dev/tty.usbserial-BBTKUSBTTL')

%% Eye-tracking
pupil_client = pupil_initialize('192.168.1.10', 50020);

%% Mo-DBRS RP Connection
modbrs_client = mo_dbrs_initialize('192.168.1.9', 8080);




%%
%% Do Work
%% ...
%%




%% Send Marks
%%
%% Biometrics
biopac_send_pulse(biopac_client, 0.4)

%% Eye-tracking
pupil_send_mark(pupil_client);

%% Mo-DBRS send Mark
mo_dbrs_send_mark(modbrs_client);




%% Stimulate
mo_dbrs_send_stim(modbrs_client);

%% Store RTE
mo_dbrs_send_store(modbrs_client);

%% Store Magnet iEEG
mo_dbrs_send_magnet(modbrs_client);

