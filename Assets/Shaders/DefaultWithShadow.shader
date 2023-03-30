Shader "Chirascuro/DefaultWithShadow"
{
    Properties
    {
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase"}

            CGPROGRAM
            #include "ShadowForwardBase.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            //Blend One OneMinusSrcAlpha
            //ZWrite Off

            CGPROGRAM
            #include "ForwardAdd.cginc"
            ENDCG
        }
        
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            //Blend One OneMinusSrcAlpha
            //ZWrite Off

            CGPROGRAM
            #include "ForwardAdd.cginc"
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