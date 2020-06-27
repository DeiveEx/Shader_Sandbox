Shader "Node Conversion Tests/TwirlTest"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _CenterAndOffset("Center And Offset", Vector) = (0.5, 0.5, 0, 0)
        _Strenght("Strenght", Float) = 0.5
        _UseTime("Use Time", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _CenterAndOffset;
            float _Strenght, _UseTime;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 offset = _CenterAndOffset.zw;

                if(_UseTime == 1){ 
                    offset.x = _Time.y;
                }

                fixed3 col = tex2D(_MainTex, twirl(i.uv, _CenterAndOffset.xy, _Strenght, offset));

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return fixed4(col, 0);
            }
            ENDCG
        }
    }
}
