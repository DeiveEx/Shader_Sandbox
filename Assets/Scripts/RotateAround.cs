using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateAround : MonoBehaviour {
	public Vector3 axis;
	public float degreesPerSec = 90;
	
	// Update is called once per frame
	void Update () {
		transform.Rotate(axis, degreesPerSec * Time.deltaTime);
	}
}
