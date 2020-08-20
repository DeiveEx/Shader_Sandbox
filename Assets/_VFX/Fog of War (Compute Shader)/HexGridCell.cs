using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexGridCell : MonoBehaviour
{
	[Range(0, 1)]public float visibility;
	public bool isVisible;

    // Start is called before the first frame update
    void Start()
    {
        MaskRenderer.Instance.RegisterCell(this);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

	private void OnMouseDown()
	{
		ToggleVisibility();
	}

	private void OnMouseEnter()
	{
		ToggleVisibility();
	}

	public void ToggleVisibility()
	{
		if (Input.GetMouseButton(0))
		{
			StopAllCoroutines();
			StartCoroutine(AnimateVisibility(isVisible ? 0 : 1));
			isVisible = !isVisible;
		}
	}

	private IEnumerator AnimateVisibility(float target)
	{
		float timePassed = 0;
		float start = visibility;

		while(timePassed <= MaskRenderer.Instance.animDuration)
		{
			timePassed += Time.deltaTime;
			visibility = Mathf.Lerp(start, target, timePassed / MaskRenderer.Instance.animDuration);
			yield return null;
		}

		visibility = target;
	}
}
