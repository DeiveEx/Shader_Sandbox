using UnityEngine;

public class LaserShooter : MonoBehaviour
{
	public Transform source;
	public Transform sourcePivot;
	public GameObject laserParent;
	public Transform laserHead;
	public Transform laserBody;
	public Transform laserTail;
	public ParticleSystem laserTrailParticles;
	public Material[] materialsToChange;

	private bool isShooting;
	private Vector3 laserSize;
	private ParticleSystem.Particle[] trailParticlesArray;
	private int trailIndex;

	private void Start()
	{
		laserSize = laserBody.localScale;
		trailParticlesArray = new ParticleSystem.Particle[laserTrailParticles.main.maxParticles];
		laserTrailParticles.Play();
	}

	// Update is called once per frame
	void Update()
	{
		isShooting = false;

		if (Input.GetMouseButton(0))
		{
			Vector3 mousePos;

			//Check if we're clicking in a valid spot
			if (GetMouseWorldPos(out mousePos))
			{
				RaycastHit hit;
				Vector3 dir = mousePos - source.position;

				//Check if there's any obstruction between the source and the point we're clicking
				if (Physics.Raycast(source.position, dir, out hit))
				{
					//Rotates the laser to look at the target
					sourcePivot.LookAt(hit.point);

					//Updates the transform of the components
					laserHead.position = source.position;
					laserHead.rotation = source.rotation;

					laserBody.position = source.position;
					laserBody.rotation = source.rotation;

					laserTail.position = hit.point;
					laserTail.rotation = Quaternion.LookRotation(hit.normal);

					//Sets the laser size
					laserSize.z = Vector3.Distance(source.position, hit.point);
					laserBody.localScale = laserSize;

					//Updates the materials
					for (int i = 0; i < materialsToChange.Length; i++)
					{
						materialsToChange[i].SetFloat("_UVTiling", laserSize.z);
					}

					//Updates the trail particles
					laserTrailParticles.GetParticles(trailParticlesArray);
					trailParticlesArray[trailIndex].position = hit.point + hit.normal * 0.1f;
					trailParticlesArray[trailIndex].rotation3D = Quaternion.LookRotation(-hit.normal).eulerAngles;
					trailParticlesArray[trailIndex].startSize = 1;
					trailParticlesArray[trailIndex].startColor = Color.white;
					trailParticlesArray[trailIndex].startLifetime = laserTrailParticles.main.startLifetime.constantMax;
					trailParticlesArray[trailIndex].remainingLifetime = laserTrailParticles.main.startLifetime.constantMax;
					laserTrailParticles.SetParticles(trailParticlesArray);

					trailIndex++;

					if (trailIndex >= trailParticlesArray.Length)
					{
						trailIndex = 0;
					}
				}

				//Sets the flag to enable the laser object
				isShooting = true;
			}
		}

		//Enables/Disables the laser
		if (isShooting && !laserParent.gameObject.activeSelf)
		{
			laserParent.gameObject.SetActive(true);
		}
		else if (!isShooting && laserBody.gameObject.activeSelf)
		{
			laserParent.gameObject.SetActive(false);
		}
	}

	private bool GetMouseWorldPos(out Vector3 mouseWorldPos)
	{
		RaycastHit hit;

		if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hit))
		{
			mouseWorldPos = hit.point;
			return true;
		}

		mouseWorldPos = Vector3.zero;
		return false;
	}
}
