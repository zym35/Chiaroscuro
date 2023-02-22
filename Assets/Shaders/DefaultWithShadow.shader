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
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM
            #include "ForwardAdd.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM
            #include "ForwardAdd.cginc"
            ENDCG
        }

        /*
        GrabPass { "_GrabTex" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

           struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            sampler2D _GrabTex;

            float4 frag (v2f i) : SV_Target
            {
                float4 c = tex2Dproj(_GrabTex, i.grabPos);
                if (c.x == 0)
                {
                    return 0;
                }
                else if (c.y == 0)
                {
                    return 1 ;
                }
                else
                {
                    return 0.5;
                }
            }
            ENDCG
        }
        */

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