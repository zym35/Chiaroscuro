Shader "Chiaroscuro/Radial" {
    Properties {
        _MainTex("Texture", 2D) = "white" {}
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_OutlineExtrusion("Outline Extrusion", float) = 0
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineDot("Outline Dot", float) = 0.25
		_OutlineDot2("Outline Dot Distance", float) = 0.5
		_OutlineSpeed("Outline Dot Speed", float) = 50.0
		_SourcePos("Source Position", vector) = (0, 0, 0, 0)
    }
    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct appdata {
                float4 vertex : POSITION;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float4 objScreenPos : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };
            
            float4 _OutlineColor;
			float  _OutlineSize;
			float  _OutlineExtrusion;
			float  _OutlineDot;
			float  _OutlineDot2;
			float  _OutlineSpeed;
			float4 _SourcePos;
            
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float4 objClipPos = UnityObjectToClipPos(float4(0,0,0,1));
 
                // -1 to 1 range edge to edge
                o.objScreenPos = ComputeScreenPos(objClipPos);
                o.objScreenPos /= o.objScreenPos.w;
                o.screenPos = ComputeScreenPos(o.pos);
                o.screenPos /= o.screenPos.w;
                
                return o;
            }
            
            float4 frag (v2f i) : SV_Target {
                float2 vec = i.screenPos.xy - i.objScreenPos.xy;
            	clip(length(vec) - 0.1);
				float v = atan2(vec.y, vec.x);
            	float strip = frac(v * _OutlineDot);
				clip(strip - 0.5);
                return strip;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
