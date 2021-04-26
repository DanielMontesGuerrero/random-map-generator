using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;

public enum Algorithm
{
    PerlinNoise,
    PerlinNoiseSmoothed,
    RandomWalk,
    RandomWalkSmoothed,
    PerlinNoiseCave,
    RandomWalkCave,
    DirectionalTunnel,
    CellularAutomata,
    MooreCellularAutomata,
    VonNeumannCellularAutomata
}

public class Generator : MonoBehaviour
{
    
    [Header("Tile references")]
    public Tilemap tilemap;
    public TileBase tile;

    [Header("Size")]
    public int width = 60;
    public int height = 34;

    [Header("Seed")]
    public bool useRandomSeed = true;
    public float seed = 0;

    [Header("Algorithm")]
    public Algorithm algorithm = Algorithm.PerlinNoise;

    [Header("PerlinNoiseSmoothed")]
    public bool useRandomInterval = true;
    public int interval = 1;

    [Header("RandomWalkSmoothed")]
    public bool useRandomMinSectionWidth = true;
    public int minSectionWidth;

    [Header("PerlinNoiseCave")]
    public bool edgeAreWalls = true;
    public bool useRandomModifier = true;
    public float modifier = 0;

    [Header("RandomWalkCave")]
    public bool useRandomRequiredFloorPercent = true;
    public int requiredFloorPercent = 0;

    [Header("DirectionalTunnel")]
    public bool useRandomMinWidth = true;
    public bool useRandomMaxWidth = true;
    public bool useRandomRoughness = true;
    public bool useRandomCurvyness = true;
    public bool useRandomMaxPathChange = true;
    public int minPathWidth = 1;
    public int maxPathWidth = 5;
    public int roughness = 5;
    public int curvyness = 5;
    public int maxPathChange = 0;

    [Header("CellularAutomata")]
    public bool useRandomFillPercent = true;
    public int fillPercent = 0;

    [Header("MooreCellularAutomata and VNCellularAutomata")]
    public bool useRandomSmoothCount = true;
    public int smoothCount = 0;

    // Generates the map
    public void GenerateMap(){
        Debug.Log("Generating the map...");
        tilemap.ClearAllTiles();
        if (useRandomSeed)
        {
            seed = Random.Range(0f, 1000f);
        }
        int[,] map = Algorithms.GenerateMatrix(width, height, false);
        switch (algorithm)
        {
            case Algorithm.PerlinNoise:
                Algorithms.PerlinNoise(map, seed);
                break;
            case Algorithm.PerlinNoiseSmoothed:
                if (useRandomInterval)
                {
                    interval = Random.Range(1, width);
                }
                Algorithms.PerlinNoiseSmoothed(map, seed, interval);
                break;
            case Algorithm.RandomWalk:
                Algorithms.RandomWalk(map, seed);
                break;
            case Algorithm.RandomWalkSmoothed:
                if (useRandomMinSectionWidth)
                {
                    minSectionWidth = Random.Range(1, width);
                }
                Algorithms.RandomWalkSmoothed(map, seed, minSectionWidth);
                break;
            case Algorithm.PerlinNoiseCave:
                if (useRandomModifier)
                {
                    modifier = Random.Range(0f, 1f);
                }
                Algorithms.PerlinNoiseCave(map, modifier, edgeAreWalls);
                break;
            case Algorithm.RandomWalkCave:
                map = Algorithms.GenerateMatrix(width, height, true);
                if (useRandomRequiredFloorPercent)
                {
                    requiredFloorPercent = Random.Range(0, 100);
                }
                Algorithms.RandomWalkCave(map, seed, requiredFloorPercent);
                break;
            case Algorithm.DirectionalTunnel:
                map = Algorithms.GenerateMatrix(width, height, true);
                if (useRandomMinWidth)
                {
                    minPathWidth = Random.Range(1, width / 2);
                }
                if (useRandomMaxWidth)
                {
                    maxPathWidth = Random.Range(minPathWidth, width);
                }
                if (useRandomRoughness)
                {
                    roughness = Random.Range(0, 100);
                }
                if (useRandomCurvyness)
                {
                    curvyness = Random.Range(0, 100);
                }
                if (useRandomMaxPathChange)
                {
                    maxPathChange = Random.Range(0, 100);
                }
                Algorithms.DirectionalTunnel(map, minPathWidth, maxPathWidth, maxPathChange, roughness, curvyness);
                break;
            case Algorithm.CellularAutomata:
                if (useRandomFillPercent)
                {
                    fillPercent = Random.Range(0, 100);
                }
                map = Algorithms.GenerateCellularAutomata(width, height, seed, fillPercent, edgeAreWalls);
                break;
            case Algorithm.MooreCellularAutomata:
                if (useRandomFillPercent)
                {
                    fillPercent = Random.Range(0, 100);
                }
                if (useRandomSmoothCount)
                {
                    smoothCount = Random.Range(1, 100);
                }
                map = Algorithms.GenerateCellularAutomata(width, height, seed, fillPercent, edgeAreWalls);
                Algorithms.SmoothMooreCellularAutomata(map, edgeAreWalls, smoothCount);
                break;
            case Algorithm.VonNeumannCellularAutomata:
                if (useRandomFillPercent)
                {
                    fillPercent = Random.Range(0, 100);
                }
                if (useRandomSmoothCount)
                {
                    smoothCount = Random.Range(1, 100);
                }
                map = Algorithms.GenerateCellularAutomata(width, height, seed, fillPercent, edgeAreWalls);
                Algorithms.SmoothVNCellularAutomata(map, edgeAreWalls, smoothCount);
                break;

            default:
                break;
        }
        Algorithms.GenerateMap(map, tilemap, tile);
    }

    // Clear the current map
    public void ClearMap(){
        Debug.Log("Clearing the map...");
        tilemap.ClearAllTiles();
    }

    public void GenerateAllRuleTiles()
    {
        Debug.Log("Generating Rule Tile");
        RuleTileGenerator.CreateAllRuleTiles();
    }
}
