Shader "Unlit/PUCRustLitShader"
{
    Properties
    {
        _MainText ("Texture", 2D) = "white" {}
        _RustText("RustTexture", 2D) = "white" {}

        _RustSelect("RustSelect", Range(-5,5)) = 0.5
        _RustDirection("RustDir", Vector) = (0,0,0,0)

        _WindSelect("WindSelect", Range(0,1)) = 0.5
        _WindForce("WindForce", Range(-0.5, 0.5)) = 0.5
        _WindAddMod("WindAddMod", Range(-1, 1)) = 0.5
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

                //pega as propriedades
                float _WindSelect;
                float _WindForce;
                float _WindAddMod;

                float _RustSelect;
                float4 _RustDirection;

                texture2D _MainText;
                SamplerState sampler_MainText;
                texture2D _RustText;
                SamplerState sampler_RustText;

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
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;

                    float3 position = Input.position.xyz;
                    float oscilation = _WindAddMod - (cos(_Time.w) * _WindForce * Input.position.y);
                    
                    if(Input.color.y > _WindSelect)
                    {
                        position += Input.normal * oscilation;
                    }
                    //Output.positionVAR = Input.position;
                    Output.positionVAR = TransformObjectToHClip(position);

                    Output.uvVAR = Input.uv;
                    Output.normalVAR = Input.normal;// = position

                    //cor do vertex (não é textura)
                    Output.color = Input.color;

                    return Output;
                }
                //var de 4 dimensões: RGBA
                float4 frag(Varyings Input) : SV_TARGET
                {
                    half4 color = Input.color;
                    color += _MainText.Sample(sampler_MainText, Input.uvVAR);

                    float force = clamp(0,1, dot(TransformObjectToWorldNormal(Input.normalVAR), _RustDirection.xyz));
                    /*
                    //corte seco, separando as duas texturas
                    if(dot(Input.normalVAR, _RustDirection.xyz) > _RustSelect)
                    {
                        //+= ou *= pra também usar o vertex color
                        color += _MainText.Sample(sampler_MainText, Input.uvVAR);
                    }
                    else
                    {
                        color += _RustText.Sample(sampler_RustText, Input.uvVAR);
                    }
                    */
                    color += _RustText.Sample(sampler_RustText, Input.uvVAR) * force * _RustSelect;

                    //luz principal (direct light)
                    Light l = GetMainLight();
                    //dot é o produto vetorial entre dois vetores
                    float intensity = dot(l.direction, TransformObjectToWorldNormal(Input.normalVAR));

                    return color * intensity;
                }


            //termina o código em HLSL
            ENDHLSL
        }
    }
}
