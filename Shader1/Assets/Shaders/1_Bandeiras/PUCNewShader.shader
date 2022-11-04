Shader "Unlit/PUCNewShader"
{
    Properties
    {
        _MainText ("Texture", 2D) = "white" {}
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

                struct Attributes
                {
                    //:POSITION é uma diretiva de pós compilação
                    float4 position : POSITION;
                    float2 uv : TEXCOORD0;
                };
                
                struct Varyings
                {
                    float4 positionVAR : SV_POSITION;
                    float2 uvVAR : TEXCOORD0;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;

                    //Output.positionVAR = Input.position;
                    Output.positionVAR = TransformObjectToHClip(Input.position.xyz);
                    Output.uvVAR = Input.uv;

                    return Output;
                }
                //var de 4 dimensões: RGBA
                float4 frag(Varyings Input) : SV_TARGET
                {
                    float4 color = float4(0.3, 0.0, 0.3, 1.0);
                    if(Input.uvVAR.y > 0.5)
                        color = float4(0.0, 0.3, 0.0, 1.0);

                    return color;
                }


            //termina o código em HLSL
            ENDHLSL
        }
    }
}
