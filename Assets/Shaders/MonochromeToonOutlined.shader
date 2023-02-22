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
            float _ToonThreshold1;
            float _ToonThreshold2;
            float _MidShade;
            float _NormalStrength;
            float _DepthStrength;

            float3 GetPixelValue(in float2 uv) {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
                float2 normal = DecodeViewNormalStereo (tex2D(_CameraDepthNormalsTexture, uv));
                return fixed3(normal * _NormalStrength, depth * _DepthStrength);
            }

            float Toon(in float4 col)
            {
                
                float lum = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
                //float lum = 0.333 * col.r + 0.333 * col.g + 0.333 * col.b;

                return step(_ToonThreshold2, lum);
                if (lum > _ToonThreshold2)
                    return 1;
                else if (lum < _ToonThreshold1)
                    return 0;
                else return _MidShade;
            }

            float GetMeanValue(in float2 uv)
            {
                #define offsetNum 4

                #if offsetNum == 4
                float2 offsets[offsetNum] = {
                    float2(-1, 0), 
                    float2(0, -1), float2(0, 1),
                    float2(1, 0)
                };
                #endif

                #if offsetNum == 8
                float2 offsets[offsetNum] = {
                    float2(-1, -1), float2(-1, 0), float2(-1, 1),
                    float2(0, -1),               float2(0, 1),
                    float2(1, -1), float2(1, 0), float2(1, 1)
                };
                #endif

                float3 center = GetPixelValue(uv);

                float3 sample = float3(0.0f,0.0f,0.0f);
                UNITY_UNROLL
                for (int i = 0; i < offsetNum; i++) {
                    sample += GetPixelValue(uv + offsets[i] * _MainTex_TexelSize.xy );
                }
                sample /= offsetNum;

                return length(center - sample);
            }

            float4 frag (v2f i) : SV_Target
            {
                float toon = Toon(tex2D(_MainTex, i.uv));
                
                float meanOutline = step(_OutlineThreshold, GetMeanValue(i.uv));
                //float invertedOutline = 1 - step(0.1, toon);
                float val = lerp(toon, 1-meanOutline, meanOutline);
                
                return lerp(_BlackColor, _WhiteColor, val);
            }
            ENDCG
        }
    }
}