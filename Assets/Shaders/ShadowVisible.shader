Shader "Custom/ShadowVisible" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGPROGRAM
        #pragma surface surf Lambert fullforwardshadows

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
            float4 shadowCoord;
            float4 screenPos;
        };

        #include "Shadows.cginc"

        void surf (Input IN, inout SurfaceOutput o) {
            float shadow = GetSunShadowsAttenuation(IN.worldPos, 0);
            
            o.Albedo= shadow;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
