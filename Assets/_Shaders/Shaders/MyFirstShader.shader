Shader "Custom Shaders/My First Shader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Tint ("Tint", Color) = (1, 1, 1, 1)
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; //To use Tiling & offset in the texture, we gotta declare thisvariable. This MUST be the SAME NAME as the texture with the suffix "_ST"
            float4 _Tint;

            VertexOutput vert(VertexInput i)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex); //Applies the Tiling and offset
                return o;
            }

            float4 frag(VertexOutput o) : SV_TARGET
            {
                float4 tex = tex2D(_MainTex, o.uv);
                return tex * _Tint;
            }

            ENDCG
        }
    }
}