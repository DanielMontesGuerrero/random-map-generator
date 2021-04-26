using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;

public class RuleTileGenerator
{

	private const string RULE_TILES_PATH = "Assets/Tiles/RuleTiles/";

	public static void CreateAllRuleTiles()
	{
		List<Rule> rules = new List<Rule>();
		rules.Add(new Rule{
			isMultipleSprite = true,
			isDefault = true,
			spriteMultiplePath = "Mountain/Tileset",
			spritePath = "ground_middle",
			matrixOfNeighbors = new int[,] {}
		});
		rules.Add(new Rule{
			isMultipleSprite = true,
			isDefault = false,
			spriteMultiplePath = "Mountain/Tileset",
			spritePath = "grass",
			matrixOfNeighbors = new int[,] {{0, -1, 0}, {0, 0, 0}, {0, 0, 0}}
		});
		RuleTile rule = CreateRuleTile("example", rules);
	}

	/// Creates a RuleTile
	private static RuleTile CreateRuleTile(string name, List<Rule> rules)
	{
		RuleTile ruleTile = ScriptableObject.CreateInstance("RuleTile") as RuleTile;

		AssetDatabase.CreateAsset(ruleTile, RULE_TILES_PATH + name + ".asset");

		for (int i = 0; i < rules.Count; i++)
		{
			Sprite sprite = null;
			if (rules[i].isMultipleSprite)
			{
				Sprite[] multipleSprites = Resources.LoadAll<Sprite>(rules[i].spriteMultiplePath);
				sprite = multipleSprites.Single(s => s.name == rules[i].spritePath);
			}
			else
			{
				sprite = Resources.Load<Sprite>(rules[i].spritePath) as Sprite;
			}
			if (sprite == null)
			{
				Debug.Log("Resource load failed");
			}
			if (rules[i].isDefault)
			{
				ruleTile.m_DefaultSprite = sprite;
			}
			else
			{
				RuleTile.TilingRule rule = new RuleTile.TilingRule();
				rule.m_Sprites[0] = sprite;
				AddNeighbors(rule, rules[i].matrixOfNeighbors);
				ruleTile.m_TilingRules.Add(rule);
			}
		}

		EditorUtility.SetDirty(ruleTile);
		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
		return ruleTile;
	}

	/// Matrix use for rules
	/// {
	///		{1, 2, 3},
	///		{4, 5, 6},
	///		{7, 8, 9}
	/// }
	/// 1 : has neighbor
	/// 0 : doesn't not matter
	/// -1 : doesn't have neighbor
	private static void AddNeighbors(RuleTile.TilingRule rule, int[,] matrix)
	{
		Dictionary<Vector3Int, int> dict = rule.GetNeighbors();
		List<Vector3Int> neighbors = rule.m_NeighborPositions;
		for(int i = 0, x = 0, y = 0; i < neighbors.Count; i++, y = (y + 1) % 3)
		{
			if (x == 1 && y == 1)
			{
				i--;
				continue;
			}
			if (matrix[x, y] == 1)
			{
				dict.Add(neighbors[i], RuleTile.TilingRuleOutput.Neighbor.This);
			}
			else if(matrix[x, y] == -1)
			{
				dict.Add(neighbors[i], RuleTile.TilingRuleOutput.Neighbor.NotThis);
			}
			if (y == 2)
			{
				x++;
			}
		}
		rule.ApplyNeighbors(dict);
	}

}
