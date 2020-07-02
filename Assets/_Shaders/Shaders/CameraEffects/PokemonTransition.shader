Shader "Camera Effects/PokemonTransition"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
        _TransitionTex ("Transition Tex", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _Amount("Amount", Range(0, 1)) = 0
        [MaterialToggle] //This line turns a Float property into a checkbox, in which 0 is False and 1 is True
        _UseDistortion("Use Distortion", Float) = 0
        _Fade("Fade", Range(0, 1)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _TransitionTex;
            float _Amount, _UseDistortion, _Fade;
            float4 _Color, _MainTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv;
                o.uv1 = v.uv;

                //When doing image effects, textures coordinates can be flipped depending on the plataform, so we can check if these coordinates are flipped and manually reverse it.
                //Note that we wonly need this flipped UV for extra textures, because Unity automatically fixes the UV coordinates for the main Texture (again, in Image effects)
                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                {
                    o.uv1.y = 1 - o.uv1.y;
                }
                #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 transition = tex2D(_TransitionTex, i.uv1); //We used the fixed UV for all texture that are not the MainTex

                float2 distortion = 0;

                if(_UseDistortion == 1)
                {
                    //The red and green channels are the displacement. So 0 red is left, 1 red is right. Same goes for the green channel, but for up and down.
                    distortion = normalize(float2((transition.r - 0.5) * 2, (transition.g - 0.5) * 2)); //Remaps the (0, 1) range of the texture RG channels to the range (-1, 1)
                    //distortion = normalize(distortion); //This line bugs everything...
                }

                float4 col = tex2D(_MainTex, i.uv0 + _Amount * distortion);

                if(transition.b < _Amount)
                {
                    col = _Color;
                }

                //col = float4(i.uv0 + _Amount * distortion, 0, 0);
                return lerp(col, _Color, _Fade);
            }
            ENDCG
        }
    }
}
