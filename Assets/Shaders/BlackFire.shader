Shader "Chiaroscuro/BlackFire" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Range(0.1, 3)) = 1
        _Intensity ("Intensity", Range(0.1, 3)) = 1
    }

    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        LOD 100

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        float _Speed;
        float _Intensity;

        struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o) {
            half4 tex = tex2D(_MainTex, IN.uv_MainTex);
            float noise = _Intensity * (tex.r + tex.g + tex.b) * 0.33;
            float time = _Time.y * _Speed;
            float dynamicNoise = _Intensity * (tex2D(_MainTex, IN.uv_MainTex + float2(time, time)).r - 0.5);

            
            o.Albedo = noise + dynamicNoise;
            o.Alpha = 0.5;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
