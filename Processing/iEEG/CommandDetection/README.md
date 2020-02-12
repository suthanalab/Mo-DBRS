# Synchronization

Detection of *Marks* and *Magnets* in iEEG data for synchronization purposes

- RNSData0910 folder contains one trace of RNS extracted iEEG data that contains targeted artifacts.
- rp_timestamps folder contains Raspberry Pi local timestamps for every command sent.
- detection.m is a script that finds Marks, Magnets, and test voltage pulses that where connected to the recording contacts. It also compares specific events to their logged timestamps.

