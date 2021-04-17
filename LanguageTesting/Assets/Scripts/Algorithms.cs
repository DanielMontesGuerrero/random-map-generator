using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;

public class Algorithms : MonoBehaviour
{
    public static int[,] GenerateMatrix(int width, int height, bool fill_matrix)
    {
        int [,] matrix = new int[width, height];
        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++){
                matrix[i, j] = (fill_matrix ? 1: 0);
            }
        }
        return matrix;
    }

    public static int[,] GenerateMap(int[,] map, Tilemap tilemap, TileBase tile)
    {
        tilemap.ClearAllTiles();
        //Loop through the width of the map
        for (int i = 0; i <= map.GetUpperBound(0); i++)
        {
            //Loop through the height of the map
            for (int j = 0; j <= map.GetUpperBound(1); j++){
                // 1 = tile, 0 = no tile
                if (map[i, j] == 1)
                {
                    tilemap.SetTile(new Vector3Int(i, j, 0), tile);
                }
            }
        }
        return map;
    }

    public static int[,] PerlinNoise(int[,] map, float seed)
    {
        //Used to reduced the position of the Perlin point
        float reduction = 0.5f;
        //Create the Perlin
        for (int x = 0; x <= map.GetUpperBound(0); x++)
        {
            int height = Mathf.FloorToInt((Mathf.PerlinNoise(x, seed) - reduction) * map.GetUpperBound(1));
            //Make sure the noise starts near the halfway point of the height
            height += (map.GetUpperBound(1) / 2); 
            for (int y = height; y >= 0; y--)
            {
                map[x, y] = 1;
            }
        }
        return map;
    }

    public static int[,] PerlinNoiseSmoothed(int[,] map, float seed, int interval)
    {
        //Smooth the noise and store it in the int array
        if (interval > 1)
        {
            //Used to reduced the position of the Perlin point
            float reduction = 0.5f;
            //Used in the smoothing process
            Vector2Int currentPos, lastPos; 
            //The corresponding points of the smoothing. One list for x and one for y
            List<int> noiseX = new List<int>();
            List<int> noiseY = new List<int>();
            //Generate the noise
            for (int x = 0; true; x += interval)
            {
                x = Mathf.Min(map.GetUpperBound(0), x);
                int newPoint = Mathf.FloorToInt((Mathf.PerlinNoise(x, (seed * reduction))) * map.GetUpperBound(1));
                noiseY.Add(newPoint);
                noiseX.Add(x);
                if (x == map.GetUpperBound(0))
                {
                    break;
                }
            }
            //Start at 1 so we have a previous position already
            for (int i = 1; i < noiseY.Count; i++) 
            {
                //Get the current position
                currentPos = new Vector2Int(noiseX[i], noiseY[i]);
                //Also get the last position
                lastPos = new Vector2Int(noiseX[i - 1], noiseY[i - 1]);
                //Find the difference between the two
                Vector2 diff = currentPos - lastPos;
                //Set up what the height change value will be 
                float heightChange = diff.y / interval;
                //Determine the current height
                float currHeight = lastPos.y;
                //Work our way through from the last x to the current x
                for (int x = lastPos.x; x < currentPos.x; x++)
                {
                    for (int y = Mathf.FloorToInt(currHeight); y > 0; y--)
                    {
                        map[x, y] = 1;
                    }
                    currHeight += heightChange;
                }
            }
        }
        else
        {
            //Defaults to a normal Perlin gen
            map = PerlinNoise(map, seed);
        }
        return map;
    }

    public static int[,] RandomWalk(int[,] map, float seed)
    {
        //Seed our random
        System.Random rand = new System.Random(seed.GetHashCode()); 
        //Set our starting height
        int lastHeight = Random.Range(0, map.GetUpperBound(1));
        //Cycle through our width
        for (int x = 0; x <= map.GetUpperBound(0); x++) 
        {
            //Flip a coin
            int nextMove = rand.Next(2);
            //If heads, and we aren't near the bottom, minus some height
            if (nextMove == 0 && lastHeight > 2) 
            {
                lastHeight--;
            }
            //If tails, and we aren't near the top, add some height
            else if (nextMove == 1 && lastHeight < map.GetUpperBound(1) - 1) 
            {
                lastHeight++;
            }
            //Circle through from the lastheight to the bottom
            for (int y = lastHeight; y >= 0; y--) 
            {
                map[x, y] = 1;
            }
        }
        //Return the map
        return map; 
    }

    public static int[,] RandomWalkSmoothed(int[,] map, float seed, int minSectionWidth)
    {
        //Seed our random
        System.Random rand = new System.Random(seed.GetHashCode());
        //Determine the start position
        int lastHeight = Random.Range(0, map.GetUpperBound(1));
        //Used to determine which direction to go
        int nextMove = 0;
        //Used to keep track of the current sections width
        int sectionWidth = 0;
        //Work through the array width
        for (int x = 0; x <= map.GetUpperBound(0); x++)
        {
            //Determine the next move
            nextMove = rand.Next(2);
            //Only change the height if we have used the current height more than the minimum required section width
            if (nextMove == 0 && lastHeight > 0 && sectionWidth > minSectionWidth)
            {
                lastHeight--;
                sectionWidth = 0;
            }
            else if (nextMove == 1 && lastHeight < map.GetUpperBound(1) && sectionWidth > minSectionWidth)
            {
                lastHeight++;
                sectionWidth = 0;
            }
            //Increment the section width
            sectionWidth++;
            //Work our way from the height down to 0
            for (int y = lastHeight; y >= 0; y--)
            {
                map[x, y] = 1;
            }
        }
        //Return the modified map
        return map;
    }

    public static int[,] PerlinNoiseCave(int[,] map, float modifier, bool edgesAreWalls)
    {
        int newPoint;
        for (int x = 0; x < map.GetUpperBound(0); x++)
        {
            for (int y = 0; y < map.GetUpperBound(1); y++)
            {

                if (edgesAreWalls && (x == 0 || y == 0 || x == map.GetUpperBound(0) - 1 || y == map.GetUpperBound(1) - 1))
                {
                    map[x, y] = 1; //Keep the edges as walls
                }
                else
                {
                    //Generate a new point using Perlin noise, then round it to a value of either 0 or 1
                    newPoint = Mathf.RoundToInt(Mathf.PerlinNoise(x * modifier, y * modifier));
                    map[x, y] = newPoint;
                }
            }
        }
        return map;
    }

    public static int[,] RandomWalkCave(int[,] map, float seed,  int requiredFloorPercent)
    {
        //Seed our random
        System.Random rand = new System.Random(seed.GetHashCode());

        //Define our start x position
        int floorX = rand.Next(1, map.GetUpperBound(0));
        //Define our start y position
        int floorY = rand.Next(1, map.GetUpperBound(1));
        //Determine our required floorAmount
        int reqFloorAmount = ((map.GetUpperBound(1) * map.GetUpperBound(0)) * requiredFloorPercent) / 100; 
        //Used for our while loop, when this reaches our reqFloorAmount we will stop tunneling
        int floorCount = 0;

        //Set our start position to not be a tile (0 = no tile, 1 = tile)
        map[floorX, floorY] = 0;
        //Increase our floor count
        floorCount++;
        while (floorCount < reqFloorAmount)
        { 
            Debug.Log("floorCount = " + floorCount + " reqFloorAmount = " + reqFloorAmount);
            //Determine our next direction
            int randDir = rand.Next(4); 

            switch (randDir)
            {
                //Up
                case 0: 
                    //Ensure that the edges are still tiles
                    if ((floorY + 1) < map.GetUpperBound(1) - 1) 
                    {
                        //Move the y up one
                        floorY++;

                        //Check if that piece is currently still a tile
                        if (map[floorX, floorY] == 1) 
                        {
                            //Change it to not a tile
                            map[floorX, floorY] = 0;
                            //Increase floor count
                            floorCount++; 
                        }
                    }
                    break;
                    //Down
                case 1: 
                    //Ensure that the edges are still tiles
                    if ((floorY - 1) > 1)
                    { 
                        //Move the y down one
                        floorY--;
                        //Check if that piece is currently still a tile
                        if (map[floorX, floorY] == 1) 
                        {
                            //Change it to not a tile
                            map[floorX, floorY] = 0;
                            //Increase the floor count
                            floorCount++; 
                        }
                    }
                    break;
                    //Right
                case 2: 
                    //Ensure that the edges are still tiles
                    if ((floorX + 1) < map.GetUpperBound(0) - 1)
                    {
                        //Move the x to the right
                        floorX++;
                        //Check if that piece is currently still a tile
                        if (map[floorX, floorY] == 1) 
                        {
                            //Change it to not a tile
                            map[floorX, floorY] = 0;
                            //Increase the floor count
                            floorCount++; 
                        }
                    }
                    break;
                    //Left
                case 3: 
                    //Ensure that the edges are still tiles
                    if ((floorX - 1) > 1)
                    {
                        //Move the x to the left
                        floorX--;
                        //Check if that piece is currently still a tile
                        if (map[floorX, floorY] == 1) 
                        {
                            //Change it to not a tile
                            map[floorX, floorY] = 0;
                            //Increase the floor count
                            floorCount++; 
                        }
                    }
                    break;
            }
        }
        //Return the updated map
        return map;
    }

    public static int[,] DirectionalTunnel(int[,] map, int minPathWidth, int maxPathWidth, int maxPathChange, int roughness, int curvyness)
    {
        //This value goes from its minus counterpart to its positive value, in this case with a width value of 1, the width of the tunnel is 3
        int tunnelWidth = 1; 
        //Set the start X position to the center of the tunnel
        int x = map.GetUpperBound(0) / 2; 

        //Set up our random with the seed
        System.Random rand = new System.Random(Time.time.GetHashCode()); 

        //Create the first part of the tunnel
        for (int i = -tunnelWidth; i <= tunnelWidth; i++) 
        {
            map[x + i, 0] = 0;
        }
        //Cycle through the array
        for (int y = 1; y <= map.GetUpperBound(1); y++) 
        {
            //Check if we can change the roughness
            if (rand.Next(0, 100) > roughness) 
            {
                //Get the amount we will change for the width
                int widthChange = Random.Range(-maxPathWidth, maxPathWidth); 
                //Add it to our tunnel width value
                tunnelWidth += widthChange;
                //Check to see we arent making the path too small
                if (tunnelWidth < minPathWidth) 
                {
                    tunnelWidth = minPathWidth;
                }
                //Check that the path width isnt over our maximum
                if (tunnelWidth > maxPathWidth) 
                {
                    tunnelWidth = maxPathWidth;
                }
            }

            //Check if we can change the curve
            if (rand.Next(0, 100) > curvyness) 
            {
                //Get the amount we will change for the x position
                int xChange = Random.Range(-maxPathChange, maxPathChange); 
                //Add it to our x value
                x += xChange;
                //Check we arent too close to the left side of the map
                if (x < maxPathWidth) 
                {
                    x = maxPathWidth;
                }
                //Check we arent too close to the right side of the map
                if (x > (map.GetUpperBound(0) - maxPathWidth)) 
                {
                    x = map.GetUpperBound(0) - maxPathWidth;
                }
            }

            //Work through the width of the tunnel
            for (int i = -tunnelWidth; i <= tunnelWidth; i++) 
            {
                if((x + i) < 0 || (x + i) > map.GetUpperBound(0))
                {
                    continue;
                }
                map[x + i, y] = 0;
            }
        }
        return map;
    }

    public static int[,] GenerateCellularAutomata(int width, int height, float seed, int fillPercent, bool edgesAreWalls)
    {
        //Seed our random number generator
        System.Random rand = new System.Random(seed.GetHashCode());

        //Initialise the map
        int[,] map = new int[width, height];

        for (int x = 0; x <= map.GetUpperBound(0); x++)
        {
            for (int y = 0; y <= map.GetUpperBound(1); y++)
            {
                //If we have the edges set to be walls, ensure the cell is set to on (1)
                if (edgesAreWalls && (x == 0 || x == map.GetUpperBound(0) || y == 0 || y == map.GetUpperBound(1)))
                {
                    map[x, y] = 1;
                }
                else
                {
                    //Randomly generate the grid
                    map[x, y] = (rand.Next(0, 100) < fillPercent) ? 1 : 0; 
                }
            }
        }
        return map;
    }

    static int GetMooreSurroundingTiles(int[,] map, int x, int y, bool edgesAreWalls)
    {
        /* Moore Neighbourhood looks like this ('T' is our tile, 'N' is our neighbours)
         * 
         * N N N
         * N T N
         * N N N
         * 
         */

        int tileCount = 0;       

        for(int neighbourX = x - 1; neighbourX <= x + 1; neighbourX++)
        {
            for(int neighbourY = y - 1; neighbourY <= y + 1; neighbourY++)
            {
                if (neighbourX >= 0 && neighbourX <= map.GetUpperBound(0) && neighbourY >= 0 && neighbourY <= map.GetUpperBound(1))
                {
                    //We don't want to count the tile we are checking the surroundings of
                    if(neighbourX != x || neighbourY != y) 
                    {
                        tileCount += map[neighbourX, neighbourY];
                    }
                }
            }
        }
        return tileCount;
    }

    public static int[,] SmoothMooreCellularAutomata(int[,] map, bool edgesAreWalls, int smoothCount)
    {
        for (int i = 0; i < smoothCount; i++)
        {
            for (int x = 0; x <= map.GetUpperBound(0); x++)
            {
                for (int y = 0; y <= map.GetUpperBound(1); y++)
                {
                    int surroundingTiles = GetMooreSurroundingTiles(map, x, y, edgesAreWalls);

                    if (edgesAreWalls && (x == 0 || x == map.GetUpperBound(0) || y == 0 || y == map.GetUpperBound(1)))
                    {
                        //Set the edge to be a wall if we have edgesAreWalls to be true
                        map[x, y] = 1; 
                    }
                    //The default moore rule requires more than 4 neighbours
                    else if (surroundingTiles > 4)
                    {
                        map[x, y] = 1;
                    }
                    else if (surroundingTiles < 4)
                    {
                        map[x, y] = 0;
                    }
                }
            }
        }
        //Return the modified map
        return map;
    }

    static int GetVNSurroundingTiles(int[,] map, int x, int y, bool edgesAreWalls)
    {
        /* von Neumann Neighbourhood looks like this ('T' is our Tile, 'N' is our Neighbour)
         * 
         *   N 
         * N T N
         *   N
         *   
         */

        int tileCount = 0;

        //Keep the edges as walls
        if(edgesAreWalls && (x - 1 == 0 || x + 1 == map.GetUpperBound(0) || y - 1 == 0 || y + 1 == map.GetUpperBound(1)))
        {
            tileCount++;
        }

        //Ensure we aren't touching the left side of the map
        if(x - 1 > 0)
        {
            tileCount += map[x - 1, y];
        }

        //Ensure we aren't touching the bottom of the map
        if(y - 1 > 0)
        {
            tileCount += map[x, y - 1];
        }

        //Ensure we aren't touching the right side of the map
        if(x + 1 < map.GetUpperBound(0)) 
        {
            tileCount += map[x + 1, y];
        }

        //Ensure we aren't touching the top of the map
        if(y + 1 < map.GetUpperBound(1)) 
        {
            tileCount += map[x, y + 1];
        }

        return tileCount;
    }

    public static int[,] SmoothVNCellularAutomata(int[,] map, bool edgesAreWalls, int smoothCount)
    {
        for (int i = 0; i < smoothCount; i++)
        {
            for (int x = 0; x <= map.GetUpperBound(0); x++)
            {
                for (int y = 0; y <= map.GetUpperBound(1); y++)
                {
                    //Get the surrounding tiles
                    int surroundingTiles = GetVNSurroundingTiles(map, x, y, edgesAreWalls);

                    if (edgesAreWalls && (x == 0 || x == map.GetUpperBound(0) || y == 0 || y == map.GetUpperBound(1)))
                    {
                        //Keep our edges as walls
                        map[x, y] = 1; 
                    }
                    //von Neuemann Neighbourhood requires only 3 or more surrounding tiles to be changed to a tile
                    else if (surroundingTiles > 2) 
                    {
                        map[x, y] = 1;
                    }
                    else if (surroundingTiles < 2)
                    {
                        map[x, y] = 0;
                    }
                }
            }
        }
        //Return the modified map
        return map;
    }
}
