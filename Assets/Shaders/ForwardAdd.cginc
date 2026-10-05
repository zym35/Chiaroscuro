#pragma target 3.5
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdadd_fullshadows

#include "UnityStandardBRDF.cginc"
#include "AutoLight.cginc"

sampler2D _MaskTexture;
float4 _MainTex_ST;

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 worldPos : TEXCOORD1;
    float3 worldNormal : TEXCOORD2;
    LIGHTING_COORDS(3, 4)
};

v2f vert (appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

    COMPUTE_LIGHT_COORDS(o);
    TRANSFER_SHADOW(o);
    return o;
}

float4 frag (v2f i) : SV_Target
{
    float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
    float diffuse = DotClamped(lightDir, i.worldNormal);
    
    float atten = SHADOW_ATTENUATION(i);
    //clip(0.5 - atten);
    
    float col = diffuse * atten * LIGHT_ATTENUATION(i);
    float4 mask = tex2D(_MaskTexture, i.uv);

    if (col > 0.8) return 1;
    //return col;
    return lerp(0.1, col, mask);
}