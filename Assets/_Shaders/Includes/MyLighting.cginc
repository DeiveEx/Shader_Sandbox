#if !defined(MY_LIGHTING_INCLUDED) //Check if this file was already included
#define MY_LIGHTING_INCLUDED //If if wasn't, we set a flag telling it was included now

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

struct VertexInput
{
    float4 pos: POSITION;
    float2 uv: TEXCOORD0;
    float3 normal: NORMAL;
};

struct VertexOutput
{
    float4 pos: SV_POSITION;
    float2 uv: TEXCOORD0;
    float3 normal: TEXCOORD1;
    float3 worldPos: TEXCOORD2;

    //If vertex light is on for this shader, we need a variable to store it
    #if defined(VERTEXLIGHT_ON)
        float3 vertexLightColor : TEXCOORD3;
    #endif
};

sampler2D _MainTex;
float4 _MainTex_ST; //To use Tiling & offset in the texture, we gotta declare thisvariable. This MUST be the SAME NAME as the texture with the suffix "_ST"
float4 _Tint;
float _Smoothness, _Metallic;

void ComputeVertexLight(inout VertexOutput i) //The inout keyword means we gonna read AND write to the parameter
{
    //Calculate up to 4 vertex lights colors, which is the max Unity can handle
    #if defined(VERTEXLIGHT_ON)
        i.vertexLightColor = Shade4PointLights(
            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
            unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
            unity_4LightAtten0, i.worldPos, i.normal
		);
    #endif
}

VertexOutput vert(VertexInput v)
{
    VertexOutput o;
    o.pos = UnityObjectToClipPos(v.pos);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex); //Applies the Tiling and offset
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.pos);
    ComputeVertexLight(o);
    return o;
}

//Shaders work from top to bottom and don't have look-ahead, se we need to define Functions and variable BEFORE using them
UnityLight CreateLight(VertexOutput i)
{
    UnityLight light; //Helper object from Unity

    //Check if the flag POINT was defined
    #if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
        light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos); //"_WorldSpaceLightPos0" contains the light direction in case of a Directional light, or the light position in case of a point light
    #else
        light.dir = _WorldSpaceLightPos0.xyz;
    #endif

    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
    light.color = _LightColor0.rgb * attenuation;

    light.ndotl = DotClamped(i.normal, light.dir);
    return light;
}

UnityIndirect CreateIndirectLight(VertexOutput i)
{
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;

    #if defined(VERTEXLIGHT_ON)
        indirectLight.diffuse = i.vertexLightColor;
    #endif

    //Ambient light using Spherical Harmonics (SH)
    #if defined(FORWARD_BASE_PASS)
        indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
    #endif

    return indirectLight;
}

float4 frag(VertexOutput i) : SV_TARGET
{
    i.normal = normalize(i.normal); //Since the values passed to the frag shader are linearly interpolated, some values, like the interpolated normals, ends up being shorter than 1, so we have to re-normalize them here

    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

    //Diffuse
    float3 albedo = tex2D(_MainTex, i.uv) * _Tint;

    float3 specularTint;
    float oneMinusReflectivity;

    albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

    float4 color = UNITY_BRDF_PBS(
        albedo, specularTint,
        oneMinusReflectivity, _Smoothness,
        i.normal, viewDir,
        CreateLight(i), CreateIndirectLight(i)
    );
    return color;
}

#endif