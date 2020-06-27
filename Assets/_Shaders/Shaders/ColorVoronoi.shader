Shader "Tests/ColorVoronoi"
{
    Properties
    {
        _Size ("Size", Float) = 8
        _Speed ("Speed", Float) = 1
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

            float _Size;
            float _Speed;

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
                fixed3 col = 0;

                //Voronoi (from include file above)
                float points = 0; //The default "Voronoi view"
                float cells = 0; // The cells
                float3 distance = float3(0, 0, 0); //The distance from the point

                voronoi(i.uv * _Size, _Time.y * _Speed, points, cells, distance);

                //Edges
                float edges = smoothstep(0.04, 0.07, distance.x);

                //Waves
                float waves = (sin(distance.x * 64) * 0.5) + 0.5;
                waves *= distance.x;

                //Join edges with waves
                float3 edgeColor = float3(1, 0.6, 0);
                float3 edgeWithWaves = lerp(edgeColor, waves, edges);
                
                //Points
                float3 pointColor = float3(1, 0.6, 0.1);
                float pointCore = (1 - smoothstep(0, 0.005, points));
                float pointCoreBorder = smoothstep(0, 0.05, points);

                //Join waves with points
                col = lerp(pointColor, edgeWithWaves, pointCoreBorder);
                col += pointCore;


                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return fixed4(col, 0);
            }
            ENDCG
        }
    }
}
