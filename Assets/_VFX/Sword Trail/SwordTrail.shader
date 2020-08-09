Shader "Custom/SwordTrail"
{
    Properties
    {
        [Header(Basic Options)][Space]
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendModeSrc("Src Blend Mode", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendModeDst("Dst Blend Mode", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0

        [Header(Shader Options)][Space]
        [Toggle]_ReverseX("Reverse UV X", Float) = 0
        [Toggle]_ReverseY("Reverse UV Y", Float) = 0
        [HDR]_Color("Color", Color) = (1, 1, 1, 1)
        _Shape("Shape", Range(-1, 1)) = 0
        _ShapeCurvature("Shape Curvature", Float) = 1
        _SpeedAndSize("Speed and Size", Vector) = (0, 0, 0, 0)
        [PowerSlider(3.0)]_Smoothness("Smoothness", Range(0, 1)) = 0

        [Header(Debug)][Space]
        [Toggle]_ShowMask("ShowMask", Float) = 0
        [Toggle]_UseColorAsMask("use color as mask", Float) = 0
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }

        Cull [_CullMode]
        Blend [_BlendModeSrc] [_BlendModeDst]

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

            float _Shape, _ShapeCurvature, _Smoothness, _ReverseX, _ReverseY;
            float4 _Color, _SpeedAndSize;
            float _ShowMask, _UseColorAsMask;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = float2(_ReverseX ? 1 - v.uv.x : v.uv.x, _ReverseY ? 1 - v.uv.y : v.uv.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = 0;

                float mask = (1 - (i.uv.x + _Shape)) + pow(i.uv.y, _ShapeCurvature);
                mask = pow(saturate(mask), _Smoothness * 100);

                if(_ShowMask){
                    return float4(mask, mask, mask, 1);
                }

                //Voronoi
                float value, cells;
                float3 color;

                float2 animUV = i.uv * _SpeedAndSize.zw + (_SpeedAndSize.xy * _Time.y);

                voronoi(animUV, 10, value, cells, color);

                col = mask * value * _Color;

                if(_UseColorAsMask){
                    return col;
                }else{
                    return float4(col.rgb, mask);
                }
            }
            ENDCG
        }
    }
}
