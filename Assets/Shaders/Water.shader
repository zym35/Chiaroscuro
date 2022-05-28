Shader "Custom/Water"
{
    Properties
    {
        _Depth ("Depth", Float) = 1
        _Strength ("Strength", Float) = 1
        _SurfaceColor ("SurfaceColor", Color) = (1,1,1,1)
        _DeepColor ("DeepColor", Color) = (0.09, 0.13, 0.47, 1)
        _WaveNormalMain ("Wave Normal Main", 2D) = "bump" {}
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

        sampler2D _WaveNormalMain;
        sampler2D _CameraDepthTexture;
        float _Depth;
        float _Strength;
        float4 _SurfaceColor, _DeepColor;
        float _Glossiness;

        struct Input
        {
            float2 uv;
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
            float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.screenPos);
            float depth = LinearEyeDepth(depthSample).r;
            float4 screenPosW = i.screenPos.w;

            float distance = saturate((depth - (screenPosW + _Depth)) * _Strength);
            float4 baseColor = lerp(_SurfaceColor, _DeepColor, distance);

            o.Albedo = baseColor.rgb;
            o.Alpha = baseColor.a;
            o.Smoothness = _Glossiness;
        }
        ENDCG   
    }
    FallBack "Diffuse"
}