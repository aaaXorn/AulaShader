Shader "Custom/sh_LSD"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("NormalTexture", 2D) = "white" {}
        _NormalForce("NormalForce", Range(-2, 2)) = 1
        _SpecForce("SpecularForce", Range(0, 2)) = 1

        _Color("InitialColor", Color) = (1, 1, 1, 1)

        _RainbowUVMod("RainbowUVModifier", float) = 1
        _RainbowSinMod("RainbowTimeModifier", float) = 1
        _RainbowMixMod("RainbowMixModifier", float) = 1
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100
            Pass
            {
                HLSLPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

               
                texture2D _MainTex;
                SamplerState sampler_MainTex;
                texture2D _NormalTex;
                SamplerState sampler_NormalTex;
                float _NormalForce;
                float _SpecForce;

                float4 _Color;

                float _RainbowUVMod;
                float _RainbowSinMod;
                float _RainbowMixMod;

                struct Attributes
                {
                    float4 position : POSITION;
                    half2 uv       : TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
            
                struct Varyings 
                {
                    float4 positionVAR : SV_POSITION;
                    float4 locpositionVAR : COLOR1;
                    half2 uvVAR       : TEXCOORD0;
                    half3 normalVAR : NORMAL;
                    half4 colorVAR : COLOR0;
                };

                float4 rainbow(float level)
                {
                    float r = float(level <= 2.0) + float(level > 4.0) * 0.5;
                    float g = max(1.0 - abs(level - 2.0) * 0.5, 0.0);
                    float b = (1.0 - (level - 4.0) * 0.5) * float(level >= 4.0);
                    return float4(r, g, b, 1);
                }

                Varyings vert(Attributes Input)
                {
                    Varyings Output;
                    float3 position = Input.position.xyz;
                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.locpositionVAR = float4(position, 1);
                    Output.uvVAR = Input.uv;
                    //Output.colorVAR = Input.color;
                    Output.colorVAR = _Color;
                    Output.normalVAR = TransformObjectToWorldNormal(Input.normal);

                    return Output;
                }

                half4 frag(Varyings Input) :SV_TARGET
                { 
                    half4 color = Input.colorVAR;

                    float pos = Input.uvVAR.x * _RainbowUVMod + _Time.y * _RainbowSinMod;
                    float4 clr = rainbow(abs(sin(pos) * 5));
                    clr = (clr + rainbow(abs(sin(pos + _RainbowMixMod) * 5))) / 2;
                    color *= clr;
                    
                    Light l = GetMainLight();

                    half4 normalmap= _NormalTex.Sample(sampler_NormalTex, Input.uvVAR) * 2 - 1;

                    float intensity = dot(l.direction, Input.normalVAR+ normalmap.xzy * _NormalForce);

                    float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, Input.locpositionVAR).xyz);

                    float3 specularReflection;

                    if(intensity < 0.0)
                    {
                        specularReflection = float3(0.0, 0.0, 0.0);
                    }
                    else
                    {
                        specularReflection = l.color * pow(max(0.0, dot(
                                             reflect(-l.direction, Input.normalVAR + normalmap.xzy),
                                             viewDirection)), _SpecForce);
                    }

                    color *= clamp(0, 1, intensity);
                    color *= _MainTex.Sample(sampler_MainTex, Input.uvVAR);
                    color += float4(specularReflection, 0) * 0.05;

                    return color;
                }

            ENDHLSL
        }
    }
}
