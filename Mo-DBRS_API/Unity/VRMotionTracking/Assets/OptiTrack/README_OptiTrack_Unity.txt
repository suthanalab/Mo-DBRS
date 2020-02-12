OptiTrack Unity Plugin
===========================

The OptiTrack Unity Plugin allows you to stream real-time rigid body,
skeletal animation, and HMD tracking data into Unity.

For more information, refer to the documentation at the following URL:

    http://wiki.optitrack.com/index.php?title=OptiTrack_Unity_Plugin



Version History / Changelog
---------------------------

1.2.0 (2018-09-12)
-----
- Updated NatNetLib to version 3.1.0. Can now stream more than 100 rigid bodies into Unity.
- Added marker data (unlabeled and labeled) to streaming client.
- Added ability to draw markers to client origin.
- Compatibility updates for Unity 2018.2


1.1.0 (2017-11-30)
-----
- Implemented late update functionality when using Unity 2017.1+, which
  reduces render transform latency for both rigid body and HMD components.
- Added support for alternative HMD rigid body streaming orientations.
- Added Mecanim finger retargeting support.
- Improved handling of HMD disconnection and reconnection.
- Compatibility updates for Unity 2017.2.
- Updated NatNetLib to version 3.0.1.


1.0.1 (2016-10-13)
-----
- Improved detection and handling of client connection errors.


1.0.0 (2016-08-23)
-----
- Initial release.
