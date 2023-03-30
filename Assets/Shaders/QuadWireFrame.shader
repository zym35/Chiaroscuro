Shader "Chiaroscuro/QuadWireFrame"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WireframeColor("Wireframe color", color) = (1.0, 1.0, 1.0, 1.0)
        _OpaqueColor("Opaque color", color) = (1.0, 1.0, 1.0, 1.0)
        _Width("Wireframe Width", float) = 1.5
        _FadeStrength("Distance fade strength", float) = 20
        
        _MaskTexture ("Mask Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            // Removes the back facing triangles.
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // We add our barycentric variables to the geometry struct.
            struct g2f {
                float4 pos : SV_POSITION;
                float3 barycentric : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float4 eyePos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2g vert(appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // This applies the barycentric coordinates to each vertex in a triangle.
            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
                float edgeLengthX = length(IN[1].vertex - IN[2].vertex);
                float edgeLengthY = length(IN[0].vertex - IN[2].vertex);
                float edgeLengthZ = length(IN[0].vertex - IN[1].vertex);
                float3 modifier = float3(0.0, 0.0, 0.0);

                if ((edgeLengthX > edgeLengthY) && (edgeLengthX > edgeLengthZ)) {
                    modifier = float3(1.0, 0.0, 0.0);
                }
                else if ((edgeLengthY > edgeLengthX) && (edgeLengthY > edgeLengthZ)) {
                    modifier = float3(0.0, 1.0, 0.0);
                }
                else if ((edgeLengthZ > edgeLengthX) && (edgeLengthZ > edgeLengthY)) {
                    modifier = float3(0.0, 0.0, 1.0);
                }

                g2f o;
                o.pos = UnityObjectToClipPos(IN[0].vertex);
                o.barycentric = float3(1.0, 0.0, 0.0) + modifier;
                o.eyePos = mul(UNITY_MATRIX_MV, IN[0].vertex);
                o.uv = IN[0].uv;
                triStream.Append(o);
                
                o.pos = UnityObjectToClipPos(IN[1].vertex);
                o.barycentric = float3(0.0, 1.0, 0.0) + modifier;
                o.eyePos = mul(UNITY_MATRIX_MV, IN[1].vertex);
                o.uv = IN[1].uv;
                triStream.Append(o);
                
                o.pos = UnityObjectToClipPos(IN[2].vertex);
                o.barycentric = float3(0.0, 0.0, 1.0) + modifier;
                o.eyePos = mul(UNITY_MATRIX_MV, IN[2].vertex);
                o.uv = IN[2].uv;
                triStream.Append(o);
            }

            fixed4 _WireframeColor;
            fixed4 _OpaqueColor;
            float _FadeStrength;
            float _Width;
            sampler2D _MaskTexture;

            fixed4 frag(g2f i) : SV_Target
            {
                // Calculate the unit width based on triangle size.
                float3 unitWidth = fwidth(i.barycentric);
                // Alias the line a bit.
                float3 aliased = smoothstep(float3(0.0, 0.0, 0.0), unitWidth * _Width, i.barycentric);
                // Use the coordinate closest to the edge.
                float edge = 1 - min(aliased.x, min(aliased.y, aliased.z));

                float depth = -i.eyePos.z;
                float fade = pow(saturate(1 - depth / _FadeStrength), 5);
                float4 col = lerp(_OpaqueColor, _WireframeColor, edge * fade);

                float4 mask = tex2D(_MaskTexture, i.uv);
				return lerp(float4(0, 0, 0, 1), col, mask.x);
            }
            ENDCG
        }
    }
}