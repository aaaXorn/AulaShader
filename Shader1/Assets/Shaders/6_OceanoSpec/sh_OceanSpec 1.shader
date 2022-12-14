Shader "Custom/sh_OceanSpec"
{
    //https://catlikecoding.com/unity/tutorials/flow/waves/
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("Normal", 2D) = "white" {}
        _NormalForce("NormalForce", Range(-2, 2)) = 1
        _SpecForce("SpecularForce", Range(-2, 2)) = 1


        _WaveColor("WaveColor", Color) = (1, 1, 1, 1)
        _WaveAmplitude("WaveAmplitude", float) = 1
        _WaveLength("WaveLength", float) = 10
        _WaveSpeed("WaveSpeed", float) = 1
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
                float4 _MainTex_ST;
                texture2D _NormalTex;

                SamplerState sampler_NormalTex;
                float _NormalForce;

                float _SpecForce;
                
                float4 _WaveColor;
                float _WaveAmplitude;
                float _WaveLength;
                float _WaveSpeed;
                

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
                    float4 locpositionVAR : COLOR1;
                    half2 uvVAR       : TEXCOORD0;
                    half3 normalVAR : NORMAL;
                    half4 colorVAR : COLOR0;
                };

                Varyings vert(Attributes Input)
                {
                    Varyings Output;
                    float3 position = Input.position.xyz;

                    //wave position
                    float length = 2 * 3.14159265f / _WaveLength;
                    float oscillation = length * (position.x - _WaveSpeed * _Time.y);
                    position.x += cos(oscillation) * _WaveAmplitude;
                    position.y += sin(oscillation) * _WaveAmplitude;
                    //normal
                    float3 tangent = normalize(float3(1 - length * _WaveAmplitude * sin(oscillation),
                                               length * _WaveAmplitude * cos(oscillation), 0));
                    float3 normal = float3(-tangent.y, tangent.x, 0);

                    Output.positionVAR = TransformObjectToHClip(position);
                    Output.locpositionVAR = float4(position, 1);
                    Output.uvVAR = (Input.uv * _MainTex_ST.xy + _MainTex_ST.zw);//tiling
                    Output.colorVAR = _WaveColor;//Input.color;

                    Output.normalVAR = TransformObjectToWorldNormal(normal);

                    return Output;
                }

                half4 frag(Varyings Input) :SV_TARGET
                { 
                    half4 color = Input.colorVAR;
                    
                    Light l = GetMainLight();

                    half4 normalmap = _NormalTex.Sample(sampler_NormalTex, half2(_Time.x+Input.uvVAR.x, Input.uvVAR.y)) * 2 - 1;
                    half4 normalmap2 = _NormalTex.Sample(sampler_NormalTex, half2(Input.uvVAR.x, _Time.x + Input.uvVAR.y)) * 2 - 1;
                  
                    normalmap *= normalmap2;
                    float intensity = dot(l.direction, Input.normalVAR + normalmap.xzy * _NormalForce);

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
                    //color *= _MainTex.Sample(sampler_MainTex, Input.uvVAR);
                    //color *= intensity;
                    return color;
                }

            ENDHLSL
        }
    }
}
