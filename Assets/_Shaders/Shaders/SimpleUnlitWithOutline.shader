Shader "Custom Shaders/SimpleUnlitWithOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineSize ("Outline Size", Range(1, 5)) = 1.1
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
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineSize;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                float4 hullVertex = v.vertex * _OutlineSize;
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

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (VertexOutput o) : SV_TARGET
            {
                float4 tex = tex2D(_MainTex, o.uv);

                return tex;
            }

            ENDCG
        }

    }
}
