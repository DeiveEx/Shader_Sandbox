Shader "Unlit/ZTestTest"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1, 0, 0, 1)
        _Color2 ("Color 2", Color) = (0, 1, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        LOD 100

        /*The ZTest takes the current pixel of the object with this shader and compares its ZBuffer value with the previous rendered
        pixel at the same place. By Default the test is "LEqual" (Less or Equal), which means it'll only render the pixels that have a depth
        value of LESS OR EQUAL than the previous rendered pixel (if any was rendered).
        
        An important note is that the ZBuffer works in a way that pixels CLOSER to the camera have a LOWER value, while pixels FARTHER
        from the camera have a GREATER value. Also, the default value in the depth buffer before any pixel is rendered is the Far clip
        camera plane depth value.
        
        Also note that since it compares with the PREVIOUS RENDERED pixel DEPTH VALUE, that means that, depending on the order it's rendered,
        the test might not happen in the desired way (For example, the object might NOT render when using "ZTest Always", which should make the
        pixels ALWAYS visible no matter the depth, because it might be getting rendered BEFORE other objects, and thus when other objects do THEIR
        ZTest, the ZBuffer value won't have changed.)*/
        

        //This pass renders all pixels as default (closer to the camera)
        Pass
        {
            ZTest LEqual

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float4 _Color1;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = _Color1;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        //While this pass renders all pixels that are farther from the camera
        Pass
        {
            ZTest Greater
            
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = _Color2;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
