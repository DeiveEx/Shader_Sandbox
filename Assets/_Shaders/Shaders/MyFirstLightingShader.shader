Shader "Custom Shaders/My First Lighting Shader"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        [Gamma]_Metallic ("Mettallic", Range(0, 1)) = 0.5
    }

    SubShader
    {
        //The first pass is ALWAYS called
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase" //Tell Unity that this Shader Pass should be called in the first render pass of the Forward Rendering. Also sets other things up, like telling Unity to use the main light (which is the one with greater intensity)
            }

            CGPROGRAM

            #pragma target 3.0

            #pragma multi_compile _ VERTEXLIGHT_ON //Tells Unity that we want to compute light in the vertex shader for optmization. Not that this only supports Point lights. Also note the "_" before "VERTEXLIGHT_ON". This measn that the multicompile will compile once for "VERTEXLIGHT_ON" and another time for everything else
            
            #pragma vertex vert
			#pragma fragment frag

            #define FORWARD_BASE_PASS

            #include "../Includes/MyLighting.cginc" //Custom include. We have to use either an absolute path (Starting from assets) or a relative path for it to work
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd" //This pass is called for additional lights. Tell Unity that this Shader Pass should add to the result of the "ForwardBase" pass. 
            }

            Blend One One //The unity to take the frame buffer, multiply by one (First param), tahe the result of this pass, multiply by one too (second param), and the add them together to get the result (additive blending)
            ZWrite Off //Turns Off writing on the Depth buffer for this pass, since it already did that on the first pass. 

            CGPROGRAM

            #pragma target 3.0
             
            //#pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT POINT_COOKIE SPOT //Tells Unity to compile this pass multiple times. In this case, one using the "#define POINT" for point lights, one using "#define DIRECTIONAL" for directional lighs, and one for Spot lights. These flags are used for some of the "AutoLighting.cginc" Macros. "DIRECTIONAL_COOKIE" and "POINT_COOKIE" are used for lighs with cookies, which are a special case
            #pragma multi_compile fwdadd //Equivalent to the line above

            #pragma vertex vert
			#pragma fragment frag

            #include "../Includes/MyLighting.cginc"
            ENDCG
        }
    }
}