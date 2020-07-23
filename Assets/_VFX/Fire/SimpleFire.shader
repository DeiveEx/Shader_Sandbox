Shader "Unlit/SimpleFire"
{
    Properties
    {
        [HDR]_MainColor("Main Color", Color) = (1, 1, 1, 1)
        _Colors("Colors", 2D) = "white" {}
        _Layers("Layers", Float) = 0
        _LayerOffset("Layers Offset", Float) = 0
        
        [Space]
        _OffsetSpeed("Offset Speed", Float) = 5
        _Movement("Movement", Vector) = (1, 1, 1, 1)
        _SpeedAndSize("Speed and Size", Vector) = (1, 1, 1, 1)
        _Position("Position", Range(-1, 1)) = 0
        
        [Space]
        _Clip("Clip", Range(0, 1)) = 0
        [MaterialToggle]_UseStep("Use Step", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

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

            sampler2D _Colors;
            float _OffsetSpeed, _Clip, _ColorID, _Position, _Layers, _LayerOffset;
            float4 _SpeedAndSize, _MainColor, _Movement;

            //Debug
            float _UseStep;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float getLayer(in float2 uv, int layerID)
            {
                //Mask
                float4 mask = 1 - (uv.y - _Position - (layerID * _LayerOffset));

                //Voronoi
                float value, cells;
                float3 color;

                float2 voronoiUV = float2(uv.x + (_Time.y * _SpeedAndSize.x), uv.y + (_Time.y * _SpeedAndSize.y));
                voronoiUV.x = voronoiUV.x + sin((1 - uv.y) + (_Time.y * _Movement.x - (layerID * _LayerOffset))) * _Movement.y;
                
                voronoi(voronoiUV * _SpeedAndSize.zw, _Time.y * _OffsetSpeed + (layerID * _LayerOffset), value, cells, color);

                value *= mask;
                value += mask;

                if(_UseStep == 1){
                    value = 1 - step(value, _Clip);
                }

                return value;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 col = 0;

                float value = 0;
                float2 uv = i.uv;
                float lastValue = 0;

                for(int i = 0; i < _Layers; i++){
                    value = getLayer(uv, i) - value;
                    col += value * tex2D(_Colors, float2((1.0/4.0) * i, 0));
                    lastValue += value;
                }

                return float4(col, lastValue) * _MainColor;
            }
            ENDCG
        }
    }
}
