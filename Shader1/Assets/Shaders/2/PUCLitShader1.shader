Shader "Unlit/PUCLitShader1"
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
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                struct Attributes
                {
                    //:POSITION é uma diretiva de pós compilação
                    float4 position : POSITION;
                    float2 uv : TEXCOORD0;
                    half3 normal : NORMAL;
                    half4 color : COLOR;
                };
                
                struct Varyings
                {
                    float4 positionVAR : SV_POSITION;
                    float2 uvVAR : TEXCOORD0;
                    half4 color : COLOR0;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;

                    float oscilation = 0.05 - (cos(_Time.w) * 0.1 * Input.position.z);
                    float3 position = Input.position.xyz + Input.normal * oscilation;
                    //Output.positionVAR = Input.position;
                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.uvVAR = Input.uv;

                    //luz principal (direct light)
                    Light l = GetMainLight();
                    //dot é o produto vetorial entre dois vetores
                    float intensity = dot(l.direction, TransformObjectToWorldNormal(Input.normal));

                    //cor do vertex (não é textura)
                    Output.color = Input.color * intensity;

                    return Output;
                }
                //var de 4 dimensões: RGBA
                float4 frag(Varyings Input) : SV_TARGET
                {
                    float4 color = Input.color;
                    
                    return color;
                }


            //termina o código em HLSL
            ENDHLSL
        }
    }
}
