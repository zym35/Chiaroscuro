Shader "Chiaroscuro/SurfaceToon"
{
    Properties
    {
        _WhiteColor ("White Color", Color) = (1,1,1,1)
        _BlackColor ("Black Color", Color) = (1,1,1,1)
        _ToonThreshold ("Toon Threshold", Range(0, 1)) = 0.1
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ToonToggle ("Toon Toggle", Range(0, 1)) = 1
        _TorchPos ("Torch Position", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows finalcolor:fin
        #pragma target 3.5

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        fixed4 _WhiteColor, _BlackColor;
        float _ToonThreshold;
        float _ToonToggle;
        float4 _TorchPos;

        float Lum (in float3 col)
        {
            float lum = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
            return lum;
        }
        
        float Toon (in float lum)
        {
            float toon = step(_ToonThreshold, lum);
            return toon;
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            // falloff
            float lightDist = length(_TorchPos - IN.worldPos);
            c.a *= 1.0f - smoothstep(5.0f, 10.0f, lightDist);
            
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        
        void fin (Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            float l = Lum(color.xyz);
            float toon = l;
            if (_ToonToggle == 1)
                toon = Toon(l);

            color = lerp(_BlackColor, _WhiteColor, l);
            float4 toonColor = lerp(_BlackColor, _WhiteColor, toon);
            color = lerp(toonColor, color, o.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
