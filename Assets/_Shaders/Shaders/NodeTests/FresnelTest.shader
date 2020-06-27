Shader "Node Conversion Tests/FresnelTest"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Power ("Power", Float) = 2
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha //Traditional alpha blending

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXTCOORD1;
                float3 worldViewDir : TEXTCOORD2;
            };

            float4 _Color;
            float _Power;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal); //Convert the normal vector of the vertex from Object space to World space. Since the normal is a direction, we have to use the 3x3 version of the "unity_ObjectToWorld" matrix
                o.worldViewDir = WorldSpaceViewDir(v.vertex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fresnel(i.worldNormal, i.worldViewDir, _Power) * _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
