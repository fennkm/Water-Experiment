Shader "Custom/Phong"
{
    Properties
    {
        _AmbientReflectivity ("Ambient Reflectivity", float) = 0.2

        _DiffuseReflectivity ("Diffuse Reflectivity", float) = 0.5
        _DiffuseColour ("Diffuse Colour", Color) = (1, 1, 1, 1)

        _SpecularReflectivity ("Specular Reflectivity", float) = 0.6
        _SpecularFactor ("Specular Factor", float) = 2

        _LightColour ("Light Colour", Color) = (1, 1, 1, 1)
        _SunHeight ("Sun Height", float) = 1.0
        _SunAngle ("Sun Angle", float) = 1.0
        _SunIntensity ("Sun Intensity", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct vertData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct interpolator
            {
                // float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 sunVec : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            float _AmbientReflectivity;

            float _DiffuseReflectivity;
            float4 _DiffuseColour;
            
            float _SpecularReflectivity;
            float _SpecularFactor;
            float4 _LightColour;

            float _SunIntensity;
            float _SunHeight;
            float _SunAngle;

            interpolator vert (vertData v)
            {
                interpolator o;
                
                o.normal = v.normal;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.sunVec = float3
                (
                    cos(_SunHeight) * sin(_SunAngle),
                    sin(_SunHeight),
                    cos(_SunHeight) * cos(_SunAngle)
                );

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                return o;
            }

            fixed4 frag (interpolator i) : SV_Target
            {
                // fixed4 col = fixed4(abs(i.normal.x), abs(i.normal.y), abs(i.normal.z), 1);
                
                float diffuse = clamp(dot(i.normal, i.sunVec), 0, 1) * _DiffuseReflectivity * _SunIntensity;

                float3 reflectVec = normalize(2 * dot(i.normal, i.sunVec) * i.normal - i.sunVec);
                float specular = pow(clamp(dot(reflectVec, i.viewDir), 0, 1), _SpecularFactor) * _SpecularReflectivity * _SunIntensity;

                float ambient = _AmbientReflectivity * _SunIntensity;

                fixed4 col = (diffuse + ambient) * _DiffuseColour + specular * _LightColour;
                
                return col;
            }
            ENDCG
        }
    }
}
