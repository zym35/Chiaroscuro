Shader "Custom/DitheredMonotone" {
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DitherThreshold ("Dither Threshold", Range(0, 1)) = 0.5
        _DitherScale ("Dither Scale", Range(1, 100)) = 10
    }

    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        LOD 100

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        float _Glossiness;
        float _Metallic;
        float _DitherThreshold;
        float _DitherScale;
        fixed4 _Color;

        struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;

            // Dithering
            float dither = (tex2D(_MainTex, IN.uv_MainTex * _DitherScale).r - _DitherThreshold) * _DitherScale;
            o.Emission = _Color.rgb * dither;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
