Shader "Custom Shaders/Texture Splatting"
{
    Properties
    {
        _MainTex ("Splat Map", 2D) = "white" {}
        [NoScaleOffset]_Tex1 ("Tex1", 2D) = "white" {} //"[NoScaleOffset]" hides the "Scale and Offset" controls in the inspector
        [NoScaleOffset]_Tex2 ("Tex2", 2D) = "white" {}
        [NoScaleOffset]_Tex3 ("Tex3", 2D) = "white" {}
        [NoScaleOffset]_Tex4 ("Tex4", 2D) = "white" {}
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
                float2 uvSplat: TEXCOORD1;
            };

            sampler2D _MainTex, _Tex1, _Tex2, _Tex3, _Tex4;
            float4 _MainTex_ST; //To use Tiling & offset in the texture, we gotta declare thisvariable. This MUST be the SAME NAME as the texture with the suffix "_ST"

            VertexOutput vert(VertexInput i)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex); //Applies the Tiling and offset
                o.uvSplat = i.uv;
                return o;
            }

            float4 frag(VertexOutput o) : SV_TARGET
            {
                float4 splatRange = tex2D(_MainTex, o.uvSplat);
                float4 color1 = tex2D(_Tex1, o.uv) * splatRange.r;
                float4 color2 = tex2D(_Tex2, o.uv) * splatRange.g;
                float4 color3 = tex2D(_Tex3, o.uv) * splatRange.b;
                float4 color4 = tex2D(_Tex4, o.uv) * (1 - splatRange.r - splatRange.g - splatRange.b);

                return color1 + color2 + color3 + color4;
            }

            ENDCG
        }
    }
}