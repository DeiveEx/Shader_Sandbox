Shader "Camera Effects/PixelDisplacement"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {} //This will be te camera texture. It HAS to be called "_MainTex" to work.
        _DisplacementMap("Displacemt", 2D) = "white" {}
        _Amount("Amount", Range(0, 1)) = 0
        _Speed("Speed", Range(0, 10)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _DisplacementMap;
            float _Amount, _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Displacement
                float2 displace = tex2D(_DisplacementMap, i.uv + (_Time.y * _Speed));
                displace = ((displace * 2) - 1) * _Amount; //Remaps the values of the texture from (0, 1) to (-1, 1)

                fixed4 col = tex2D(_MainTex, i.uv + displace);

                return col;
            }
            ENDCG
        }
    }
}
