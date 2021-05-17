public class Section
{
	public int width { get; set; }
	public int height { get; set; }
	public int xBase { get; set; }
	public int yBase { get; set; }
	public Algorithm algorithm { get; set; }
	public int xIni { get; set; }
	public int yIni { get; set; }
	public int xEnd { get; set; }
	public int yEnd { get; set; }
	private int[,] map { get; set; }
	private bool[,] visited { get; set; }
	private int[] directionX = {1, -1, 0,  0};
	private int[] directionY = {0,  0, 1, -1};


	public Section(int[,] map, Algorithm algorithm)
	{
		this.map = map;
		this.algorithm = algorithm;
		visited = new bool[width, height];
		for (int i = 0; i < width; i++)
		{
			for (int j = 0; j < height; j++)
			{
				visited[i, j] = false;
			}
		}
		if (algorithm == Algorithm.PerlinNoise
				|| algorithm == Algorithm.PerlinNoiseSmoothed
				|| algorithm == Algorithm.RandomWalk
				|| algorithm == Algorithm.RandomWalkSmoothed
				|| algorithm == Algorithm.DirectionalTunnel)
		{
			FindIni();
			FindEnd(xIni, yIni);
		}
	}

	void FindEnd(int x, int y)
	{
		if (algorithm == Algorithm.PerlinNoise
				|| algorithm == Algorithm.PerlinNoiseSmoothed
				|| algorithm == Algorithm.RandomWalk
				|| algorithm == Algorithm.RandomWalkSmoothed)
		{
			if (x > xEnd || (x == xEnd && y < yEnd))
			{
				xEnd = x;
				yEnd = y;
			}
		}
		else if (algorithm == Algorithm.DirectionalTunnel)
		{
			if (y < yEnd || (y == yEnd && x < xEnd))
			{
				xEnd = x;
				yEnd = y;
			}
		}
		visited[x - xBase, y - yBase] = true;
		for (int i = 0; i < 4; i++)
		{
			int nxtX, nxtY;
			nxtX = xBase + x + directionX[i];
			nxtY = yBase + y + directionY[i];
			if (!IsValid(nxtX, nxtY))
			{
				continue;
			}
			if(!visited[nxtY - xBase, nxtY - yBase]){
				FindEnd(nxtX, nxtY);
			}
		}
	}

	bool IsValid(int x, int y)
	{
		if(x < 0 || x >= width || y < 0 || y >= height)
		{
			return false;
		}
		return true;
	}

	void FindIni()
	{
		int limit = 0;
		if (algorithm == Algorithm.PerlinNoise
				|| algorithm == Algorithm.PerlinNoiseSmoothed
				|| algorithm == Algorithm.RandomWalk
				|| algorithm == Algorithm.RandomWalkSmoothed)
		{
			limit = height;
		}
		else if (algorithm == Algorithm.DirectionalTunnel)
		{
			limit = width;
		}
		for (int i = 0; i < limit; i++)
		{
			int x, y;
			if (algorithm == Algorithm.PerlinNoise
					|| algorithm == Algorithm.PerlinNoiseSmoothed
					|| algorithm == Algorithm.RandomWalk
					|| algorithm == Algorithm.RandomWalkSmoothed)
			{
				x = xBase;
				y = i + yBase;
			}
			else if (algorithm == Algorithm.DirectionalTunnel)
			{
				x = xBase + height - 1;
				y = i + yBase;
			}
			else
			{
				continue;
			}
			if (map[x, y] == 0)
			{
				xIni = x;
				yIni = y;
				break;
			}
		}
	}
}
