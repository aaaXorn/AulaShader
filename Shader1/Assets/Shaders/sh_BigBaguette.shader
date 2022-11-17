Shader "Custom/sh_BigBaguette"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("NormalTexture", 2D) = "white" {}
        _NormalForce("NormalForce", Range(-2, 2)) = 1
        _SpecForce("SpecularForce", Range(0, 2)) = 1

        _SnowTex ("SnowTexture", 2D) = "white" {}
        _SnowNormalTex("SnowNormalTexture", 2D) = "white" {}

        _Color("Color", Color) = (1, 1, 1, 1)
        _SnowColor("SnowColor", Color) = (1,1,1,1)

        _SnowStart("SnowStart", float) = 1
        _SnowDirection("SnowDirection", Vector) = (0,0,0,0)
        _SnowDeform("SnowSineDeform", float) = 0.1
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

                texture2D _SnowTex;
                SamplerState sampler_SnowTex;
                texture2D _SnowNormalTex;
                SamplerState sampler_SnowNormalTex;

                float4 _Color;
                float4 _SnowColor;

                float _SnowStart;
                float4 _SnowDirection;
                float _SnowDeform;

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

                    float4 worldPositionVAR : TEXCOORD1;
                };

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

                    Output.worldPositionVAR = mul(unity_ObjectToWorld, Input.position);

                    return Output;
                }

                half4 frag(Varyings Input) :SV_TARGET
                { 
                    float distort = sin(Input.worldPositionVAR.x * _SnowDeform + _Time.w) * _SnowDeform;
                    bool isSnow = dot(Input.normalVAR, _SnowDirection) < _SnowStart - distort;
                    half4 color = isSnow ? _SnowColor : _Color;
                    //half4 color = Input.colorVAR;
                    
                    Light l = GetMainLight();

                    half4 normalmap = (0,0,0,0);
                    if(!isSnow)
                        normalmap = _NormalTex.Sample(sampler_NormalTex, Input.uvVAR) * 2 - 1;
                    else
                        normalmap = _SnowNormalTex.Sample(sampler_SnowNormalTex, Input.uvVAR) * 2 - 1;

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
                    if(!isSnow)
                        color *= _MainTex.Sample(sampler_MainTex, Input.uvVAR);
                    else
                        color *= _SnowTex.Sample(sampler_SnowTex, Input.uvVAR);
                    color += float4(specularReflection, 0) * 0.05;
                    return color;
                }



            ENDHLSL
        }
    }
}
