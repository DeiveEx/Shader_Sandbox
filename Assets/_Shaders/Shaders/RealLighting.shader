Shader "Custom Shaders/Real Light"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Float) = 1
    }

    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc" //Import some of the Unity lighting functionality

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD0;
                float3 worldPos: TEXCOORD2;
            };

            float4 _Color;
            float _Gloss;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, o.vertex); //Transforms from object space to world space
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                //The interpolated normals can end up having a lenght of less than 1, thus not being normalized anymore, so we have to fix that manually
                float3 normal = normalize(i.normal); 

                //Since we impoted Unity's lighting, we can get some of the light data from the scene
                float3 lightDir = _WorldSpaceLightPos0.xyz; //Get the direction of the first directional light OR  the position of the first point light
                float3 lightColor = _LightColor0.rgb; //get the color of the first light in the scene

                //Simple lighting using Dot and clamping it to 0-1 using saturate
                float simpleLight = saturate(dot(lightDir, normal));
                float3 diffuse = simpleLight * lightColor;

                //Ambient light
                float3 ambientLightColor = float3(0.1, 0.1, 0.25);

                //Specular light
                float3 camPos = _WorldSpaceCameraPos; //Taken from the Unity lib
                float3 viewDirection = normalize(camPos - i.worldPos); //Here the "worldPos" is the position of the fragment being processed
                float3 viewReflect = reflect(-viewDirection, normal); //Reflect an incoming vector based on a normal

                float3 specularFalloff = max(0, dot(viewReflect, lightDir));
                float3 specular = pow(specularFalloff, _Gloss) * lightColor;

                //Light composition
                float3 finalDiffuseColor = diffuse + ambientLightColor;

                //Actual surface color
                float3 surfaceColor = finalDiffuseColor * _Color + specular;

                return fixed4(surfaceColor, 0);
            }
            ENDCG
        }
    }
}
