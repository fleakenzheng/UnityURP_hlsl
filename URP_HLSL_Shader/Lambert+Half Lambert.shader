Shader "URPshader/UnlitShader"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" 
        "IgnoreProjector" = "True"
         "RenderPipeline" = "UniversalPipeline"
          }
        LOD 100

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)

            half4 _MainTex_ST;
            half4 _BaseColor;

            CBUFFER_END
            

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float3  normalWS :TEXCOORD1;
                
            };

            

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                o.pos = TransformWorldToHClip(v.vertex.xyz);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            half4 frag (vertexOutput i) : SV_Target
            {   half2 texcoord = i.texcoord;
                Light light = GetMainLight();
                light.color = _MainLightColor.rgb;
                light.dirWS =  _MainLightPosition.xyz;
                half4 Tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                // sample the texture
                float Lambert =normalize(saturate(dot(_MainLightPosition.xyz, i.normalWS))) ;
                float HalfLambert = Lambert * 0.5 + 0.5;
                
                float finalRGB = Lambert *_MainTex * _MainLightColor.rgb * _BaseColor ;
            //    float finalRGB = HalfLambert *_MainTex * _MainLightColor.rgb * _BaseColor ;

                return float4(finalRGB,1);
            }
            ENDHLSL
        }
    }
}
