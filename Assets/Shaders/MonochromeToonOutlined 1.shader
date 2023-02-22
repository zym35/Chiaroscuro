// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/MonochromeToonOutlined1"
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

        _Strength ("Strength", Float) = 1
        _PosStrength ("Pos Strength", Float) = 1
    }
    SubShader
    {
//        Pass
//        {
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//
//            #include "UnityCG.cginc"
//
//            struct v2f
//            {
//                float4 pos : SV_POSITION;
//                float3 color : COLOR0;
//            };
//
//            float _Strength;
//            float _PosStrength;
//
//            v2f vert (appdata_full v)
//            {
//                v2f o;
//                o.pos = UnityObjectToClipPos(v.vertex);
//
//                float3 origin = mul(unity_ObjectToWorld, float4(0.0,0.0,0.0,1.0)).xyz;
//                float3 area = float3(1,1,1) * _PosStrength;
//
//                float3 cameraDir = mul((float3x3)UNITY_MATRIX_V,float3(0,0,1));
//                float3 norm = mul(unity_ObjectToWorld, float4(v.normal, 0.0));
//                norm *= v.color.r;
//                float light = saturate((dot(norm, cameraDir)+1.0)*0.5);
//
//                o.color = (origin + area) * 0.5 / area;
//                o.color.x *= light;
//                o.color.y /= light;
//                o.color *= v.color.r;
//                o.color = frac(o.color * _Strength);
//                 
//                return o;
//            }
//
//            //the problem is that the line is not pixel perfect !!!
//            float4 frag (v2f i) : SV_Target
//            {
//                return float4(i.color, 1.0f);
//            }
//            ENDCG
//        }
        
//        Blend One One
//        CGPROGRAM
//        #pragma surface surf SimpleLambert
//  
//        half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten) {
//            half NdotL = dot (s.Normal, lightDir);
//            half4 c;
//            c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
//            c.a = s.Alpha;
//            return c;
//        }
//  
//        struct Input {
//            float2 uv_MainTex;
//        };
//        
//        sampler2D _MainTex;
//        
//        void surf (Input IN, inout SurfaceOutput o) {
//            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
//        }
//        ENDCG
        
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
                //return tex2D(_MainTex, uv);
            }

            float Toon(in float4 col)
            {
                //float lum = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
                float lum = 0.333 * col.r + 0.333 * col.g + 0.333 * col.b;
                if (lum > _ToonThreshold2)
                    return 1;
                else if (lum < _ToonThreshold1)
                    return 0;
                else return _MidShade;
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

            //the problem is that the line is not pixel perfect !!!
            float4 frag (v2f i) : SV_Target
            {
                float toon = Toon(tex2D(_MainTex, i.uv));
                
                float meanOutline = step(_OutlineThreshold, GetMeanValue(i.uv));
                float invertedOutline = abs(sign(toon - meanOutline));
                //float invertedOutline = step(1.5f, toon + meanOutline);
                //if (meanOutline == toon) return 0;
                //else return 1;
                
                //return lerp(_BlackColor, _WhiteColor, invertedOutline);
                return float4(GetPixelValue(i.uv), 1.0f);
                //return lerp(_BlackColor, _WhiteColor, toon);
            }
            ENDCG
        }
        
        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}