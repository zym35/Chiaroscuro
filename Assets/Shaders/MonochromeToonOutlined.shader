Shader "Hidden/MonochromeToonOutlined"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _OutlineThreshold ("Outline Threshold", Range(0, 1)) = 0.15

        _WhiteColor ("White Color", Color) = (0.78, 0.73, 0.67, 1)
        _BlackColor ("Black Color", Color) = (0.12, 0.11, 0.2, 1)
        _ToonThreshold ("Toon Threshold", Range(0, 0.5)) = 0.1

        _NormalStrength ("Normal Strength", Float) = 1
        _DepthStrength ("Depth Strength", Float) = 1
        _InvertThreshold ("Invert Threshold", Range(0, 2)) = 1
    }
    SubShader
    {
        // No culling or depth
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

            sampler2D _CameraDepthNormalsTexture;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _OutlineThreshold;
            float4 _WhiteColor;
            float4 _BlackColor;
            float _ToonThreshold;
            float _NormalStrength;
            float _DepthStrength;
            float _InvertThreshold;

            float3 GetPixelValue(in float2 uv) {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
                float2 normal = DecodeViewNormalStereo (tex2D(_CameraDepthNormalsTexture, uv));
                return fixed3(normal * _NormalStrength, depth * _DepthStrength);
            }

            float2 GetNormalValue(in float2 uv) {
                float2 normal = DecodeViewNormalStereo (tex2D(_CameraDepthNormalsTexture, uv));
                return normal * _NormalStrength;
            }

            float GetDepthValue(in float2 uv) {
                float depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
                return depth * _DepthStrength;
            }

            float GetMeanValue(in float2 uv, in half2 offsets[8])
            {
                float3 center = GetPixelValue(uv);

                float3 sample = float3(0,0,0);

                UNITY_UNROLL
                for (int i = 0; i < 8; i++) {
                    sample += GetPixelValue(uv + offsets[i] * _MainTex_TexelSize.xy );
                }
                sample /= 8;

                return length(center - sample);
            }

            float GetSobelValue(in float2 uv,  in half2 offsets[8])
            {
                half gx[8] = {
                    -1, 0, 1,
                    -2,    2,
                    -1, 0, 1
                };

                half gy[8] = {
                    -1, -2, -1,
                    -2,    2,
                    1, 2, 1
                };

                float2 sampleXNormal = float2(0,0);
                float2 sampleYNormal = float2(0,0);
                float sampleXDepth = 0;
                float sampleYDepth = 0;

                UNITY_UNROLL
                for (int i = 0; i < 8; i++) {
                    float vD = GetDepthValue(uv + offsets[i] * _MainTex_TexelSize.xy);
                    float2 vN = GetNormalValue(uv + offsets[i] * _MainTex_TexelSize.xy);
                    sampleXNormal += vN * gx[i];
                    sampleYNormal += vN * gy[i];
                    sampleXDepth += vD * gx[i];
                    sampleYDepth += vD * gy[i];
                }

                float sampleNormal = sqrt(pow(sampleXNormal, 2) + pow(sampleYNormal, 2));
                float sampleDepth = sqrt(pow(sampleXDepth, 2) + pow(sampleYDepth, 2));

                return max(sampleNormal, sampleDepth);
            }

            float Toon(in float4 col)
            {
                //float lum = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
                return step(_ToonThreshold, col);
            }

            float4 frag (v2f i) : SV_Target
            {
                half2 offsets[8] = {
                    half2(-1, -1), half2(-1, 0), half2(-1, 1),
                    half2(0, -1),               half2(0, 1),
                    half2(1, -1), half2(1, 0), half2(1, 1)
                };

                float4 sample = tex2D(_MainTex, i.uv);

                UNITY_UNROLL
                for (int j = 0; j < 8; j++) {
                    sample += tex2D(_MainTex, i.uv + offsets[j] * _MainTex_TexelSize.xy * _InvertThreshold);
                }
                sample /= 9;
                float toon = Toon(sample);

                float meanOutline = step(_OutlineThreshold, GetMeanValue(i.uv, offsets));

                //return toon != meanOutline;

                return lerp(_BlackColor, _WhiteColor, toon != meanOutline);
            }
            ENDCG
        }
    }
}