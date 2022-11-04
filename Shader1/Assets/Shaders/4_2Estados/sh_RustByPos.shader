Shader "Custom/sh_RustByPos"
{
    Properties
    {
        _MainText ("Texture", 2D) = "white" {}
        _RustText("RustTexture", 2D) = "white" {}

        _RustDirection("RustDirection", Vector) = (0,0,0,0)
        _RustStartPoint("RustStartPoint", Vector) = (0,0,0,0)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque"}
        LOD 100

        Pass
        {
            //muda a linguagem pro HLSL
            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                texture2D _MainText;
                SamplerState sampler_MainText;
                texture2D _RustText;
                SamplerState sampler_RustText;

                float4 _RustDirection;
                float4 _RustStartPoint;

                struct Attributes
                {
                    //:POSITION é uma diretiva de pós compilação
                    float4 position : POSITION;
                    //half é menos preciso que float, mas mais otimizado
                    half2 uv : TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
                
                struct Varyings
                {
                    float4 positionVAR : SV_POSITION;
                    half2 uvVAR : TEXCOORD0;
                    half4 color : COLOR0;

                    half3 normalVAR : NORMAL;

                    //posição do objeto em world position
                    float4 worldPositionVAR : TEXCOORD1;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;

                    float3 position = Input.position.xyz;

                    Output.positionVAR = TransformObjectToHClip(position);

                    Output.uvVAR = Input.uv;
                    Output.normalVAR = Input.normal;

                    Output.color = Input.color;

                    //pega a posição do vertex na cena
                    Output.worldPositionVAR = mul(unity_ObjectToWorld, Input.position);

                    return Output;
                }

                float4 frag(Varyings Input) : SV_TARGET
                {
                    half4 color = Input.color;
                    //color += _MainText.Sample(sampler_MainText, Input.uvVAR);

                    if(Input.worldPositionVAR.x > _RustStartPoint.x)
                        color += _RustText.Sample(sampler_RustText, Input.uvVAR);
                    else
                        color += _MainText.Sample(sampler_MainText, Input.uvVAR);

                    Light l = GetMainLight();
                    float intensity = dot(l.direction, TransformObjectToWorldNormal(Input.normalVAR));
                    
                    return color * intensity;
                }
            ENDHLSL
        }
    }
}
