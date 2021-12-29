using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CycleObjects : MonoBehaviour
{
    public GameObject[] objs;

	private int currentID;

	private void Start()
	{
		currentID = 0;
		GoToNextObj(0);
	}

	private void Update()
	{
		if (Input.GetKeyDown(KeyCode.RightArrow))
		{
			GoToNextObj(1);
		}
		else if (Input.GetKeyDown(KeyCode.LeftArrow))
		{
			GoToNextObj(-1);
		}
	}

	public void GoToNextObj(int dir)
	{
		currentID += dir;

		if (currentID >= objs.Length)
			currentID = 0;

		if (currentID < 0)
			currentID = objs.Length - 1;

		for (int i = 0; i < objs.Length; i++)
		{
			objs[i].SetActive(currentID == i);
		}
	}
}
