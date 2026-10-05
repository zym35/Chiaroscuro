Shader "Chiaroscuro/TexturePainter"
{   
    Properties
    {
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Off

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float3 _PainterPosition;
            float _Radius;
            float _Hardness;
            float _Strength;

            struct appdata
            {
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            float mask (float3 position, float3 center, float radius, float3 normal)
            {
                float3 v = center - position;
                float d = dot(v, normal);
                float sin = sqrt(1 - d * d);
                float dist = sin * length(v);
                return step(distance(position, center), radius);
            }

            v2f vert (appdata v)
            {
                v2f o;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
				float4 uv = float4(0, 0, 0, 1);
                uv.xy = (v.uv * 2 - 1) * float2(1, _ProjectionParams.x);
				o.vertex = uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float f = mask(i.worldPos, _PainterPosition, _Radius, normalize(i.worldNormal));
                float edge = f * _Strength;
                return lerp(col, 1, edge - 0.2);
            }
            ENDCG
        }
    }
}