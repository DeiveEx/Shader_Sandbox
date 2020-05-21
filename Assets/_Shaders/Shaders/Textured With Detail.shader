Shader "Custom Shaders/Textured With Detail"
{
    Properties
    {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _DetailTex ("Detail Tex", 2D) = "gray" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
			#pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexInput
            {
                float4 pos: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float2 uvDetail: TEXCOORD1;
            };

            float4 _Tint;
            sampler2D _MainTex, _DetailTex;
            float4 _MainTex_ST, _DetailTex_ST; //To use Tiling & offset in the texture, we gotta declare thisvariable. This MUST be the SAME NAME as the texture with the suffix "_ST"
            
            VertexOutput vert(VertexInput i)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex); //unity macro that applies the Tiling and offset
                o.uvDetail = TRANSFORM_TEX(i.uv, _DetailTex);
                return o;
            }

            float4 frag(VertexOutput o) : SV_TARGET
            {
                float4 color = tex2D(_MainTex, o.uv) * _Tint;
                color *= tex2D(_DetailTex, o.uvDetail) * unity_ColorSpaceDouble; //"unity_ColorSpaceDouble" is a helper variable that helps with the darkening of textures when using linear Color Space. The value of this variable changes depending of which Color space is used
                return color;
            }

            ENDCG
        }
    }
}