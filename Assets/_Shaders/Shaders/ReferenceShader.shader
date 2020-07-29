//Define the name and path of the Shader in the material inspector
Shader "Custom Shaders/ReferenceShader"
{
	//Defines the  properties of the inspector
	Properties
	{
		/*
		Each property is defined as:
		
				[OptionalAttribute]_VariableName ("Inspector label", VariableType) = (DefaultValue)
		
		Also, we DON'T use semicolons (;) at the end of each property
		For a list of availbale attributes/Property Drawers, check the links:
		https://docs.unity3d.com/Manual/SL-Properties.html
		https://docs.unity3d.com/ScriptReference/MaterialPropertyDrawer.html
		*/
		[HDR]_Color ("Main Color", Color) = (1, 1, 1, 1)
	}

	//A subshader is basically a shader code that is hardware dependent. That means tou can write different SubShaders for different devices
	//that uses different technologies, but Unity will choose the FIRST one that is compatible with the current device.
	SubShader
	{
		//A Pass is the code that'll be executed in one of Unity's Render passes. You can have multiple passes in a single shader where tou can draw different things.
		//A pass must always have at least a Vertex and a Fragment function.
		Pass
		{
			//Now we can start writting ou shader code in the specified language. In this case we're using "CGPROGRAM", which is a language created by Nvidia.
			//IMPORTANT: CGPROGRAM DOES USE SEMICOLON!
			CGPROGRAM

			//Here we define which functions will work as each part of our shader. All Shaders must have AT LEAST a vertex and a fragment Shader inside. You can check other parts on the "HLSL Snippets" in the url:
			//https://docs.unity3d.com/Manual/SL-ShaderPrograms.html
			#pragma vertex vert
			#pragma fragment frag

			//Imports the Unity CG library
			#include "UnityCG.cginc"

			//Here we declare which values we want to take from each vertex of the Mesh and put it into a Struct. The list of all available values can be found on:
			//https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics#vertex-shader-semantics
			struct VertexInput
			{
				//Here we are declaring a variable and defining wich value it's gonna take from the Vertex as:
				//		type variableName : vertexPropertyToTake
				float4 vertex : POSITION;
			};

			//Here we define the Vertex output that we want our vertex shader to return, also as a Struct
			struct VertexOutput
			{
				//The declaration works just like the Vertex input, but now the property we want to take are for the Fragment Shader. The list of available values can be found on:
				//https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics#pixel-shader-semantics
				//We can also use what's called an "Interpolator", which represets a interpolated value between each vertex that is given to the fragment shader. Usually you use them
				//by setting the value as "TEXCOORDn", in which [n] is a number: Ex:
				//		float2 varName: TEXTCOORD0
				float4 pos : SV_POSITION;
			};

			//By declaring a variable with the EXACT same name as one of the variables defined in the "Properties" section above, Unity will feed the value of that property into this variable.
			half4 _Color;

			//Here we define the body of our Vertex Shader. It'll take a input and return an output.
			VertexOutput vert(VertexInput v)
			{
				//Declare the Output struct
				VertexOutput o;

				//Convert the vertex position from object space to clip space using an Unity's helper function. For a list of helper functions, check the link:
				//https://docs.unity3d.com/Manual/SL-BuiltinFunctions.html
				o.pos = UnityObjectToClipPos(v.vertex);

				//Return the output
				return o;
			}

			//Here we define the body of our Fragment Shader. It'll the the output of the Vertex Shader as input and it must return a color, which will be the pixel color.
			//A color is a Vector4, so we can use a "float4", "fixed4" or "half4" for that, but we also must say that this return value must be interpreted as a COLOR (SV_TARGET).
			half4 frag(VertexOutput i) : SV_TARGET
			{
				//There's also a number of functions from nVidia for the CGPROGRAM language that can be checked here:
				//https://developer.download.nvidia.com/cg/index_stdlib.html

				//Returns a color
				return _Color; 
			}

			//And here we end our CGPROGRAM code
			ENDCG
		}
	}
}