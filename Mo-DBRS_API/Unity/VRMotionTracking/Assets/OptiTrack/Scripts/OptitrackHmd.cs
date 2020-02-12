//======================================================================================================
// Copyright 2016, NaturalPoint Inc.
//======================================================================================================

using System;
using System.Runtime.InteropServices;
using UnityEngine;


public class OptitrackHmd : MonoBehaviour
{
    public enum OptitrackHmdRbOrientation
    {
        // Oculus/SteamVR native
        NegativeZForward,

        // Unity
        PositiveZForward,

        // Unreal
        PositiveXForward,
    }

    public OptitrackStreamingClient StreamingClient;
    public Int32 RigidBodyId;
    public OptitrackHmdRbOrientation RigidBodyOrientation;

    private bool m_deviceInitialized = false;
    private bool m_deviceWasPresent = false;
    private GameObject m_hmdCameraObject;
    private IntPtr m_nphmdHandle;


    void Start()
    {
        // If the user didn't explicitly associate a client, find a suitable default.
        if ( this.StreamingClient == null )
        {
            this.StreamingClient = OptitrackStreamingClient.FindDefaultClient();

            // If we still couldn't find one, disable this component.
            if ( this.StreamingClient == null )
            {
                Debug.LogError( GetType().FullName + ": Streaming client not set, and no " + typeof( OptitrackStreamingClient ).FullName + " components found in scene; disabling this component.", this );
                this.enabled = false;
                return;
            }
        }

        m_deviceWasPresent = DevicePresent();
        m_deviceInitialized = InitializeDevice();
    }


    void OnEnable()
    {
        NpHmdResult result = NativeMethods.NpHmd_Create( out m_nphmdHandle );
        if ( result != NpHmdResult.OK || m_nphmdHandle == IntPtr.Zero )
        {
            Debug.LogError( GetType().FullName + ": NpHmd_Create failed.", this );
            m_nphmdHandle = IntPtr.Zero;
            this.enabled = false;
            return;
        }

#if UNITY_2017_1_OR_NEWER
        Application.onBeforeRender += OnBeforeRender;
#endif
    }


    void OnDisable()
    {
#if UNITY_2017_1_OR_NEWER
        Application.onBeforeRender -= OnBeforeRender;
#endif

        if ( m_nphmdHandle != IntPtr.Zero )
        {
            NativeMethods.NpHmd_Destroy( m_nphmdHandle );
            m_nphmdHandle = IntPtr.Zero;
        }
    }


    void Update()
    {
        if ( ! m_deviceInitialized )
        {
            if ( m_deviceWasPresent == false && DevicePresent() )
            {
                Debug.LogWarning( GetType().FullName + ": XRDevice found.", this );

                m_deviceWasPresent = true;
                m_deviceInitialized = InitializeDevice();
            }
        }
        else
        {
            if ( m_deviceWasPresent && DevicePresent() == false )
            {
                Debug.LogWarning( GetType().FullName + ": XRDevice lost.", this );

                m_deviceWasPresent = false;
                m_deviceInitialized = false;
            }
        }

        UpdatePose();
    }


#if UNITY_2017_1_OR_NEWER
    void OnBeforeRender()
    {
        UpdatePose();
    }
#endif


    void UpdatePose()
    {
        OptitrackRigidBodyState rbState = StreamingClient.GetLatestRigidBodyState( RigidBodyId );
        if ( rbState != null && rbState.DeliveryTimestamp.AgeSeconds < 1.0f )
        {
            this.transform.localPosition = rbState.Pose.Position;

            if ( m_nphmdHandle != IntPtr.Zero && m_deviceInitialized )
            {
                NpHmdQuaternion inertialOri = new NpHmdQuaternion( m_hmdCameraObject.transform.localRotation );
                NpHmdQuaternion opticalOri;
                switch ( RigidBodyOrientation )
                {
                    case OptitrackHmdRbOrientation.NegativeZForward:
                        opticalOri = new NpHmdQuaternion( rbState.Pose.Orientation * Quaternion.Euler( 0.0f, 180.0f, 0.0f ) );
                        break;
                    case OptitrackHmdRbOrientation.PositiveZForward:
                        opticalOri = new NpHmdQuaternion( rbState.Pose.Orientation );
                        break;
                    case OptitrackHmdRbOrientation.PositiveXForward:
                        opticalOri = new NpHmdQuaternion( rbState.Pose.Orientation * Quaternion.Euler( 0.0f, -90.0f, 0.0f ) );
                        break;
                    default:
                        return;
                }

                NpHmdResult result = NativeMethods.NpHmd_MeasurementUpdate(
                    m_nphmdHandle,
                    ref opticalOri, // const
                    ref inertialOri, // const
                    Time.deltaTime
                );

                if ( result == NpHmdResult.OK )
                {
                    NpHmdQuaternion newCorrection;
                    result = NativeMethods.NpHmd_GetOrientationCorrection( m_nphmdHandle, out newCorrection );

                    if ( result == NpHmdResult.OK )
                    {
                        this.transform.localRotation = newCorrection;
                    }
                    else
                    {
                        Debug.LogError( GetType().FullName + ": NpHmd_GetOrientationCorrection failed.", this );
                        this.enabled = false;
                        return;
                    }
                }
                else
                {
                    Debug.LogError( GetType().FullName + ": NpHmd_MeasurementUpdate failed.", this );
                    this.enabled = false;
                    return;
                }
            }
        }
    }


    bool DevicePresent()
    {
#if UNITY_2017_2_OR_NEWER
        return UnityEngine.XR.XRSettings.enabled && UnityEngine.XR.XRDevice.isPresent;
#else
        return UnityEngine.VR.VRSettings.enabled && UnityEngine.VR.VRDevice.isPresent;
#endif
    }


    bool DeviceSupported()
    {
        if ( ! DevicePresent() )
        {
            return false;
        }

#if UNITY_2017_2_OR_NEWER
        string deviceFamily = UnityEngine.XR.XRSettings.loadedDeviceName;
        string deviceModel = UnityEngine.XR.XRDevice.model;
#else
        string deviceFamily = UnityEngine.VR.VRSettings.loadedDeviceName;
        string deviceModel = UnityEngine.VR.VRDevice.model;
#endif

        bool isOculusDevice = String.Equals( deviceFamily, "oculus", StringComparison.CurrentCultureIgnoreCase );
        return isOculusDevice;
    }


    bool InitializeDevice()
    {
        if ( DevicePresent() )
        {
            if ( DeviceSupported() )
            {
                if ( ! TryDisableOvrPositionTracking() )
                {
                    Debug.LogError( GetType().FullName + ": Could not disable OVR position tracking.", this );
                    return false;
                }
                else
                {
                    Debug.Log( GetType().FullName + ": Successfully disabled OVR position tracking.", this );
                }
            }
            else
            {
                Debug.LogWarning( GetType().FullName + ": Unsupported XRDevice type.", this );
                return false;
            }
        }
        else
        {
            Debug.LogWarning( GetType().FullName + ": No XRDevice present.", this );
            return false;
        }

        // Cache a reference to the GameObject containing the HMD Camera.
        Camera hmdCamera = this.GetComponentInChildren<Camera>();
        if ( hmdCamera == null )
        {
            Debug.LogError( GetType().FullName + ": Couldn't locate HMD-driven Camera component in children.", this );
            return false;
        }
        else
        {
            m_hmdCameraObject = hmdCamera.gameObject;
        }

        Debug.Log( GetType().FullName + ": Successfully (re)initialized.", this );
        return true;
    }


    private enum NpHmdResult
    {
        OK = 0,
        InvalidArgument
    }


    private struct NpHmdQuaternion
    {
        public float x;
        public float y;
        public float z;
        public float w;

        public NpHmdQuaternion( UnityEngine.Quaternion other )
        {
            this.x = other.x;
            this.y = other.y;
            this.z = other.z;
            this.w = other.w;
        }

        public static implicit operator UnityEngine.Quaternion( NpHmdQuaternion nphmdQuat )
        {
            return new UnityEngine.Quaternion
            {
                w = nphmdQuat.w,
                x = nphmdQuat.x,
                y = nphmdQuat.y,
                z = nphmdQuat.z
            };
        }
    }


    private static class NativeMethods
    {
        public const string NpHmdDllBaseName = "HmdDriftCorrection";
        public const CallingConvention NpHmdDllCallingConvention = CallingConvention.Cdecl;

        [DllImport( NpHmdDllBaseName, CallingConvention = NpHmdDllCallingConvention )]
        public static extern NpHmdResult NpHmd_UnityInit();

        [DllImport( NpHmdDllBaseName, CallingConvention = NpHmdDllCallingConvention )]
        public static extern NpHmdResult NpHmd_Create( out IntPtr hmdHandle );

        [DllImport( NpHmdDllBaseName, CallingConvention = NpHmdDllCallingConvention )]
        public static extern NpHmdResult NpHmd_Destroy( IntPtr hmdHandle );

        [DllImport( NpHmdDllBaseName, CallingConvention = NpHmdDllCallingConvention )]
        public static extern NpHmdResult NpHmd_MeasurementUpdate( IntPtr hmdHandle, ref NpHmdQuaternion opticalOrientation, ref NpHmdQuaternion inertialOrientation, float deltaTimeSec );

        [DllImport( NpHmdDllBaseName, CallingConvention = NpHmdDllCallingConvention )]
        public static extern NpHmdResult NpHmd_GetOrientationCorrection( IntPtr hmdHandle, out NpHmdQuaternion correction );


        public const string OvrPluginDllBaseName = "OVRPlugin";
        public const CallingConvention OvrPluginDllCallingConvention = CallingConvention.Cdecl;

        [DllImport( OvrPluginDllBaseName, CallingConvention = OvrPluginDllCallingConvention )]
        public static extern Int32 ovrp_GetCaps();

        [DllImport( OvrPluginDllBaseName, CallingConvention = OvrPluginDllCallingConvention )]
        public static extern Int32 ovrp_SetCaps( Int32 caps );

        [DllImport( OvrPluginDllBaseName, CallingConvention = OvrPluginDllCallingConvention )]
        public static extern Int32 ovrp_SetTrackingIPDEnabled( Int32 value );
    }


    private bool TryDisableOvrPositionTracking()
    {
        try
        {
            const Int32 kCapsPositionBit = (1 << 5);
            Int32 oldCaps = NativeMethods.ovrp_GetCaps();
            bool bSucceeded = NativeMethods.ovrp_SetCaps( oldCaps & ~kCapsPositionBit ) != 0;

            try
            {
                NativeMethods.ovrp_SetTrackingIPDEnabled( 1 );
            }
            catch ( Exception ex )
            {
                Debug.LogError( GetType().FullName + ": ovrp_SetTrackingIPDEnabled failed. OVRPlugin too old?", this );
                Debug.LogException( ex, this );
                bSucceeded = false;
            }

            return bSucceeded;
        }
        catch ( Exception ex )
        {
            Debug.LogException( ex, this );
            return false;
        }
    }
}
