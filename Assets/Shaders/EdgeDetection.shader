Shader "Hidden/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineThreshold ("Outline Threshold", Range(0, 1)) = 0.15
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

            float GetMeanValue(in float2 uv)
            {
                half2 offsets[8] = {
                    half2(-1, -1), half2(-1, 0), half2(-1, 1),
                    half2(0, -1),               half2(0, 1),
                    half2(1, -1), half2(1, 0), half2(1, 1)
                };
                float3 center = tex2D(_MainTex, uv);
            
                float3 sample = float3(0,0,0);
            
                for (int i = 0; i < 8; i++) {
                    sample += tex2D(_MainTex, uv + offsets[i] * _MainTex_TexelSize.xy );
                }
                sample /= 8;
            
                return length(center - sample);
            }

            float GetSobelValue(in float2 uv)
            {
                half2 offsets[8] = {
                    half2(-1, -1), half2(-1, 0), half2(-1, 1),
                    half2(0, -1),               half2(0, 1),
                    half2(1, -1), half2(1, 0), half2(1, 1)
                };

                half gx[8] = {
                    -1, 0, 1,
                    -2,    2,
                    -1, 0, 1
                };

                half gy[8] = {
                    -1, -2, -1,
                    0,    0,
                    1, 2, 1
                };

                float3 sampleX = float3(0,0,0);
                float3 sampleY = float3(0,0,0);

                for (int i = 0; i < 8; i++) {
                    sampleX += tex2D(_MainTex, uv + offsets[i] * _MainTex_TexelSize.xy) * gx[i];
                    sampleY += tex2D(_MainTex, uv + offsets[i] * _MainTex_TexelSize.xy) * gy[i];
                }

                float3 sample = sqrt(pow(sampleX, 2) + pow(sampleY, 2));

                return length(sample);
            }

            float4 frag (v2f i) : SV_Target
            {
                float edge = GetSobelValue(i.uv);
                //return tex2D(_MainTex, i.uv);
                //return edge;
                return step(_OutlineThreshold, edge);
            }
            ENDCG
        }
    }
}