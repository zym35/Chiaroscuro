#pragma target 3.5
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdadd_fullshadows

#include "UnityStandardBRDF.cginc"
#include "AutoLight.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float4 worldPos : TEXCOORD0;
    float3 worldNormal : TEXCOORD1;
    LIGHTING_COORDS(2, 3)
};

v2f vert (appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);

    COMPUTE_LIGHT_COORDS(o);
    TRANSFER_SHADOW(o);
    return o;
}

float4 frag (v2f i) : SV_Target
{
    float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
    float diffuse = DotClamped(lightDir, i.worldNormal);
    float atten = SHADOW_ATTENUATION(i);
    clip(0.5 - atten);

    return (1-atten) * diffuse;
}