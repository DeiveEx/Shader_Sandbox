Shader "Custom/Flower"
{
    Properties
    {
        _Points ("Points", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off

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

            float _Points;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Simple Polar coordinates
                float2 pos = i.uv - float2(0.5, 0.5);
                float radius = length(pos) * 2.0;
                float angle = atan2(pos.x, pos.y);

                float value = abs(cos(angle * _Points)) * 0.5 + 0.3;

                float4 col = 1.0 - smoothstep(value, value + 0.02, radius);

                return col;
            }
            ENDCG
        }
    }
}
