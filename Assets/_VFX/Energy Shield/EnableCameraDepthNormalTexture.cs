using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class EnableCameraDepthNormalTexture : MonoBehaviour
{
	private DepthTextureMode defaultMode;

	// Start is called before the first frame update
	private void OnEnable()
	{
		defaultMode = Camera.main.depthTextureMode;
		Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
	}

	private void OnDisable()
	{
		Camera.main.depthTextureMode = defaultMode;
	}
}
