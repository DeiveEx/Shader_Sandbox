#if !defined(HELPER_INCLUDED) //Check if this file was already included
#define HELPER_INCLUDED //If if wasn't, we set a flag telling it was included now

//=== Voronoi

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

float2 randomVector2 (float2 UV, float offset) //This function was taken from Unity's Voronoi node documentation, and not from ShaderToy
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
}

void voronoi (in float2 x, in float offset, out float value, out float cells, out float3 color)
{
    float2 n = floor(x);
    float2 f = frac(x); 

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
	float2 mg, mr;

    float md = 8.0;
    for( int j=-1; j<=1; j++ ){
        for( int i=-1; i<=1; i++ )
        {
            float2 g = float2(float(i),float(j));
		    float2 o = randomVector2(g + n, offset);//hash2( (n + g) * offset );

            float2 r = g + o - f;
            float d = dot(r,r);

            if(d < md)
            {
                md = d;
                mr = r;
                mg = g;

                value = d;
                cells = o.x;
            }
        }
    }

    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 8.0;
    for( int j=-2; j<=2; j++ ){
        for( int i=-2; i<=2; i++ )
        {
            float2 g = mg + float2(float(i),float(j));
		    float2 o = randomVector2(g + n, offset);//hash2( (n + g) * offset );

            float2 r = g + o - f;

            if( dot(mr-r,mr-r)>0.00001 ){
                md = min( md, dot( 0.5*(mr+r), normalize(r-mr) ) );
            }
        }
    }

    color = float3( md, mr );
}

//=== Dither

float4 dither (float4 color, float4 ScreenPosition)
{
    float2 uv = ScreenPosition.xy * _ScreenParams.xy;
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    return color - DITHER_THRESHOLDS[index];
}

//=== Fresnel

float fresnel (float3 Normal, float3 ViewDir, float Power)
{
    return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

//=== Remap

float remap(float value, float InMin, float InMax, float OutMin, float OutMax)
{
    return OutMin + (value - InMin) * (OutMax - OutMin) / (InMax - InMin);
}

float2 remap(float2 value, float InMin, float InMax, float OutMin, float OutMax)
{
    return OutMin + (value - InMin) * (OutMax - OutMin) / (InMax - InMin);
}

float3 remap(float3 value, float InMin, float InMax, float OutMin, float OutMax)
{
    return OutMin + (value - InMin) * (OutMax - OutMin) / (InMax - InMin);
}

float4 remap(float4 value, float InMin, float InMax, float OutMin, float OutMax)
{
    return OutMin + (value - InMin) * (OutMax - OutMin) / (InMax - InMin);
}

//=== Simple Noise

inline float unity_noise_randomValue (float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
}

inline float unity_noise_interpolate (float a, float b, float t)
{
    return (1.0-t)*a + (t*b);
}

inline float unity_valueNoise (float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = unity_noise_randomValue(c0);
    float r1 = unity_noise_randomValue(c1);
    float r2 = unity_noise_randomValue(c2);
    float r3 = unity_noise_randomValue(c3);

    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}

float simpleNoise(float2 UV, float Scale)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3-0));
    t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3-1));
    t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3-2));
    t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

    return t;
}

//=== Gradient Noise

float2 unity_gradientNoise_dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float unity_gradientNoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(unity_gradientNoise_dir(ip), fp);
    float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float gradientNoise(float2 UV, float Scale)
{
    return unity_gradientNoise(UV * Scale) + 0.5;
}

//=== Rotate

float2 rotateRadians(float2 UV, float Rotation, float2 Center = float2(0.5, 0.5))
{
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2 - 1;
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;
    return UV;
}

float2 rotateDegrees(float2 UV, float Rotation, float2 Center = float2(0.5, 0.5))
{
    Rotation = Rotation * (3.1415926f/180.0f);
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2.0 - 1.0;
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;
    return UV;
}

//=== Polar Coordinates

float2 polarCoordinates(float2 UV, float RadialScale, float LengthScale, float2 Center = float2(0.5, 0.5))
{
    float2 delta = UV - Center;
    float radius = length(delta) * 2 * RadialScale;
    float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
    return float2(radius, angle);
}

//=== Radial Sheer

float2 radialShear(float2 UV, float Strength, float2 Center = float2(0.5, 0.5), float2 Offset = float2(0.0, 0.0))
{
    float2 delta = UV - Center;
    float delta2 = dot(delta.xy, delta.xy);
    float2 delta_offset = delta2 * Strength;
    return UV + float2(delta.y, -delta.x) * delta_offset + Offset;
}

//=== Twirl
float2 twirl(float2 UV, float Strength, float2 Center = float2(0.5, 0.5), float2 Offset = float2(0.0, 0.0))
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    return float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

//=== Spherize

float2 spherize(float2 UV, float Strength, float2 Center = float2(0.5, 0.5), float2 Offset = float2(0, 0))
{
    float2 delta = UV - Center;
    float delta2 = dot(delta.xy, delta.xy);
    float delta4 = delta2 * delta2;
    float2 delta_offset = delta4 * Strength;
    return UV + delta * delta_offset + Offset;
}

//=== Triplanar

float4 triplanar (sampler2D Texture, float3 Position, float3 Normal, float Tile, float Blend)
{
    float3 Node_UV = Position * Tile;
    float3 Node_Blend = pow(abs(Normal), Blend);
    Node_Blend /= dot(Node_Blend, 1.0);
    float4 Node_X = tex2D(Texture, Node_UV.zy);
    float4 Node_Y = tex2D(Texture, Node_UV.xz);
    float4 Node_Z = tex2D(Texture, Node_UV.xy);
    return Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z;
}

#endif