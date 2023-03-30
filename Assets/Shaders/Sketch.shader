Shader "Chiaroscuro/Sketch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Scale", Range(0.0, 0.1)) = 0.01
        _Fps ("Frame Rate", Float) = 12.0
        _EdgeLength ("Edge length", Float) = 80
        _Color ("Color", color) = (1,1,1,0)
    }
    SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:vert tessellate:tessEdge nolightmap
            #pragma target 4.6
            #include "Tessellation.cginc"

            float3 hash33(float3 p)
            {
               float3 p3 = frac(p * float3(.1031, .1030, .0973));
               p3 += dot(p3, p3.yzx + 33.33);
               return frac((p3.xxy + p3.yzz) * p3.zyx); 
            }

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            float _EdgeLength;

            float4 tessEdge (appdata v0, appdata v1, appdata v2)
            {
                return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
            }
            
            float _Scale;
            float _Fps;

            void vert (inout appdata v)
            {
                float3 delta = hash33(v.vertex.xyz + floor(_Time.yyy * _Fps)) - 0.5;
                float3 newVert = v.vertex + delta * _Scale;
                v.vertex.xyz = newVert;
            }

            struct Input {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutput o) {
                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
            }
            ENDCG
        }
        FallBack "Diffuse"
}
