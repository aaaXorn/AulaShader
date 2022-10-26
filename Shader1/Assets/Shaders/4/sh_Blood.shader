Shader "Custom/sh_Blood"
{
    Properties
    {
        _MainText ("Texture", 2D) = "white" {}
        _BloodText("BloodTexture", 2D) = "white" {}

        _AddVertexColor("AddVertexColor", int) = 0

        _BloodAlpha("BloodAlpha", Range(0,1)) = 1
        _BloodPosition("BloodPosition", Range(-1,1)) = 0
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
                texture2D _BloodText;
                SamplerState sampler_BloodText;

                float _BloodAlpha;
                float _BloodPosition;

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

                    return Output;
                }

                float4 frag(Varyings Input) : SV_TARGET
                {
                    //vertex color (não aparece na Unity)
                    half4 v_color = Input.color;
                    //color que aparece na Unity
                    half4 color = half4(0,0,0,0);

                    //v_color.xyz é a cor do vertex RGB
                    //Input.normalVAR.xyz é a posição na normal do modelo
                    if(v_color.x > 0.5 && Input.normalVAR.y > _BloodPosition)
                    {
                        color = lerp(_MainText.Sample(sampler_MainText, Input.uvVAR), _BloodText.Sample(sampler_BloodText, Input.uvVAR), _BloodAlpha);
                    }
                    else
                    {
                        color = _MainText.Sample(sampler_MainText, Input.uvVAR);
                    }
                    

                    Light l = GetMainLight();
                    float intensity = dot(l.direction, TransformObjectToWorldNormal(Input.normalVAR));
                    
                    return color * intensity;
                }
            ENDHLSL
        }
    }
}
