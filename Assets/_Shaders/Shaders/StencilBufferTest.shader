Shader "Custom/StencilBufferTest"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [IntRange] _StencilRef ("Stencil Ref", Range(0, 255)) = 0.0 //[IntRange] makes it so on the inspector we can only choose int values
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        /*The stencil buffer is part of the depth buffer. The stencil, just like the depth buffer, is an operation which defides if the current pixel
        will be drawn or discarded. On Deffered Rendering, Unity uses some values of the Stencil buffer to calculate some things, so some limitations
        may apply.
        Helper article: https://www.ronja-tutorials.com/2018/08/18/stencil-buffers.html*/
        Stencil
        {
            //We can tell ShaderLab to reference a value from the properties by putting this value between brackets
            Ref [_StencilRef] //This is the value we're comparing to the stencil buffer. The default value for the stencil buffer is 0. We can use any number from 0 to 255
            Comp Equal //This is the comparision we're making with the current buffer, so we are basically camparing the buffer with the "Ref" value. The default comparision is "Always"
            Pass Replace //This tells Unity WHAT to do with the value of the Stencil buffer if both the Stencil comparision and ZTest passed. By default this value is "Keep", which won't change the value in the buffer
            //There's other commands like "Fail", which tells Unity what to do with the buffer value when the Stencil test fails, and "ZFail", which tells unity what to do with the buffer value when the Stencil test passed, but the ZTest did not.
        }

        CGPROGRAM
        // Physically based Standard lighting model
        #pragma surface surf Standard

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
