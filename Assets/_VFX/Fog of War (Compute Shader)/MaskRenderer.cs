using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskRenderer : Singleton<MaskRenderer>
{
	public List<HexGridCell> cells = new List<HexGridCell>();
	public ComputeShader computeShader; //We're gonna use a compute shader to rewrite the texture every frame
	[Range(64, 4096)]
	public int textureSize = 1024;
	public float mapSize;
	public float radius = 1;
	[Range(0, 1)]
	public float blendDistance = 0.8f;
	public float animDuration = 1;
	public Material[] materials;

	private bool isReady;
	private RenderTexture maskTexture;

	//Store an ID for each property we're gonna update on the shader. By doing this, we're avoiding string comparisions, specially if we're updating the shader every frame. (nice tip!)
	private readonly int textureSizeID = Shader.PropertyToID("_TextureSize"); //Also, we can call functions whilie initializing variables if the functions is static.
	private readonly int cellCountID = Shader.PropertyToID("_CellCount");
	private readonly int mapSizeID = Shader.PropertyToID("_MapSize");
	private readonly int radiusID = Shader.PropertyToID("_Radius");
	private readonly int blendID = Shader.PropertyToID("_Blend");
	private readonly int maskTextureID = Shader.PropertyToID("_MaskTexture");
	private readonly int cellBufferID = Shader.PropertyToID("_CellBuffer");
	private readonly int offsetID = Shader.PropertyToID("_Offset");

	private List<CellBufferEntry> bufferElements = new List<CellBufferEntry>();
	private ComputeBuffer shaderBuffer;

	private struct CellBufferEntry
	{
		public float posX;
		public float posY;
		public float visibility;
	}

	private IEnumerator Start()
	{
		//Wait for all cells to add themselves to the list
		yield return null;

		maskTexture = new RenderTexture(textureSize, textureSize, 0, RenderTextureFormat.ARGB32) {
			enableRandomWrite = true
		};

		maskTexture.Create();

		computeShader.SetInt(textureSizeID, textureSize);
		computeShader.SetTexture(0, maskTextureID, maskTexture);
		computeShader.SetFloat(mapSizeID, mapSize);

		for (int i = 0; i < materials.Length; i++)
		{
			materials[i].SetTexture(maskTextureID, maskTexture);
			materials[i].SetFloat(mapSizeID, mapSize);
		}

		foreach (var cell in cells)
		{
			CellBufferEntry entry = new CellBufferEntry();
			bufferElements.Add(entry);
		}

		/*Here we're creating the compute buffer. The first argument is the number of elemenets in total(in this case, the number of cells * the number of variables for each cell),
		 and the second argument is the size in bytes of each element. To discover the sive of a type, we can use the command "sizeof" and pass the corresponding type as an argument.*/
		shaderBuffer = new ComputeBuffer(bufferElements.Count * 3, sizeof(float));

		isReady = true;
	}

	protected override void OnDestroy()
	{
		//We have to clear the memory for these Objects, since Unity's garbage collector won't do it for us.
		shaderBuffer?.Dispose();
		maskTexture?.Release();
	}

	private void Update()
	{
		if (!isReady)
			return;

		//Here we update the list of the elements we're gonna put into the sahder buffer with the actual cells data
		for (int i = 0; i < cells.Count; i++)
		{
			CellBufferEntry entry = bufferElements[i];
			entry.posX = cells[i].transform.localPosition.x;
			entry.posY = cells[i].transform.localPosition.z;
			entry.visibility = cells[i].visibility;
			bufferElements[i] = entry;
		}

		//Updates the materials
		for (int i = 0; i < materials.Length; i++)
		{
			materials[i].SetVector(offsetID, transform.position); //Add the position of this parent object, so we can move the map around freely
		}

		//Here we set the data of the compute buffer and then set the buffer into the compute shader.
		shaderBuffer.SetData(bufferElements); //Here, the data will be set as an array containing each field of the struct in order, like: [cell0.posX, cell0.posY, cell0.visibility, cell1.posX, cellY.posY, ..., cellN.visbility]
		computeShader.SetBuffer(0, cellBufferID, shaderBuffer); //The first parameter is the kernel ID. A kernel is a function in the compute shader that'll execute our functionality. Kinda like a thread, but not exactly (a kernel will be executed in multiple threads)

		//Here we update other variables in the compute shader, just like any other shader
		computeShader.SetInt(cellCountID, bufferElements.Count);
		computeShader.SetFloat(radiusID, radius / mapSize); //Here and in the line below we are dividing by the map size so we can have a range from 0-1, just like our UV coordinates. This way, we can modify the texture  at the same location as our cell
		computeShader.SetFloat(blendID, blendDistance / mapSize);

		/*"Dispatch" executes the compute kernel in the shader.
		 The other 3 parameters is how many worker groups we want in each dimension of our texture.
		Since we're working with a 2D texture, we can set the Z value to 1.
		For the X and Y axis, we can calculate the amount of workers by getting the texture size and dividing it by 8 (why? idk).
		This basically means we'll render 8x8 square of texels at once, until we cover the entire texture*/
		computeShader.Dispatch(0, Mathf.CeilToInt(textureSize / 8.0f), Mathf.CeilToInt(textureSize / 8.0f), 1);
	}

	public void RegisterCell(HexGridCell cell)
	{
		if (cells.Contains(cell))
			return;

		cells.Add(cell);
	}
}
