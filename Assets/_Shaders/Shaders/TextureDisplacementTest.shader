Shader "Unlit/TextureDisplacementTest"
{
    Properties
    {
        _MainTex ("Texture Mask", 2D) = "white" {}
        _Strength("Strenght", Float) = 1
        _Rotation("_Rotation", Float) = 1
        _Speed("Speed", Vector) = (1, 1, 1, 1)
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
            float4 _MainTex_ST, _Speed;
            float _Strength, _Rotation;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                v.vertex += v.vertex * lerp(0, _Strength, tex2Dlod(_MainTex, float4(rotateDegrees(o.uv.xy + (_Speed * _Time.y), _Rotation), 0, 0)));
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, rotateDegrees(i.uv + _Speed * _Time.y, _Rotation));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
