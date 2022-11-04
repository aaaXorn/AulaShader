Shader "Unlit/EspadosUnibos"
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
                    float stripe = 1.0/13.0;
                    float rect_y = 7.0/13.0;
                    float rect_x = 7.0/13.0;

                    float4 color = float4(0.3, 0.0, 0.0, 1.0);
                    /*if(Input.uvVAR.y > 0.5)
                        color = float4(0.0, 0.3, 0.0, 1.0);*/
                    if(Input.uvVAR.y < rect_y || Input.uvVAR.x > rect_x)
                    {
                        for(float i = 0.0; i <= 12.0; i += 1.0)
                        {
                            if(Input.uvVAR.y > i * stripe && Input.uvVAR.y < (i + 1.0) * stripe)
                            {
                                if(i % 2 == 0)
                                    color = float4(0.0, 0.3, 0.0, 1.0);
                                else
                                    color = float4(0.0, 0.0, 0.3, 1.0);
                            }
                        }
                    }

                    return color;
                }


            //termina o código em HLSL
            ENDHLSL
        }
    }
}
