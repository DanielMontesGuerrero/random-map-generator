










































































































using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Tilemaps;
public class MapGenerator : MonoBehaviour {
    private Dictionary<string, Template> templates {
        get;
        set;
    } private List<Section> sections {
        get;
        set;
    }[Header("Reference here your Tilemap")]public Tilemap tilemap;
    public int width {
        get;
        set;
    } public int height {
        get;
        set;
    } bool[] visited;
    public void ClearMap() {
        tilemap.ClearAllTiles();
    } public void Generate() {
        visited = new bool[sections.Count];
        List<ConectedComponent> components = new List<ConectedComponent>();
        for (int i = 0; i < sections.Count; i++) {
            visited[i] = false;
        }
        for (int i = 0; i < sections.Count; i++) {
            if(!visited[i]) {
                sections[i].x = 0;
                sections[i].y = 0;
                ConectedComponent current = new ConectedComponent {origin = new int[2] {0, 0}, corner = new int[2] {width - 1, height - 1},elements = new List<int>()};
                Dfs(i, current);
                components.Add(current);
            }
        }
        int[] origin = new int[] {0, 0};
        for (int i = 0; i < components.Count; i++) {
            MoveCoords(components[i], origin);
            origin[0] = components[i].corner[0];
        }
        int mapWidth = origin[0] + width;
        int mapHeight = origin[1] + height;
        for (int k = 0; k < sections.Count; k++) {
            if(sections[k] == null) {
                continue;
            }
            TileBase tile = Resources.Load<TileBase>(RuleTileGenerator.RULE_TILES_PATH + sections[k].filler) as TileBase;
            if(tile == null) {
                Debug.Log("Resource tile load failed");
            }
            for (int i = 0; i < width; i++) {
                for (int j = 0; j < height; j++) {
                    int x = sections[k].x + i;
                    int y = sections[k].y + j;
                    if(sections[k].map[i, j] == 1) {
                        tilemap.SetTile(new Vector3Int(x, y, 0), tile);
                    }
                }
            }
        }
    } private void MoveCoords(ConectedComponent component, int[] origin) {
        int Cx = component.origin[0] - origin[0];
        int Cy = component.origin[1] - origin[1];
        for (int i = 0; i < component.elements.Count; i++) {
            int idx = component.elements[i];
            sections[idx].x = sections[idx].x - Cx;
            sections[idx].y = sections[idx].y - Cy;
        }
        component.origin[0] = component.origin[0] - Cx;
        component.origin[1] = component.origin[1] - Cy;
        component.corner[0] = component.corner[0] - Cx;
        component.corner[1] = component.corner[1] - Cy;
    } private void Join(ConectedComponent component, Section origin, Section destiny, int direction) {
        if (direction == 0) {
            destiny.x = origin.x - width;
            destiny.y = origin.y;
        }
        else if (direction == 1) {
            destiny.x = origin.x;
            destiny.y = origin.y + height;
        }
        else if (direction == 2) {
            destiny.x = origin.x + width;
            destiny.y = origin.y;
        }
        else {
            destiny.x = origin.x;
            destiny.y = origin.y - height;
        }
        component.origin[0] = Min(origin.x, destiny.x);
        component.origin[1] = Min(origin.y, destiny.y);
        component.corner[0] = Max(origin.x, destiny.x) + width;
        component.corner[1] = Max(origin.y, destiny.y) + height;
    } private void Dfs(int node, ConectedComponent current) {
        visited[node] = true;
        current.elements.Add(node);
        for (int i = 0; i < 4; i++) {
            int nextNode = sections[node].neighbors[i];
            if (nextNode == -1) {
                continue;
            }
            if (!visited[nextNode]) {
                Join(current, sections[node], sections[nextNode], i);
                Dfs(nextNode, current);
            }
        }
    } private int Min(int a, int b) {
        if (a < b) return a;
        return b;
    } private int Max(int a, int b) {
        if (a > b) return a;
        return b;
    } public void GenerateAll() {
        ClearMap();
        width = 100;
        height = 100;
        sections = new List<Section>();
        templates = new Dictionary<string, Template>();
        CreateRulesAndTemplates();
        CreateMap();
        Generate();
    } public void CreateRulesAndTemplates() {
        List<Rule> montain = new List<Rule>() {
            new Rule {spritePath="Mountain/tierra_nieve", spriteMultiplePath="",isDefault=true,isMultipleSprite=false, matrixOfNeighbors=new int[,] {{0,0,0},{0,0,0},{0,0,0}}}, new Rule {spritePath="Mountain/nieve", spriteMultiplePath="",isDefault=false,isMultipleSprite=false, matrixOfNeighbors=new int[,] {{0,-1,0},{1,0,1},{0,0,0}}}, new Rule {spritePath="Mountain/nieve_left", spriteMultiplePath="",isDefault=false,isMultipleSprite=false, matrixOfNeighbors=new int[,] {{0,-1,0},{-1,0,1},{0,0,0}}}, new Rule {spritePath="Mountain/nieve_right", spriteMultiplePath="",isDefault=false,isMultipleSprite=false, matrixOfNeighbors=new int[,] {{0,-1,0},{1,0,-1},{0,0,0}}}
        };
        RuleTileGenerator.CreateRuleTile("montain",montain);
        templates["cueva1"] = new Template {seed = 76.699096F, filler = "montain", requiredFloorPercent = 45, algorithm = "RandomWalkCave"};
        templates["cueva2"] = new Template {seed = 3569.236096F, filler = "montain", requiredFloorPercent = 45, algorithm = "RandomWalkCave"};
        templates["camino1"] = new Template {seed = 66.368077F, filler = "montain", algorithm = "RandomWalk"};
        templates["camino2"] = new Template {seed = 76.699096F, filler = "montain", algorithm = "RandomWalk"};
        templates["camino3"] = new Template {seed = 7653.090956F, filler = "montain", algorithm = "RandomWalk"};
        templates["camino4"] = new Template {seed = 67.975635F, filler = "montain", algorithm = "RandomWalk"};
        templates["completo"] = new Template {fillPercent = 100, filler = "montain", algorithm = "MooreCellularAutomata"};
    } public void CreateMap() {
        sections = new List<Section> ();
        for(int iterador = 0; iterador < 12; iterador++) {
            sections.Add(new Section {width = width,height = height,id = iterador,neighbors = new int[4]{-1,-1,-1,-1},map = new int[width, height]});
        }
        sections[1].Init(templates["camino1"]);
        sections[2].Init(templates["completo"]);
        sections[3].Init(templates["camino2"]);
        sections[4].Init(templates["completo"]);
        sections[5].Init(templates["cueva1"]);
        sections[6].Init(templates["cueva2"]);
        sections[7].Init(templates["camino3"]);
        sections[8].Init(templates["completo"]);
        sections[10].Init(templates["camino4"]);
        sections[11].Init(templates["completo"]);
        for(int i = 0; i<2; i++) {
            if(i==0) {
                sections[3+i].neighbors[3]=sections[4+i].id;
                sections[4+i].neighbors[1]=sections[3+i].id;
                sections[7+i].neighbors[3]=sections[8+i].id;
                sections[8+i].neighbors[1]=sections[7+i].id;
            }
            sections[i].neighbors[3]=sections[i+1].id;
            sections[i+1].neighbors[1]=sections[i].id;
            sections[9+i].neighbors[3]=sections[i+10].id;
            sections[i+10].neighbors[1]=sections[9+i].id;
            int j = i+1;
            sections[2*j].neighbors[2]=sections[2*j+2].id;
            sections[2*j+2].neighbors[0]=sections[2*j].id;
            sections[3*j+2].neighbors[2]=sections[3*j+5].id;
            sections[3*j+5].neighbors[0]=sections[3*j+2].id;
        }
        sections[5].neighbors[0]=sections[6].id;
        sections[6].neighbors[2]=sections[5].id;
    }
}
