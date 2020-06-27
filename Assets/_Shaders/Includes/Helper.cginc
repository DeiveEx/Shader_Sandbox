#if !defined(HELPER_INCLUDED) //Check if this file was already included
#define HELPER_INCLUDED //If if wasn't, we set a flag telling it was included now

//=== VORONOI

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

float2 randomVector2 (float2 UV, float offset) //This function was taken from Unity's Voronoi node documentation, and not from ShaderToy
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
}

void voronoi (in float2 x, in float offset, out float Out , out float cells, out float3 color)
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

                Out = d;
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

//=== Twirl
float2 twirl(float2 UV, float2 Center, float Strength, float2 Offset)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    return float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}

#endif