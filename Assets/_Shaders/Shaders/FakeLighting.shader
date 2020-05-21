Shader "Custom Shaders/Fake Light"
{
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD0;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                //Fake light direction
                float3 lightDir = float3(1, 1, 1);

                //Simple lighting using Dot and clamping it to 0-1 using saturate
                float simpleLight = saturate(dot(lightDir, i.normal));
                float3 lightColor = float3(0.35, 0.35, 0.1);

                float3 diffuse = simpleLight * lightColor;

                float3 ambientLightColor = float3(0.1, 0.1, 0.25);

                return fixed4(diffuse + ambientLightColor, 0);
            }
            ENDCG
        }
    }
}
