Shader "Camera Effects/Overdraw"
{
    Properties
    {
        _OverdrawColor("Overdraw Color", Color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        ZTest Always //Here we're telling unity to draw this object no matter their zBuffer value
        ZWrite Off //Here we're telling this shader to not write to the zBuffer
        Blend One One //Additive blending

        Tags
        {
            "Queue"="Transparent" //making sure this shader is draw after the skybox and stuff
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _OverdrawColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OverdrawColor;
            }
            ENDCG
        }
    }
}
