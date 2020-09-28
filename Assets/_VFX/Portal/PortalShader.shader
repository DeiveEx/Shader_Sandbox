Shader "Custom/PortalShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[IntRange]_Rings ("Rings", Range(1, 10)) = 5
		_Test ("Test", Float) = 0
		[Toggle]_ShowUV ("Show UV", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
			float _Rings, _Test;
			float _ShowUV; //Debug

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = float2(i.uv.x * i.uv.y, frac(i.uv.y * _Rings));

                fixed4 col = tex2D(_MainTex, uv);

				if(_ShowUV){
					return float4(uv, 0, 1);
				}

                return col;
            }
            ENDCG
        }
    }
}
