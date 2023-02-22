Shader "Chiaroscuro/Monocular" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Radius ("Radius", Range(0.0, 1.0)) = 0.5
        _Distortion ("Distortion", Range(-1.0, 1.0)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Radius;
            float _Distortion;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 uv = i.uv - 0.5;
                float dist = length(uv);

                if (dist > _Radius) {
                    discard;
                }

                float2 offset = uv * _Distortion * (1.0 - (dist / _Radius));

                float2 distortedUv = i.uv + offset;

                fixed4 col = tex2D(_MainTex, distortedUv);

                return col;
            }
            ENDCG
        }
    }
}