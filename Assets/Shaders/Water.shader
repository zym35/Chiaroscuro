Shader "Custom/Water"
{
    Properties
    {
        _Depth ("Depth", Float) = 1
        _Strength ("Strength", Float) = 1
        _SurfaceColor ("SurfaceColor", Color) = (1,1,1,1)
        _DeepColor ("DeepColor", Color) = (0.09, 0.13, 0.47, 1)
        _WaveNormal1 ("Wave Normal Main", 2D) = "bump" {}
        _WaveSpeed1 ("Wave Speed Main", Float) = 1
        _WaveScale1 ("Wave Scale Main", Float) = 1
        _WaveStrength1 ("Wave Strength Main", Float) = 1
        _WaveNormal2 ("Wave Normal Secondary", 2D) = "bump" {}
        _WaveSpeed2 ("Wave Speed Secondary", Float) = 1
        _WaveScale2 ("Wave Scale Secondary", Float) = 1
        _WaveStrength2 ("Wave Strength Secondary", Float) = 1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha noshadow novertexlights nolightmap vertex:vert nofog

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _CameraDepthTexture;
        float _Depth;
        float _Strength;
        float4 _SurfaceColor, _DeepColor;
        sampler2D _WaveNormal1, _WaveNormal2;
        float _WaveSpeed1, _WaveSpeed2;
        float _WaveScale1, _WaveScale2;
        float _WaveStrength1, _WaveStrength2;
        float _Glossiness;

        struct Input
        {
            float2 uv_WaveNormal1;
            float2 uv_WaveNormal2;
            float depth;
            float4 screenPos;
        };

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            COMPUTE_EYEDEPTH(o.depth);
            o.screenPos = ComputeScreenPos(v.vertex);
        }

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            //color
            float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.screenPos);
            float depth = LinearEyeDepth(depthSample).r;
            float4 screenPosW = i.screenPos.w;

            float distance = saturate((depth - (screenPosW + _Depth)) * _Strength);
            float4 baseColor = lerp(_SurfaceColor, _DeepColor, distance);

            //normal
            float movementTimeParam = _Time.y * 0.01;
            float2 waveUV1 = _WaveScale1 * i.uv_WaveNormal1 + _WaveSpeed1 * movementTimeParam;
            float2 waveUV2 = _WaveScale2 * i.uv_WaveNormal2 + _WaveSpeed2 * movementTimeParam * -1;

            //sample
            float3 normalSample1 = UnpackNormal(tex2D(_WaveNormal1, waveUV1));
            float3 normalSample2 = UnpackNormal(tex2D(_WaveNormal2, waveUV2));

            //strength
            float3 normalAdjusted1 = float3 (normalSample1.rg * _WaveStrength1, lerp(1, normalSample1.b, saturate(_WaveStrength1)));
            float3 normalAdjusted2 = float3 (normalSample2.rg * _WaveStrength2, lerp(1, normalSample2.b, saturate(_WaveStrength2)));

            //blend
            float3 normal = normalize(float3(normalAdjusted1.rg + normalAdjusted2.rg, normalAdjusted1.b * normalAdjusted2.b));

            o.Albedo = baseColor.rgb;
            o.Alpha = baseColor.a;
            o.Normal = normal;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}