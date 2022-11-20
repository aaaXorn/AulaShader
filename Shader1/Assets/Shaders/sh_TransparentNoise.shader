Shader "Custom/sh_TransparentNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color("Color", Color) = (1, 1, 1, 1)

        _NoiseTarget("NoiseTarget", float) = 0.1
        _NoiseScale("NoiseScale", float) = 1
        _NoiseSpd("NoiseSpeed", float) = 1

        _RainbowUVMod("RainbowUVModifier", float) = 1
        _RainbowSinMod("RainbowTimeModifier", float) = 1
        _RainbowMixMod("RainbowMixModifier", float) = 1
    }
        SubShader
        {
            Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType" = "Transparent" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull front 
            LOD 100
            Pass
            {
                HLSLPROGRAM
                    #pragma vertex vert alpha
                    #pragma fragment frag alpha
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

               
                texture2D _MainTex;
                SamplerState sampler_MainTex;

                float4 _Color;
                float4 _Transp = float4(0,0,0,0);

                float _NoiseTarget;
                float _NoiseScale;
                float _NoiseSpd;

                float _RainbowUVMod;
                float _RainbowSinMod;
                float _RainbowMixMod;

                struct Attributes
                {
                    float4 position : POSITION;
                    half2 uv       : TEXCOORD0;
                    half4 color : COLOR;
                };
            
                struct Varyings 
                {
                    float4 positionVAR : SV_POSITION;
                    float4 locpositionVAR : COLOR1;
                    half2 uvVAR       : TEXCOORD0;
                    half4 colorVAR : COLOR0;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;
                    float3 position = Input.position.xyz;
                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.locpositionVAR = float4(position, 1);
                    Output.uvVAR = Input.uv;
                    Output.colorVAR = _Color;

                    return Output;
                }

                float2 unity_gradientNoise_dir(float2 p)
                {
                    p = p % 289;
                    float x = (34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                float unity_gradientNoise(float2 p)
                {
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(unity_gradientNoise_dir(ip), fp);
                    float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
                }
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    Out = unity_gradientNoise(UV * Scale) + 0.5;
                }

                float4 rainbow(float level)
                {
                    float r = float(level <= 2.0) + float(level > 4.0) * 0.5;
                    float g = max(1.0 - abs(level - 2.0) * 0.5, 0.0);
                    float b = (1.0 - (level - 4.0) * 0.5) * float(level >= 4.0);
                    return float4(r, g, b, 1);
                }

                half4 frag(Varyings Input) :SV_TARGET
                { 
                    half4 color = Input.colorVAR;
                    
                    float noise = 0;
                    float2 uvNoise = float2(Input.uvVAR.x + _Time.w * _NoiseSpd, Input.uvVAR.y);
                    Unity_GradientNoise_float(uvNoise, _NoiseScale, noise);

                    if(noise < _NoiseTarget)
                    {
                        float pos = Input.uvVAR.x * _RainbowUVMod + _Time.y * _RainbowSinMod;
                        float4 clr = rainbow(abs(sin(pos) * 5));
                        clr = (clr + rainbow(abs(sin(pos + _RainbowMixMod) * 5))) / 2;
                        color *= clr;

                        color *= _MainTex.Sample(sampler_MainTex, Input.uvVAR);
                    }
                    else
                        color = _Transp;

                    return color;
                }


            ENDHLSL
        }
    }
}
