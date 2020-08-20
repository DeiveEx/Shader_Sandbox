Shader "Custom/HexCell"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Color Texture", 2D) = "white" {}
        [NoScaleOffset]_MapTex ("Map Texture", 2D) = "white" {}
        [NoScaleOffset]_Noise ("Noise", 2D) = "black" {}
        _Cutoff ("Cutoff", Float) = 0.5
        _MapColor ("Map Color", Color) = (1, 1, 1, 1)
        _MapEdgeColor ("Map Edge Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_MapBackgroud ("Map Background", 2D) = "white" {}
        
        //These are set by the script
        _MaskTexture ("Mask Texture", 2D) = "white" {}
        [HideinInspector]_MapSize ("Map Size", Float) = 0
        [HideinInspector]_Offset ("Offset", Vector) = (0, 0, 0, 0)
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex, _MaskTexture, _MapTex, _Noise, _MapBackgroud;
            float _MapSize, _Cutoff;
            float4 _MapColor, _MapEdgeColor, _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = 0;
                float2 worldUV = (i.worldPos.xz - _Offset.xz) / _MapSize; //Calculate the correct UV coordinates from the projected texture in world space
                
                //Get all textures we're gonna use, with the correct UVs
                float4 mask = tex2D(_MaskTexture, worldUV); //The mask
                float4 tileTex = tex2D(_MainTex, i.uv); //The tile Icon
                float4 tilemap = tex2D(_MapTex, i.uv); //The hidden tile Icon
                float4 mapBG = tex2D(_MapBackgroud, worldUV); //An optional texture for the hidden part of the map
                float noise = tex2D(_Noise, worldUV); //The noise used at the borders of the revealed/hidden parts

                //Applies the noise to the mask
                float maskNoise = clamp(mask - pow(1 - mask, 0.01f) * noise, 0, 1);

                //Decides which texture to show
                col = tileTex;

                if(maskNoise < _Cutoff)
                    col = lerp(_MapColor * tilemap * mapBG, _MapEdgeColor, maskNoise / _Cutoff); //Paints the edges of the revealed area and join the tile texture with the map color and texture

                return col;
            }
            ENDCG
        }
    }
}
