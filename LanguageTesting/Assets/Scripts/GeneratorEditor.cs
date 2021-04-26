using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Generator))]
public class GeneratorEditor : Editor
{
	public override void OnInspectorGUI()
	{
		base.OnInspectorGUI();
		Generator generator = (Generator) target;
		if (GUILayout.Button("Generate Map"))
		{
			generator.GenerateMap();
		}
		if (GUILayout.Button("Clear Map"))
		{
			generator.ClearMap();
		}
		if (GUILayout.Button("Generate All Rule Tiles"))
		{
			generator.GenerateAllRuleTiles();
		}
	}
}
