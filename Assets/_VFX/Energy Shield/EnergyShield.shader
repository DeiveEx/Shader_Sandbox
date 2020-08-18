Shader "Custom/EnergyShield"
{
    Properties
    {
        [Header(Blend)]
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc ("Blend Src", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst ("Blend Dst", Float) = 0

        [Header(Hexagons)]
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        _WaveSpeed ("Wave Speed", Float) = 1
        _WaveSize ("Wave Size", Float) = 1

        [Header(Hexagons Lines)]
        [Enum(Circle, 0, Diamond, 1)]_PulseShape ("Pulse Shape", Float) = 0
        [HDR]_LineColor ("Line Color", Color) = (1, 1, 1, 1)
        _LineWaveSpeed ("Line Wave Speed", Float) = 1
        _LineWaveSize ("Line Wave Size", Range(0, 1)) = 1

        [Header(Border)]
        [HDR]_BorderColor ("Border Color", Color) = (1, 1, 1, 1)
        _BorderSize ("Border Size", Float) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Cull Off
        Blend [_BlendSrc] [_BlendDst]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/_Shaders/Includes/Helper.cginc"

            struct appdata
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 vertexObjPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST, _Color, _LineColor, _BorderColor;
            float _WaveSize, _WaveSpeed, _LineWaveSize, _LineWaveSpeed, _PulseShape, _BorderSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex); //Tiled UV
                o.uv.zw = v.uv; //Object UV
                o.vertexObjPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 tiledTex = tex2D(_MainTex, i.uv.xy);
                float4 normalTex = tex2D(_MainTex, i.uv.zw);
                
                //Hexagons
                //Animate a "fade in-fade out" effect using the object position of the vertices and the color of the main texture as offsets. Also uses the absolute value so it can originate from the center
                float vertexPosOffset = abs(i.vertexObjPos.x) * _WaveSize;
                float colorOffset = tiledTex.r;
                float pulsatingHex = 1 - abs(sin((_Time.y * _WaveSpeed) + 1 - (vertexPosOffset * colorOffset)));
                pulsatingHex *= tiledTex.r;

                //Hexagon lines
                float hexLines = 0;
                
                if(_PulseShape == 0){
                    hexLines = max(0, abs(sin(distance(float2(0, 0), i.vertexObjPos) - _Time.y * _LineWaveSpeed)) - _LineWaveSize);
                }else{
                    hexLines = max(0, sin(abs(i.vertexObjPos.x) + abs(i.vertexObjPos.y) - _Time.y * _LineWaveSpeed) - _LineWaveSize);
                }

                hexLines = hexLines * (1 / (1 - _LineWaveSize)); //Normalize the value
                hexLines *= tiledTex.g;

                //Borders
                float border = pow(normalTex.b, _BorderSize);

                //Final color
                float4 col = pulsatingHex * _Color + hexLines * _LineColor + border * _BorderColor;
                return col;
            }
            ENDCG
        }
    }
}
