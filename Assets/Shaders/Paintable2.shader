Shader "Custom/Paintable2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert fullforwardshadows vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
        float3 _PainterPos;

        struct Input
        {
            float2 uv_MainTex;
            float4 color : Color;
            float3 worldPos;
            float3 worldNormal;
        };

        fixed4 _Color;

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input,o);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            float3 v = IN.worldPos - _PainterPos;
            float d = dot(v, IN.worldNormal);
            float sin = sqrt(1 - d * d);
            float dist = sin * length(v);
            float mask = step(distance(_PainterPos, IN.worldPos), 1);
            
            o.Albedo = mask;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
