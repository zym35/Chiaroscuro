Shader "Chiaroscuro/Outlined"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _OutlineThreshold ("Outline Threshold", Range(0, 1)) = 0.15
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
            float _NormalStrength;
            float _DepthStrength;

            float3 GetPixelValue(in float2 uv) {
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
                float2 normal = DecodeViewNormalStereo (tex2D(_CameraDepthNormalsTexture, uv));
                return fixed3(normal * _NormalStrength, depth * _DepthStrength);
            }

            float GetMeanValue(in float2 uv)
            {
                #define offsetNum 8

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
                float4 col = tex2D(_MainTex, i.uv);
                
                float meanOutline = step(_OutlineThreshold, GetMeanValue(i.uv));
                //float invertedOutline = 1 - step(0.1, toon);
                
                return col * (1-meanOutline);
            }
            ENDCG
        }
    }
}