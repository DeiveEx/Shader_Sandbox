using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class Overdraw : MonoBehaviour
{
	public Shader replacementShader;
	public Color overdrawColor;

	private Camera cam;

	private void Awake()
	{
		cam = GetComponent<Camera>();
	}

	private void OnEnable()
	{
		if (replacementShader != null)
		{
			/*A replacement shader is a shader that literally replaces the shader used to draw certain objects based on their tag.*/
			//Set the replamente shader of the camera.
			cam.SetReplacementShader(replacementShader, ""); //By passing an empty tag, we're telling unity to replace every object's shader, no matter tejir tag
		}
	}

	private void OnDisable()
	{
		cam.ResetReplacementShader();
	}

	private void OnValidate()
	{
		//We can use this value to set a Shader property without having an material instance. Note that this will set the SHADER property, so every place this shader is use will have this value.
		Shader.SetGlobalColor("_OverdrawColor", overdrawColor);
	}
}
