
# Pupil-Labs

In our experiments we use open-source Pupil Core eye-tracking device. 

For our paradigms we added custom Matlab and Unity support for wired and wireless setup. Implemented functions can be used to control calibration, recording, and software marking of the eye-tracking data streams.

For more information visit https://pupil-labs.com and https://github.com/pupil-labs/pupil

1. Follow the Pupil-Labs instructions to setup your eye-tracking equipment with setup that uses Pupil Capture software.
2. Within Plugin Manager of Pupil Capture make sure to enable Pupil Remote and Annotation Capture.
3. Once eye-tracking is successfully started and connected to your network, check Pupil Remote to find out local or remote IP address and port number which will be used in your Experimental paradigm codes to connect to eye-tracking setup.
4. Include files from matlab/unity folders into your paradigm design and call eye-tracking functions as needed.
