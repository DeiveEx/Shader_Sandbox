Shader "Custom/QuadDisplacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rings ("Rings", Float) = 1
        _Speed ("Speed", Float) = 1
        _MaskSize ("Mask Size", Float) = 1
        _DisplaceStrenght ("Displace Strenght", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Rings, _MaskSize, _Speed, _DisplaceStrenght;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float4 col = 0;

                // Displacement based on UV center
				float2 center = float2(0.5, 0.5);
				float2 dir = i.uv - center;
				
				float rings = frac((length(dir) + _Time.y * _Speed) * _Rings);
				rings = sin(rings * 3.1416) / 2 + 0.5;

				float2 displace = dir * rings * _DisplaceStrenght;
				// return float4(i.uv, 0, 1);
				// return float4(i.uv + displace, 0, 1);

                col = tex2D(_MainTex, i.uv + displace);
				col.a = clamp(1 - length(dir) * _MaskSize, 0, 1);

                return col;
            }
            ENDCG
        }
    }
}
