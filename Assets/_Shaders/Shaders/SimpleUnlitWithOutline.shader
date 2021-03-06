﻿Shader "Custom Shaders/SimpleUnlitWithOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (0, 0, 0, 1)
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineSize ("Outline Size", Range(0, 5)) = 1
        _UseNormalOrPosition("Use Normal Or Position", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry+1"
        }

        //Outline
        Pass
        {
            Cull Front //Don't render front faces
            ZWrite Off //Don't write into the Depth Buffer

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineSize, _UseNormalOrPosition;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                float4 normalVert = v.vertex + (float4(v.normal, 0) * _OutlineSize);
                float4 posVert = v.vertex * (1 + _OutlineSize);
                float4 hullVertex = lerp(normalVert, posVert, _UseNormalOrPosition);
                o.pos = UnityObjectToClipPos(hullVertex);
                return o;
            }

            float4 frag (VertexOutput o) : SV_TARGET
            {
                return _OutlineColor;
            }

            ENDCG
        }
        
        //Normal render
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct VertexInput
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _Tint;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (VertexOutput o) : SV_TARGET
            {
                float4 tex = tex2D(_MainTex, o.uv) * _Tint;

                return tex;
            }

            ENDCG
        }

    }
}
