Shader "Custom/Laser_Inner"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc ("Blend Scr", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst ("Blend Dst", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("Cull Mode", Float) = 0
        [Toggle]_ZWrite ("ZWrite", Float) = 0
        [Header(Properties)]
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _ScaleAndSpeed ("Scale and Speed", Vector) = (1, 1, 0, 1)
        [Toggle]_BlackIsAlpha ("Use Texture Black as Alpha", Float) = 0
        
        [HideInInspector]_UVTiling ("UV Tiling", Float) = 1 //We use this value to tile the texture based on the size of the laser
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }

        Blend [_BlendSrc] [_BlendDst]
        Cull [_CullMode]
        ZWrite [_ZWrite]

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
            float _UVTiling, _BlackIsAlpha;
            float4 _ScaleAndSpeed, _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = 0;

                float2 uv = i.uv;
                uv.y *= _UVTiling;
                fixed4 tex = tex2D(_MainTex, uv * _ScaleAndSpeed.xy + (_ScaleAndSpeed.zw * _Time.y));
                
                col = tex * _Color;

                col.a = lerp(col.a, tex.x, _BlackIsAlpha);

                return col;
            }
            ENDCG
        }
    }
}
