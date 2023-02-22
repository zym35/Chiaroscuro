Shader "Chiaroscuro/SurfaceToon"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _ToonThreshold2 ("Toon Threshold2", Range(0, 1)) = 0.1
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows finalcolor:fin
        #pragma target 3.5

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
        float _ToonThreshold2;
        
        float4 Toon(in float4 col)
            {
                
                float lum = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
                //float lum = 0.333 * col.r + 0.333 * col.g + 0.333 * col.b;
                float toon = step(_ToonThreshold2, lum);

                return lerp(float4(0.0f, 0.0f, 0.0f, 1.0f), _Color, toon);
                // if (lum > _ToonThreshold2)
                //     return 1;
                // else if (lum < _ToonThreshold1)
                //     return 0;
                // else return _MidShade;
            }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        
        void fin (Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            color = Toon(color);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
