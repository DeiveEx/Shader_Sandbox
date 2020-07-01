Shader "Camera Effects/SimpleBoxBlur"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
        _SampleDistance("Sample distance", Float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize; //Using TextureName_TexelSize makes it so Unity gives us the, well, texel size of the named texture. The texel size is the size of the texture in pixels. 
            float _SampleDistance;

            float4 box(sampler2D tex, float2 uv, float4 texelSize)
            {
                //Add the color of the current pixel with all 8 adgecent pixel colors
                float4 averagedColor =  tex2D(tex, uv) +
                                        tex2D(tex, uv + (float2(-1, 0) * texelSize)) +
                                        tex2D(tex, uv + (float2(-1, -1) * texelSize)) +
                                        tex2D(tex, uv + (float2(0, -1) * texelSize)) +
                                        tex2D(tex, uv + (float2(1, -1) * texelSize)) +
                                        tex2D(tex, uv + (float2(1, 0) * texelSize)) +
                                        tex2D(tex, uv + (float2(1, 1) * texelSize)) +
                                        tex2D(tex, uv + (float2(0, 1) * texelSize)) +
                                        tex2D(tex, uv + (float2(-1, 1) * texelSize));
                
                //Then return this color, divided by the amount of pixels sampled (in this case, 9)
                return averagedColor / 9;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = box(_MainTex, i.uv, _MainTex_TexelSize * _SampleDistance);

                return col;
            }
            ENDCG
        }
    }
}
