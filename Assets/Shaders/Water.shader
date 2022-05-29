Shader "Custom/Water"
{
    Properties
    {
        [Header(Threshold)]
        _Depth ("Depth", Float) = 1
        _Strength ("Strength", Float) = 1
        _FoamThreshold ("Foam Threshold", Float) = 1

        [Header(Color)]
        _SurfaceColor ("SurfaceColor", Color) = (1,1,1,1)
        _DeepColor ("DeepColor", Color) = (0.09, 0.13, 0.47, 1)

        [Header(Wave)]
        [NoScaleOffset] _WaveNormal1 ("Wave Normal Main", 2D) = "bump" {}
        _WaveSpeed1 ("Wave Speed Main", Float) = 1
        _WaveScale1 ("Wave Scale Main", Float) = 1
        _WaveStrength1 ("Wave Strength Main", Float) = 1
        [NoScaleOffset] _WaveNormal2 ("Wave Normal Secondary", 2D) = "bump" {}
        _WaveSpeed2 ("Wave Speed Secondary", Float) = 1
        _WaveScale2 ("Wave Scale Secondary", Float) = 1
        _WaveStrength2 ("Wave Strength Secondary", Float) = 1

        [Header(Refraction)]
        _RefractionStrength ("Refraction Strength", Float) = 1

        [Header(Foam)]
        [NoScaleOffset] _FoamTexture ("Foam texture", 2D) = "white" {}
        _FoamTextureScale ("Foam Texture Scale", Float) = 1
        _FoamTextureSpeed ("Foam texture speed", Float) = 1
        _FoamIntensity ("Foam intensity", Float) = 1

        [Header(Surface)]
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _DisplacementAmplitude ("Displacement Amplitude", Float) = 1
        _DisplacementFrequency ("Displacement Frequency", Float) = 1
        _DisplacementSpeed ("Displacement Speed", Float) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass{
            "_GrabTexture"
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha:premul novertexlights nolightmap vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float2 uv_WaveNormal1;
            float2 uv_WaveNormal2;
            float2 uv_FoamTexture;
            float2 uv_GrabTexture;
            float2 worldPos;
            float4 screenPos;
        };

        sampler2D _CameraDepthTexture;
        float _Depth;
        float _Strength;
        float4 _SurfaceColor, _DeepColor;
        sampler2D _WaveNormal1, _WaveNormal2;
        float _WaveSpeed1, _WaveSpeed2;
        float _WaveScale1, _WaveScale2;
        float _WaveStrength1, _WaveStrength2;
        float _RefractionStrength;
        sampler2D _FoamTexture;
        float _FoamTextureScale;
        float _FoamTextureSpeed;
        float _FoamThreshold;
        float _FoamIntensity;
        float _Glossiness;
        sampler2D _GrabTexture;
        float _DisplacementAmplitude;
        float _DisplacementFrequency;
        float _DisplacementSpeed;

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            float delta = sin(_Time.y * _DisplacementSpeed + v.vertex.x * 6.28 * _DisplacementFrequency) * _DisplacementAmplitude;
            v.vertex.z += delta;
        }

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            //distance diff
            float depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.screenPos);
            float depth = LinearEyeDepth(depthSample);
            float4 screenPosW = i.screenPos.w;
            float colorDiff = saturate(depth - (screenPosW + _Depth) * _Strength);
            float foamDiff = saturate((depth - screenPosW) / _FoamThreshold);

            //color
            float4 baseColor = lerp(_SurfaceColor, _DeepColor, colorDiff);

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

            //refraction
            float2 refractionUV = normal * _RefractionStrength * 0.1 + float2(i.screenPos.xy / i.screenPos.w) ;
            float3 refraction = tex2D(_GrabTexture, refractionUV);

            //foam
            float foamTex = tex2D(_FoamTexture, i.uv_FoamTexture * _FoamTextureScale + movementTimeParam * _FoamTextureSpeed);
            float foam = step(foamTex, 1 - foamDiff);

            o.Albedo = lerp(baseColor, refraction * baseColor, colorDiff);
            o.Alpha = 1;
            o.Normal = normal;
            o.Smoothness = _Glossiness;
            o.Emission = foam * _FoamIntensity;
        }
        ENDCG
    }
}