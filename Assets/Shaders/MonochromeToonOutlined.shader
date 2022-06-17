Shader "Hidden/MonochromeToonOutlined"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _OutlineThreshold ("Outline Threshold", Range(0, 1)) = 0.15

        _WhiteColor ("White Color", Color) = (0.78, 0.73, 0.67, 1)
        _BlackColor ("Black Color", Color) = (0.12, 0.11, 0.2, 1)
        _ToonThreshold ("Toon Threshold", Range(0, 0.5)) = 0.1
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

            float4 GetPixelValue(in float2 uv) {
                float4 depthNormals = tex2D(_CameraDepthNormalsTexture, uv);

                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
                float3 normal = DecodeViewNormalStereo (depthNormals);

                return fixed4(normal, depth);
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float4 orValue = GetPixelValue(i.uv);
                half2 offsets[8] = {
                    half2(-1, -1), half2(-1, 0), half2(-1, 1),
                    half2(0, -1),               half2(0, 1),
                    half2(1, -1), half2(1, 0), half2(1, 1)
                };
                float4 sampledValue = float4(0,0,0,0);

                [unroll]
                for (int j = 0; j < 8; j++) {
                    sampledValue += GetPixelValue(i.uv + offsets[j] * _MainTex_TexelSize.xy);
                }
                sampledValue /= 8;

                float4 outlined = lerp(col, _BlackColor, step(_OutlineThreshold, length(orValue - sampledValue)));

                float lum = 0.299 * outlined.r + 0.587 * outlined.g + 0.114 * outlined.b;
                float toon = step(_ToonThreshold, lum);

                return lerp(_BlackColor, _WhiteColor, toon);
            }
            ENDCG
        }
    }
}