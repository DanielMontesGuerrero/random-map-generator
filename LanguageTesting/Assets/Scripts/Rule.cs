public class Rule
{
	public bool isMultipleSprite { get; set; }
	public bool isDefault { get; set; }
	public string spriteMultiplePath { get; set; }
	public string spritePath { get; set; }
	public int[,] matrixOfNeighbors { get; set; }

	public Rule()
	{}

}
