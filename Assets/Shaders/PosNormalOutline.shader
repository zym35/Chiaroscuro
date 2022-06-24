// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/PosNormalOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _NormalStrength ("Normal Strength", Float) = 1
        _DistStrength ("Distance Strength", Float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityStandardBRDF.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
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

            ///https://en.wikipedia.org/wiki/Pairing_function
            float GetCantorValue(in float a, in float b)
            {
                float pi = 0.5 * (a + b) * (a + b + 1) + b;
                return pi;
            }

            float3 GetCantorValue(in float3 a, in float3 b)
            {
                float3 pi = float3(GetCantorValue(a.x, b.x), GetCantorValue(a.y, b.y), GetCantorValue(a.z, b.z));
                return pi;
            }

            float2 ProjectOntoPlane(in float3 v, in float3 n)
            {
                return v - dot(v, normalize(n));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                float viewDistance = length(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));
                //float zDepth = o.vertex.z / o.vertex.w;

                //same as mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz
                //loat3 origin = unity_ObjectToWorld._m03_m13_m23;
                //float3 area = _Area.xxx;

                //float3 norm = UnityObjectToWorldNormal(v.normal);
                float2 norm = mul(unity_MatrixVP, UnityObjectToWorldNormal(v.normal));
                //float3 norm = mul(unity_WorldToCamera, mul(unity_ObjectToWorld, v.normal));
                //float3 norm = mul(unity_CameraProjection, mul(unity_MatrixVP, mul(unity_ObjectToWorld, v.normal)));
                //float3 cameraDir = mul((float3x3)UNITY_MATRIX_V,float3(0,0,1));
                //float2 norm = ProjectOntoPlane(UnityObjectToWorldNormal(v.normal), cameraDir);

                norm *= _NormalStrength * 0.1;
                viewDistance *= _DistStrength * 0.01;

                o.color = float3(norm.xy, 0);
                //o.color = viewDistance;
                o.color = frac(o.color);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return float4(i.color, 1);
            }
            ENDCG
        }
    }
}