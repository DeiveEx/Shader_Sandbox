Shader "Unlit/SwordTrail"
{
    Properties
    {
        _Size("Size", Range(-1, 1)) = 0
        _Smoothness("Smoothness", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        //Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/_Shaders/Includes/Helper.cginc"

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

            float _Size, _Smoothness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = 0;

                float mask = (1 - (i.uv.x +  + _Size)) + i.uv.y;
                mask = saturate(pow(mask, _Smoothness));

                //Voronoi
                float value, cells;
                float3 color;

                voronoi(i.uv * 5, 10, value, cells, color);

                col = mask * value;

                return col;
            }
            ENDCG
        }
    }
}
