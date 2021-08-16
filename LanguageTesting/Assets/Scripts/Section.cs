public class Section
{
	public int width { get; set; }
	public int height { get; set; }
	public int[,] map { get; set; }
	public int id { get; set; }
	public int[] neighbors { get; set; }
	public int x { get; set; }
	public int y { get; set; }
	public string filler { get; set; }

	public Section()
	{}

	public void Init(Template template)
	{
		map = Algorithms.GenerateMatrix(width, height, false);
		filler = template.filler;
		switch(template.algorithm)
		{
			case "PerlinNoise":
				Algorithms.PerlinNoise(map, template.seed);
				break;
			case "PerlinNoiseSmoothed":
				Algorithms.PerlinNoiseSmoothed(map, template.seed, template.interval);
				break;
			case "RandomWalk":
				Algorithms.RandomWalk(map, template.seed);
				break;
			case "RandomWalkSmoothed":
				Algorithms.RandomWalkSmoothed(map, template.seed, template.minSectionWidth);
				break;
			case "PerlinNoiseCave":
				Algorithms.PerlinNoiseCave(map, template.modifier, template.edgeAreWalls);
				break;
			case "RandomWalkCave":
				map = Algorithms.GenerateMatrix(width, height, true);
				Algorithms.RandomWalkCave(map, template.seed, template.requiredFloorPercent);
				break;
			case "DirectionalTunnel":
				map = Algorithms.GenerateMatrix(width, height, true);
				Algorithms.DirectionalTunnel(map, template.seed, template.minPathWidth, template.maxPathWidth, template.maxPathChange, template.roughness, template.curvyness);
				break;
			case "CellularAutomata":
				map = Algorithms.GenerateCellularAutomata(width, height, template.seed, template.fillPercent, template.edgeAreWalls);
				break;
			case "MooreCellularAutomata":
				map = Algorithms.GenerateCellularAutomata(width, height, template.seed, template.fillPercent, template.edgeAreWalls);
				Algorithms.SmoothMooreCellularAutomata(map, template.edgeAreWalls, template.smoothCount);
				break;
			case "VonNeumannCellularAutomata":
				map = Algorithms.GenerateCellularAutomata(width, height, template.seed, template.fillPercent, template.edgeAreWalls);
				Algorithms.SmoothVNCellularAutomata(map, template.edgeAreWalls, template.smoothCount);
				break;
			default:
				break;
		}
	}

}
