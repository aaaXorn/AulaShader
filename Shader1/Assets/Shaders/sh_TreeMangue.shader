Shader "Custom/sh_TreeMangue"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("NormalTexture", 2D) = "white" {}
        _NormalForce("NormalForce", Range(-2, 2)) = 1
        _SpecForce("SpecularForce", Range(0, 2)) = 1

        _Color("Color", Color) = (1, 1, 1, 1)

        _WindForce("WindForce", Range(-0.5, 0.5)) = 0.5
        _WindAddMod("WindAddMod", Range(-1, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque"}
        LOD 100

        Pass
        {
            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                float _WindForce;
                float _WindAddMod;

                texture2D _MainTex;
                SamplerState sampler_MainTex;
                texture2D _NormalTex;
                SamplerState sampler_NormalTex;
                float _NormalForce;
                float _SpecForce;

                float4 _Color;

                struct Attributes
                {
                    float4 position : POSITION;
                    half2 uv : TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
                
                struct Varyings
                {
                    float4 positionVAR : SV_POSITION;
                    half2 uvVAR : TEXCOORD0;
                    half4 color : COLOR0;
                    float4 locpositionVAR : COLOR1;
                    half3 normalVAR : NORMAL;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;

                    float3 position = Input.position.xyz;
                    float oscilation = _WindAddMod - (cos(_Time.w) * _WindForce * Input.position.y);
                    
                    position += Input.normal * oscilation;

                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.locpositionVAR = float4(position, 1);
                    Output.uvVAR = Input.uv;
                    Output.normalVAR = TransformObjectToWorldNormal(Input.normal);

                    Output.color = Input.color;

                    return Output;
                }
                
                float4 frag(Varyings Input) : SV_TARGET
                {
                    half4 color = _Color;
                    color *= _MainTex.Sample(sampler_MainTex, Input.uvVAR);

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


            //termina o código em HLSL
            ENDHLSL
        }
    }
}
