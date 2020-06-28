Shader "Unlit/GrabPassTest"
{
    Properties
    {
        _UseProjectionUV("use projection UV", Range(0, 1)) = 1
        _Invert("Invert", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

        /* Grab the screen texture until this object is rendered and put it into a texture named "_GrabPassTestTexture".
        To better clarify what exactly will be in the texture, if you use GrabPass in a skybox shader, there ain't gonna be much there.
        If it's in a transparent shader, you'll get all the objects drawn in the geometry queue before it.
        So it's important to define the correct queue order in order to get the desired texture.*/
        GrabPass
        {
            "_GrabPassTestTexture"
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 grabPos : TEXCOORD1;
            };

            sampler2D _GrabPassTestTexture; //We still need to declare the GrabPass texture inside the CG program
            float _Invert, _UseProjectionUV;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;

                //Use the grabPass Texture
                if(_UseProjectionUV == 1){
                    col = tex2Dproj(_GrabPassTestTexture, i.grabPos); //Project the texture into the object, retaining the same angle of the camera
                }
                else{
                    col = tex2D(_GrabPassTestTexture, i.uv); //use the object default UVs
                }

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                if(_Invert == 1){
                    col = 1 - col;
                }

                return col;
            }
            ENDCG
        }
    }
}
