Shader "Camera Effects/DepthView"
{
    Properties
    {
        //The replacement shader retains all properties of the original shader, so if we want to use something from there, we just need to declare what we need as usual
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        /*In a replacement shader, the tag defines which shader will be replaced. You can create custom tags at will, but if you want
        to replace any of Unity's built-in Shaders, all of their shaders have a "RenderType" tag, with different values for different
        types of shaders (explanined here: https://docs.unity3d.com/Manual/SL-ShaderReplacement.html).
        
        The way the replacement works is basically:
        1 - You define the tag used when setting the Camera Replacement Shader in the C# script (ex: "RenderType");
        2 - Your replacement shader must have this same tag, with a value defined
        3 - Unity will check all objects being rendered that also has the same tag, and check if the value of the tag is the same as one
        of the subshaders defined in the replacement shader (ex: If the SubShader has the tag "RenderType=Opaque", then it'll only replace
        objects that ALSO has the "RenderType=Opaque" tag.
        4 - If the object doesn't have a tag matching any of the Replacement Shader's tags, the object WON'T BE RENDERED.
        
        We need to write a new subshader for each different tag we want to replace. In this case, we're replacing opaque objects, but if we want
        to replace transparent objects too for example, we'd need to write another subshader with the "RenderType=Transparent" tag.

        NOTE: You can actually give an empty value ("") in the function at the C# script to replace the shaders in ALL objects being rendered*/
        Tags
        {
            "RenderType"="Opaque"
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
                float depth : DEPTH;
            };

            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                /*This line transforms the vertex position into View space, which is basically the position of the vertex relative to the camera POSITION
                (and not the camera view frustum, that is the CLIP space). That means the Z value is the distance from the vertex to the camera, but it
                comes as a negative value, so we invert the signal to get positive values.

                The variable "_ProjectionParams" is a built-in variable from UnityCG, and the W value is (1 / Camera far clip distance). We can
                multiply the distance of the vertex with this value to get a nice value between the range 0 to 1, representing the percentage of the distance.*/
                o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Here we invert the depth so the white values are closer to the camera instead
                float4 col = 1 - i.depth;
                return col * _Color;
            }
            ENDCG
        }
    }
}
