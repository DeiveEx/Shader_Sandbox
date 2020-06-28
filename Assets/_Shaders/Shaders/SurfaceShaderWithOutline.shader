Shader "Custom/SurfaceShaderWithOutline"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineSize("Outline Size", Float) = 0.1
        _UseNormalOrPosition("Use Normal or Position", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Geometry+1" }
        LOD 200

        //You can still add passes to surface shaders
        
        //Outline Pass
        Pass
        {
            Cull Front //Don't render front faces
            ZWrite Off //Don't write into the Depth Buffer

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineSize, _UseNormalOrPosition;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                float4 normalVert = v.vertex + (float4(v.normal, 0) * _OutlineSize);
                float4 posVert = v.vertex * (1 + _OutlineSize);
                float4 hullVertex = lerp(normalVert, posVert, _UseNormalOrPosition);
                o.pos = UnityObjectToClipPos(hullVertex);
                return o;
            }

            float4 frag (VertexOutput o) : SV_TARGET
            {
                return _OutlineColor;
            }

            ENDCG
        }

        //Surface shader

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

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
