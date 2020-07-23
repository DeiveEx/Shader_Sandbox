using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetShaderObjectPos : MonoBehaviour
{
    public Material mat;
    public string propertyName;
    
    // Update is called once per frame
    void Update()
    {
        if(mat != null)
		{
            mat.SetVector(propertyName, transform.position);
		}
    }
}
