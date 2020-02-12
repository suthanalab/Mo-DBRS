Shader "Hidden/OptiTrack/Editor/MarkerShader"
{
    Properties
    {
        _Color( "Color", Color ) = (1,1,1,1)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }


        // First pass: Only occluded fragments (negated depth test), rendered WITH alpha blending.
        Pass
        {
            ZWrite Off
            ZTest Greater
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma shader_feature _FORCE_TO_GAMMA
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexIn
            {
                float3 position : POSITION;
                float3 normal : NORMAL;
            };

            struct VertexOut
            {
                float4 position : SV_POSITION;
                fixed4 color : COLOR0;
            };

            fixed4 _Color;

            VertexOut vert( VertexIn In )
            {
                VertexOut Out;
                Out.color = _Color;
                Out.position = UnityObjectToClipPos( float4( In.position.xyz, 1.0 ) );
                return Out;
            }

            fixed4 frag( VertexOut In ) : SV_Target
            {
#if _FORCE_TO_GAMMA
                In.color.rgb = LinearToGammaSpace( In.color.rgb );
#endif // #if _FORCE_TO_GAMMA

                return In.color;
            }
            ENDCG
        }


        // Second pass: Only unoccluded fragments, rendered WITHOUT alpha blending.
        Pass
        {
            CGPROGRAM
            #pragma shader_feature _FORCE_TO_GAMMA
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexIn
            {
                float3 position : POSITION;
                float3 normal : NORMAL;
            };

            struct VertexOut
            {
                float4 position : SV_POSITION;
                fixed4 color : COLOR0;
            };

            fixed4 _Color;

            VertexOut vert( VertexIn In )
            {
                VertexOut Out;
                Out.color = _Color;
                Out.position = UnityObjectToClipPos( float4(In.position.xyz, 1.0) );
                return Out;
            }

            fixed4 frag( VertexOut In ) : SV_Target
            {
#if _FORCE_TO_GAMMA
                In.color.rgb = LinearToGammaSpace( In.color.rgb );
#endif // #if _FORCE_TO_GAMMA

                return fixed4( In.color.rgb, 1.0 );
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
