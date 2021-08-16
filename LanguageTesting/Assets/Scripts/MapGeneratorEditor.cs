using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(MapGenerator))]
public class MapGeneratorEditor : Editor
{
	public override void OnInspectorGUI()
	{
		base.OnInspectorGUI();
		MapGenerator generator = (MapGenerator) target;
		if (GUILayout.Button("Generate Map"))
		{
			generator.GenerateAll();
		}
		if (GUILayout.Button("Clear Map"))
		{
			generator.ClearMap();
		}
	}
}
