using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SinPropertyShaderTest : MonoBehaviour {
	public string propertyName;
	public float min, max, speed = 1;
	public Material optionalMat;

	// Use this for initialization
	void Awake () {
		if(optionalMat == null)
		{
			Renderer rend = GetComponent<Renderer>();
			optionalMat = rend.sharedMaterial;
		}
	}
	
	// Update is called once per frame
	void Update () {
		if(optionalMat != null)
		{
			float t = Mathf.Lerp(min, max, (Mathf.Sin(Time.time * speed) * .5f) + .5f);
			optionalMat.SetFloat(propertyName, t);
		}
	}
}
