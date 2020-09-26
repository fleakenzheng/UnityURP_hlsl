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
                float2 texcoord : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                
            };

            

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                o.pos = TransformWorldToHClip(v.vertex.xyz);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            half4 frag (vertexOutput i) : SV_Target
            {   half2 texcoord = i.texcoord;
                half4 Tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                // sample the texture
                half4 finalcol = Tex * _BaseColor;
                return finalcol;
            }
            ENDHLSL
        }
    }
}
