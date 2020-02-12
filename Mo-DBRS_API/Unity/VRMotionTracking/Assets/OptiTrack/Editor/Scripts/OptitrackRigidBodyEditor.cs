using System.Collections;
using UnityEditor;
using UnityEngine;


[CustomEditor( typeof( OptitrackRigidBody ) )]
public class OptitrackRigidBodyEditor : Editor
{
    Material m_cachedMarkerMaterial = null;
    Material m_markerMaterial
    {
        get
        {
            if ( m_cachedMarkerMaterial )
                return m_cachedMarkerMaterial;

            m_cachedMarkerMaterial = Instantiate( AssetDatabase.LoadAssetAtPath<Material>( "Assets/OptiTrack/Editor/Materials/MarkerMaterial.mat" ) );

            // For some reason, our usage pattern of DrawMeshNow within OnSceneGUI
            // necessitates an explicit linear-to-gamma conversion on the shader color.
            m_cachedMarkerMaterial.EnableKeyword( "_FORCE_TO_GAMMA" );

            return m_cachedMarkerMaterial;
        }
    }

    Mesh m_cachedMarkerMesh = null;
    Mesh m_markerMesh
    {
        get
        {
            if ( m_cachedMarkerMesh )
                return m_cachedMarkerMesh;

            m_cachedMarkerMesh = Instantiate( AssetDatabase.LoadAssetAtPath<Mesh>( "Assets/OptiTrack/Editor/Meshes/MarkerMesh.fbx" ) );
            return m_cachedMarkerMesh;
        }
    }


    /// <summary>
    /// Draws marker visualizations in the editor viewport for any selected OptitrackRigidBody component.
    /// </summary>
    void OnSceneGUI()
    {
        OptitrackRigidBody rb = target as OptitrackRigidBody;

        if ( !rb || rb.StreamingClient == null )
        {
            return;
        }

        rb.StreamingClient._EnterFrameDataUpdateLock();

        try
        {
            OptitrackRigidBodyDefinition rbDef = rb.StreamingClient.GetRigidBodyDefinitionById( rb.RigidBodyId );
            OptitrackRigidBodyState rbState = rb.StreamingClient.GetLatestRigidBodyState( rb.RigidBodyId );

            if ( rbDef != null && rbState != null )
            {
                for ( int iMarker = 0; iMarker < rbDef.Markers.Count; ++iMarker )
                {
                    OptitrackRigidBodyDefinition.MarkerDefinition marker = rbDef.Markers[iMarker];

                    // Effectively treat the RB GameObject transform as a rigid transform by negating its local scale.
                    Vector3 markerPos = marker.Position;
                    markerPos.Scale( new Vector3( 1.0f / rb.transform.localScale.x, 1.0f / rb.transform.localScale.y, 1.0f / rb.transform.localScale.z ) );
                    markerPos = rb.transform.TransformPoint( markerPos );

                    float kMarkerSize = 0.02f;
                    Matrix4x4 markerTransform = Matrix4x4.TRS( markerPos, Quaternion.identity, new Vector3( kMarkerSize, kMarkerSize, kMarkerSize ) );

                    for ( int iPass = 0; iPass < m_markerMaterial.passCount; ++iPass )
                    {
                        if ( m_markerMaterial.SetPass( iPass ) )
                        {
                            Graphics.DrawMeshNow( m_markerMesh, markerTransform );
                        }
                    }
                }
            }
        }
        finally
        {
            rb.StreamingClient._ExitFrameDataUpdateLock();
        }
    }
}
