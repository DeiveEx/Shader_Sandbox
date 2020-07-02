Shader "Camera Effects/ScannerWave"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
        _ScanTex ("Scan Texture", 2D) = "white" {}
        _WaveSize ("Wave Size", Float) = 1
        _WavePos ("Wave Pos", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

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
                float depth: DEPTH;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                //Calculate Depth
                o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;
                return o;
            }

            sampler2D _MainTex, _ScanTex;
            float _WaveSize, _WavePos;

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float4 scan = tex2D(_ScanTex, i.uv);

                float wave = smoothstep(_WavePos - _WaveSize, _WavePos + _WaveSize, i.depth);
                float mask1 = step(_WavePos - _WaveSize, i.depth);
                float mask2 = step(_WavePos + _WaveSize, i.depth);

                wave *= mask1 - mask2;

                col = lerp(col, scan, wave);

                return col;
            }
            ENDCG
        }
    }
}
