using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(LineRenderer))]
public class CustomTrail : MonoBehaviour
{
    public float lifeTime = 1;
    public float minVertexDistance = 0.1f;

    private LineRenderer line;
    private List<TrailPoint> points = new List<TrailPoint>();
    private Vector3 lastPos;

    private class TrailPoint
	{
        public Vector3 position;
        public float lifeTime;
	}

    // Start is called before the first frame update
    void Awake()
    {
        line = GetComponent<LineRenderer>();
        line.alignment = LineAlignment.TransformZ;
        line.useWorldSpace = false;

        lastPos = transform.position;
    }

	// Update is called once per frame
	void LateUpdate()
    {
        //Check if we need to create a new point
        if (Vector3.Distance(transform.position, lastPos) > minVertexDistance)
		{
            CreatePoint();
		}

        //Updates and removes points that are too old
        for (int i = 0; i < points.Count; i++)
        {
            points[i].lifeTime -= Time.deltaTime;

            if(points[i].lifeTime < 0)
			{
                points.RemoveAt(i);
                i--;
			}
        }

        //Updates the line Renderer
        line.positionCount = points.Count;

        for (int i = 0; i < points.Count; i++)
		{
            line.SetPosition(i, transform.InverseTransformPoint(points[i].position));
		}
    }

    private void CreatePoint()
	{
        TrailPoint p = new TrailPoint() {
            position = transform.position,
            lifeTime = lifeTime
        };

        points.Insert(0, p);
        lastPos = transform.position;
    }
}
