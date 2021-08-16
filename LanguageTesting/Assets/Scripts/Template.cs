public class Template
{
	public bool edgeAreWalls { get; set; }
	public int interval { get; set; }
	public int minSectionWidth { get; set; }
	public float modifier { get; set; }
	public float seed { get; set; }
	public int requiredFloorPercent { get; set; }
	public int minPathWidth { get; set; }
	public int maxPathWidth { get; set; }
	public int roughness { get; set; }
	public int curvyness { get; set; }
	public int maxPathChange { get; set; }
	public int fillPercent { get; set; }
	public int smoothCount { get; set; }
	public string algorithm { get; set; }
	public string filler { get; set; }

	public Template()
	{}

}
