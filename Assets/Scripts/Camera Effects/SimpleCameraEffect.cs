using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode] //So we can see the effect outside play mode
public class SimpleCameraEffect : MonoBehaviour
{
    public Material effectMaterial;

	//This method is called if this script is attached to a camera
	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if(effectMaterial != null)
		{
			//Applies the shader effect into the camera texture
			Graphics.Blit(source, destination, effectMaterial);
		}
	}
}
