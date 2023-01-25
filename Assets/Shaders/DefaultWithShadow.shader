Shader "Chirascuro/DefaultWithShadow"
{
    Properties
    {
        _WhiteColor ("White Color", Color) = (0.78, 0.73, 0.67, 1)
        _BlackColor ("Black Color", Color) = (0.12, 0.11, 0.2, 1)
        _ToonThreshold1 ("Toon Threshold1", Range(0, 1)) = 0.1
        _ToonThreshold2 ("Toon Threshold2", Range(0, 1)) = 0.1
        _MidShade ("Mid Shade", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag () : SV_Target
            {
                return float4(0, 0, 0, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One

            CGPROGRAM
            #include "ForwardAdd.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One

            CGPROGRAM
            #include "ForwardAdd.cginc"
            ENDCG
        }

//        Pass
//        {
//            Blend Off
//
//            CGPROGRAM
//            #pragma target 3.5
//            #pragma vertex vert
//            #pragma fragment frag
//
//            struct appdata
//            {
//                float4 vertex : POSITION;
//                float3 normal : NORMAL;
//            };
//
//            struct v2f
//            {
//                float4 pos : SV_POSITION;
//                float4 worldPos : TEXCOORD0;
//                float3 worldNormal : TEXCOORD1;
//            };
//
//            v2f vert (appdata v)
//            {
//                v2f o;
//                o.pos = UnityObjectToClipPos(v.vertex);
//                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
//                o.worldNormal = UnityObjectToWorldNormal(v.normal);
//                return o;
//            }
//
//            float4 _WhiteColor;
//            float4 _BlackColor;
//            float _ToonThreshold1;
//            float _ToonThreshold2;
//            float _MidShade;
//
//            // float4( light num, shadow num, 0, 0)
//            float4 frag (v2f i) : SV_Target
//            {
//                float3 lightDir = _WorldSpaceLightPos0 - i.worldPos;
//                float diffuse = DotClamped(normalize(lightDir), i.worldNormal);
//                float atten = SHADOW_ATTENUATION(i);
//                float shadow = atten * diffuse;
//                if (shadow > 0.5)
//                    return float4(0.1, 0, 0, 0);
//                else
//                    return float4(0, 0.1, 0, 0);
//            }
//            ENDCG
//        }

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