Shader "Hidden/AtmosphereShader"
{
    Properties
    {
        _MainTex ("Base", 2D) = "" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex, _DepthTex;
			samplerCUBE _Skybox;

            float3 _SunDir;
            float3 _SunColour;

            float4x4 _CameraInvViewProjection;

            // v2f_img vert_img( appdata_img v )
            // {
            //     v2f_img o;
            //     o.pos = UnityObjectToClipPos (v.vertex);
            //     o.uv = v.texcoord;
            //     return o;
            // }

            float3 ComputeWorldSpacePosition (float2 positionNDC, float deviceDepth)
            {
                float4 positionCS  = float4(positionNDC * 2.0 - 1.0, deviceDepth, 1.0);
                float4 hpositionWS = mul(_CameraInvViewProjection, positionCS);
                return hpositionWS.xyz / hpositionWS.w;
            }

            fixed4 frag (v2f_img i) : COLOR
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos - ComputeWorldSpacePosition(i.uv, UNITY_NEAR_CLIP_VALUE));

                float depth = SAMPLE_DEPTH_TEXTURE(_DepthTex, i.uv);
                
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 sun = _SunColour * pow(clamp(dot(viewDir, _SunDir) * -1, 0, 1), 3500.0f);

                float3 sky = texCUBE(_Skybox, -viewDir) + sun;

                if (depth == 0) col.rgb = sky;

                return fixed4(col);
            }
            ENDCG
        }
    }
}
