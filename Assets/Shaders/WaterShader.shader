Shader "Custom/WaterShader"
{
    Properties
    {
        _AmbientReflectivity ("Ambient Reflectivity", Range (0, 1)) = 0.2
        _AmbientColour ("Ambient Colour", Color) = (1, 1, 1, 1)

        _DiffuseReflectivity ("Diffuse Reflectivity", Range (0, 1)) = 0.5
        _DiffuseColour ("Diffuse Colour", Color) = (1, 1, 1, 1)

        _SpecularReflectivity ("Specular Reflectivity", Range (0, 1)) = 0.6
        _SpecularFactor ("Specular Factor", Range (1, 500)) = 2

        _LightColour ("Light Colour", Color) = (1, 1, 1, 1)
        _SunIntensity ("Sun Intensity", Range(0, 1)) = 1.0

        _NoiseIterations ("Noise Iterations", Range(0, 32)) = 8
        _StartingFreq ("Starting Frequency", Range(0, 10)) = 1.0
        _StartingAmp ("Starting Amplitude", Range(0, 1)) = 1.0
        _StartingSpeed ("Starting Speed", Range(0, 10)) = 1.0
        _StartingSharpness ("Starting Sharpness", Range(0, 10)) = 1.0

        _FrequencyFactor ("Frequency Factor", Range(1, 2)) = 1.0
        _AmplitudeFactor ("Amplitude Factor", Range(0, 1)) = 1.0
        _SpeedFactor ("Speed Factor", Range(1, 2)) = 1.0
        _SharpnessFactor ("Sharpness Factor", Range(0, 2)) = 1.0

        _WaveAngle ("Wave Angle", Range(0, 6.2831833)) = 0.0
        _WaveAngleChange ("Wave Angle Change", Range(0, 20)) = 10.0

        _Drag ("Drag", Range(0, 20)) = 0.0
        _Wobble ("Wobble", Range(0, 20)) = 0.0
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
            };

            struct interpolator
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

			samplerCUBE _Skybox;

            float _AmbientReflectivity;
            float4 _AmbientColour;

            float _DiffuseReflectivity;
            float4 _DiffuseColour;
            
            float _SpecularReflectivity;
            float _SpecularFactor;

            float _SunIntensity;
            float3 _SunDir;
            float4 _SunColour;

            float _NoiseIterations;
            float _StartingFreq;
            float _StartingAmp;
            float _StartingSpeed;
            float _StartingSharpness;

            float _FrequencyFactor;
            float _AmplitudeFactor;
            float _SpeedFactor;
            float _SharpnessFactor;

            float _WaveAngle;
            float _WaveAngleChange;

            float _Drag;
            float _Wobble;

            interpolator vert (vertData v)
            {
                interpolator o;

                float dir = _WaveAngle;
                float freq = _StartingFreq;
                float amp = _StartingAmp;
                float speed = _StartingSpeed;
                float sharp = _StartingSharpness;

                float xSlopeSum = 0;
                float zSlopeSum = 0;

                float prevdx = 0;
                float prevdz = 0;

                for (int i = 0; i < _NoiseIterations; i++)
                {
                    float val = (v.uv.x + prevdx * 10.0 * _Drag) * cos(dir) + (v.uv.y + prevdz * 10.0 * _Drag) * sin(dir);

                    float a = amp;
                    float b = sharp;
                    float c = 6.2831833 * freq * 0.01;
                    float d = _Time.y * speed;

                    v.vertex.y += a * exp(b * sin(c * val + d));

                    v.vertex.x += prevdx * _Wobble;
                    v.vertex.z += prevdz * _Wobble;

                    prevdx = a * b * c * cos(c * val + d) * exp(b * sin(c * val + d)) * cos(dir);
                    prevdz = a * b * c * cos(c * val + d) * exp(b * sin(c * val + d)) * sin(dir);

                    xSlopeSum += prevdx;
                    zSlopeSum += prevdz;

                    freq *= _FrequencyFactor;
                    amp *= _AmplitudeFactor;
                    speed *= _SpeedFactor;
                    sharp *= _SharpnessFactor;

                    float2 noise = (frac(sin(dot(i / _NoiseIterations, float2(12.9898,78.233) * 2.0)) * 43758.5453));

                    dir += _WaveAngleChange;
                }

                float3 xTangent = normalize(float3(1, xSlopeSum, 0));
                float3 zTangent = normalize(float3(0, zSlopeSum, 1));

                o.normal = cross(zTangent, xTangent);

                o.vertex = UnityObjectToClipPos(v.vertex);

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                o.uv = v.uv;

                return o;
            }

            fixed4 frag (interpolator i) : SV_Target
            {
                float diffuse = clamp(dot(i.normal, _SunDir), 0, 1) * _DiffuseReflectivity * _SunIntensity;

                float3 reflectVec = normalize(2 * dot(i.normal, _SunDir) * i.normal - _SunDir);
                float specular = pow(clamp(dot(reflectVec, i.viewDir), 0, 1), _SpecularFactor) * _SpecularReflectivity * _SunIntensity;

                float fresnel = pow((1 - clamp(dot(i.viewDir, i.normal), 0, 1)), 5);
                
                float3 mirrorVec = normalize(2 * dot(i.normal, i.viewDir) * i.normal - i.viewDir);
                float3 skyCol = texCUBE(_Skybox, mirrorVec).rgb;
				float3 sun = _SunColour * pow(clamp(dot(mirrorVec, _SunDir), 0, 1), 3500.0f);

                float4 reflectCol = float4((skyCol.rgb + sun.rgb) * fresnel, 1);

                float ambient = _AmbientReflectivity * _SunIntensity;

                fixed4 col = reflectCol + ambient * _AmbientColour + diffuse * _DiffuseColour + specular * _SunColour;
                
                return col;
            }
            ENDCG
        }
    }
}
