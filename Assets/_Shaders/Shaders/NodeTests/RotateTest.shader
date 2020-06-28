Shader "Node Conversion Tests/RotateTest"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _DegOrRad("Degrees or Radians", Range(0, 1)) = 0
        _Value("Strenght", Float) = 0
        _CenterX("CenterX", Float) = 0.5
        _CenterY("CenterY", Float) = 0.5
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
            float _DegOrRad, _Value, _CenterX, _CenterY;

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
                float2 uv = i.uv;

                if(_DegOrRad == 0){
                    uv = rotateDegrees(uv, _Value, float2(_CenterX, _CenterY));
                }
                else{
                    uv = rotateRadians(uv, _Value, float2(_CenterX, _CenterY));
                }

                fixed3 col = tex2D(_MainTex, uv);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return fixed4(col, 0);
            }
            ENDCG
        }
    }
}
