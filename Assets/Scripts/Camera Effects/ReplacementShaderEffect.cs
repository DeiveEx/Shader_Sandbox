using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour
{
    public Shader replacementShader;
	public string replacementTag;

	private Camera cam;

	private void Awake()
	{
		cam = GetComponent<Camera>();
	}

	private void OnEnable()
	{
		if(replacementShader != null)
		{
			/*A replacement shader is a shader that literally replaces the shader used to draw certain objects based on their tag.*/

			//Set the replamente shader of the camera.
			cam.SetReplacementShader(replacementShader, replacementTag);
		}
	}

	private void OnDisable()
	{
		cam.ResetReplacementShader();
	}
}
