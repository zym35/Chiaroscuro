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

float4 _WhiteColor;
float4 _BlackColor;
float _ToonThreshold1;
float _ToonThreshold2;
float _MidShade;

// float4( light num, shadow num, 0, 0)
float4 frag (v2f i) : SV_Target
{
    float3 lightDir = normalize(_WorldSpaceLightPos0 - i.worldPos);
    float diffuse = DotClamped(lightDir, i.worldNormal);
    float atten = SHADOW_ATTENUATION(i);
    float shadow = atten * diffuse;

    return shadow;
    //return clamp(0, 0.5, shadow);
    // if (shadow > 0.5)
    //     return float4(0.1, 0, 0, 0);
    // else
    //     return float4(0, 0.1, 0, 0);
}