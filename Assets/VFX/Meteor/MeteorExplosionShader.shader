Shader "Unlit/MeteorExplosionShader"
{
    Properties
    {
        [HDR]_Color1 ("Color1", Color) = (1, 1, 1, 1)
        [HDR]_Color2 ("Color2", Color) = (1, 1, 1, 1)
        _Size ("Size", Float) = 5
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "Queue"="Transparent+1"
        }
        Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency

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
                float4 uvs : TEXCOORD0; //Changed the uv to a float4 so we can easily put our custom data into the TEXCOORD1 (if we don't do this, Unity will try to fit the custom data into the TEXCOORD0.zw channels, which we could use, but for simplicity, lets not)
                float4 color : COLOR;
                float4 custom : TEXCOORD1;
            };

            struct v2f
            {
                float4 uvs : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float4 custom : TEXCOORD1;
            };

            float4 _Color1, _Color2;
            float _Size, _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvs = v.uvs;
                o.color = v.color;
                o.custom = v.custom;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color1 * i.color;
                float value;
                float cells;
                float3 color;
                voronoi(i.uvs.xy * _Size, i.custom.y, value, cells, color);

                col *= step(i.custom.x, value);

                return col;
            }
            ENDCG
        }
    }
}
