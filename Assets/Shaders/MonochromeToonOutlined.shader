Shader "Hidden/MonochromeToonOutlined"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _OutlineThreshold ("Outline Threshold", Range(0, 1)) = 0.15

        _WhiteColor ("White Color", Color) = (0.78, 0.73, 0.67, 1)
        _BlackColor ("Black Color", Color) = (0.12, 0.11, 0.2, 1)
        _ToonThreshold1 ("Toon Threshold1", Range(0, 1)) = 0.1
        _ToonThreshold2 ("Toon Threshold2", Range(0, 1)) = 0.1
        _MidShade ("Mid Shade", Range(0, 1)) = 0.1

        _NormalStrength ("Normal Strength", Float) = 1
        _DepthStrength ("Depth Strength", Float) = 1
        _OutlineDistance ("Outline Show Distance", Float) = 1
        
        _GridSize ("Grid Size", Range(2, 200)) = 8
        _StripWidth ("Strip Width", Range(0.01, 1)) = 0.1
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _CameraDepthNormalsTexture;
            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _OutlineThreshold;
            float4 _WhiteColor;
            float4 _BlackColor;
            float _ToonThreshold1;
            float _ToonThreshold2;
            float _MidShade;
            float _NormalStrength;
            float _DepthStrength;
            float _GridSize;
            float _OutlineDistance;

            float4 GetPixelValue(in float2 uv) {
                float depth = 0;
                float3 normal;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, normal);

                return float4(normal * _NormalStrength, log(depth));
            }

            float2 hash2(float2 p) {
                return frac(sin(float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)))) * 43758.5453);
            }

            float noise(float2 p) {
                float2 Pi = floor(p);
                float2 Pf = p - Pi;
                float2 w = Pf * Pf * (3.0 - 2.0 * Pf);

                return lerp(lerp(dot(Pf - float2(0, 0), hash2(Pi + float2(0, 0))),
                                 dot(Pf - float2(0, 1), hash2(Pi + float2(0, 1))), w.y),
                             lerp(dot(Pf - float2(1, 0), hash2(Pi + float2(1, 0))),
                                 dot(Pf - float2(1, 1), hash2(Pi + float2(1, 1))), w.y), w.x);
            }
            
            float Toon(in float2 uv)
            {
                float4 col = tex2D(_MainTex, uv);
                float lum = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;

                float timeOffset = _Time.y * 0.3;
                float noiseVal = noise(uv * 10 + timeOffset) * 0.03;
                
                float originalToon = max(step(_ToonThreshold1, lum) * _MidShade, step(_ToonThreshold2, lum));

                if (originalToon == _MidShade) {
                    lum += noiseVal;
                }

                float toon = max(step(_ToonThreshold1, lum) * _MidShade, step(_ToonThreshold2, lum));
                return toon;
            }

            float GetMeanValue(in float2 uv)
            {
                float2 offsets[8] = {
                    float2(-1, -1), float2(-1, 0), float2(-1, 1),
                    float2(0, -1),               float2(0, 1),
                    float2(1, -1), float2(1, 0), float2(1, 1)
                };

                float4 center = GetPixelValue(uv);

                float4 sample = float4(0.0f,0.0f,0.0f,0.0f);
                UNITY_UNROLL
                for (int i = 0; i < 8; i++) {
                    sample += GetPixelValue(uv + offsets[i] * _MainTex_TexelSize.xy );
                }
                sample /= 8;

                return length(center - sample);
            }

            float2 GetClipNormal(in float2 uv)
            {
                // Get the world normal
                float3 worldNormal = GetPixelValue(uv).xyz;

                // Calculate clip space normal
                float2 clipSpaceNormal = mul(UNITY_MATRIX_V, float4(worldNormal, 0)).xy;
                return clipSpaceNormal;
            }

            float checker(in float2 uv )
            {
                float aspectRatio = _MainTex_TexelSize.y / _MainTex_TexelSize.x;
                float2 gridCoords = uv * float2(_GridSize * aspectRatio, _GridSize);
                float2 intPart;
                float2 fracPart = modf(gridCoords, intPart);
                float checker = step(0.5, (intPart.x + intPart.y) % 2);
                return checker;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                float toon = Toon(i.uv);
                
                float outline = step(_OutlineThreshold, GetMeanValue(i.uv));
                //if (toon < 0.9 || GetPixelValue(i.uv).w > _OutlineDistance) outline = 0;
                
                float val = saturate(toon - outline);
                //return outline;
                return lerp(_BlackColor, _WhiteColor, val);
            }
            ENDCG
        }
    }
}