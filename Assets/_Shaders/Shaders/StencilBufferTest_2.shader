Shader "Unlit/StencilBufferTest_2"
{
    Properties
    {
        [IntRange] _StencilRef ("Stencil Ref", Range(0, 255)) = 0.0 //[IntRange] makes it so on the inspector we can only choose int values
    }
    SubShader
    {
        //Note that it's important that all shaders that WRITES to the Stencil Buffer should be executed BEFORE the ones that READS from te buffer, or else the desired effect might not be achieved.
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1"}
        LOD 100
        ColorMask 0 //This tells Unity to mask the channel of the final collor returned by the fragment shader. A value of ZERO means that we don't care about the color of this shader, so it can just discard all channels.
        Zwrite Off

        //In this Stencil Block, we're telling the Shader to Always pass the stencil test so it can write into the Stencil Buffer using the value defined in the "Ref" field
        Stencil
        {
            Ref [_StencilRef]
            Comp Always
            Pass Replace
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return 0;
            }
            ENDCG
        }
    }
}
