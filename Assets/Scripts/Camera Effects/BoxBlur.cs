using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BoxBlur : MonoBehaviour
{
	public Material effectMaterial;
	[Range(0, 10)]
	public int blurAmount = 1;
	[Range(0, 5)]
	public int downResAmount = 1;

	//This method is called if this script is attached to a camera
	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (effectMaterial != null)
		{
			/* The bit shit operator ">>" and "<<" shits the bits by the amount defined at the right side of the operation.
			We use bitwise operations with ints, uints, long and ulong (we can use with other types, but they'll be converted to the closest value in one of these types
			before the bitwise operations), and these values always have either 32 or 64 bits, so a value of "1" written in bits would actually be:
			0000 0000 0000 0000 0000 0000 0000 0001

			Ex: 110 shifted 1 bit to the right with ">>" turns into "011", which can be simplified to just 11.
			Before:	0000 0000 0000 0000 0000 0000 0000 0110
			After:	0000 0000 0000 0000 0000 0000 0000 0011

			Ex2: 110 shifted 1 bit to the left with "<<" turns into 1100.
			Before:	0000 0000 0000 0000 0000 0000 0000 0110
			After:	0000 0000 0000 0000 0000 0000 0000 1100

			It's important to note that the values on each extremety WON'T be trasnfered to the otehr side. So, for example:
			1011 shifted to the right is actually 0101, and NOT 1101, meaning the "1" at the rightmost side or the original sequence was DISCARDED.

			And thanks to the way bits and bytes works in power of 2, this has a really nice property to it:

			If we shift 1 bit to the RIGHT, we're basically DIVIDING the original value by 2
			If we shift 1 bit to the LEFT, we're basically MULTIPLYING the value by 2
			
			So, for example:
			1 << 1 is 2
			1 << 2 is 4
			1 << 3 is 8
			5 << 1 is 10
			100 << 2 is 400
			
			100 >> 1 is 50
			4 >> 1 is 2
			400 >> 3 is 50
			 */

			//We're doing a bit shit operation on the texture size here, which basically means that we're taking the original size and diving by (2 ^ some value)
			//And thanks to the bilinear filtering (which is the default filter mode of textures, we get a blurry low res image.
			int width = source.width >> downResAmount;
			int height = source.height >> downResAmount;

			RenderTexture rt = RenderTexture.GetTemporary(width, height);
			Graphics.Blit(source, rt);

			for (int i = 0; i < blurAmount; i++)
			{
				RenderTexture rt2 = RenderTexture.GetTemporary(width, height);
				Graphics.Blit(rt, rt2, effectMaterial);
				RenderTexture.ReleaseTemporary(rt);
				rt = rt2;
			}

			Graphics.Blit(rt, destination);
			RenderTexture.ReleaseTemporary(rt);
		}
	}
}
