Shader "Chiaroscuro/ObjectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _NormalStrength ("Normal Strength", Float) = 1
        _DistStrength ("Distance Strength", Float) = 1
        _PositionStrength ("Position Strength", FLoat) = 1
    }
    SubShader
    {
        // Pass 1 outline
        Pass
        {
            Tags { "RenderType"="Opaque" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityStandardBRDF.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 color : TEXCOORD1;
            };

            float _NormalStrength;
            float _DistStrength;
            float _PositionStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                float4 ori = mul(unity_ObjectToWorld, float4(0,0,0,1));
                float4 pos = mul(unity_ObjectToWorld, v.vertex);
                float dist = distance(ori, pos);
                
                float3 norm = UnityObjectToWorldNormal(v.normal);
                
                float3 cameraDir = mul((float3x3)unity_CameraToWorld,float3(0,0,1));
                //adjust dist strength
                float viewNormAngle = saturate(pow(dot(cameraDir, norm), 4));
                
                norm *= _NormalStrength * 0.1 * v.color.r;
                dist *= _DistStrength * viewNormAngle * 0.1 * v.color.g;
                float3 position = (ori + 1 / _PositionStrength) * 0.5 * _PositionStrength;
                
                o.color = norm + position + dist;
                o.color = frac(o.color * 10);
                //o.color = viewNormAngle;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return float4(i.color, 1);
            }
            ENDCG
        }
        
        // Pass 2 lighting
//        Tags { "RenderType"="Opaque" }
//
//        CGPROGRAM
//        #pragma surface surf Standard fullforwardshadows
//        #pragma target 3.0
//
//        sampler2D _MainTex;
//
//        struct Input
//        {
//            float2 uv_MainTex;
//        };
//
//        void surf (Input IN, inout SurfaceOutputStandard o)
//        {
//            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
//            o.Albedo = c.rgb;
//        }
//        ENDCG
    }
    FallBack "Diffuse"
}