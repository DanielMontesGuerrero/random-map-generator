#ifndef __TEMPLATES__
#define __TEMPLATES__

#define USING_HEADER "using System.Collections.Generic;" \
                     "using UnityEngine;" \
                     "using UnityEditor;" \
                     "using UnityEngine.Tilemaps;"

#define CLASS_DELCARATION   "public class MapGenerator : MonoBehaviour {" \
                                "private Dictionary<string, Template> templates {    get;    set;  }" \
                                "private List<Section> sections {    get;    set;  }" \
                                "[Header(\"Reference here your Tilemap\")]" \
                                "public Tilemap tilemap;" \
                                "public int width {    get;    set;  }" \
                                "public int height {    get;    set;  }" \
                                "bool[] visited;"

#define CLEAR_MAP_FUN "public void ClearMap() {" \
                        "tilemap.ClearAllTiles();" \
                      "}" \

#define GENERATE_FUN    "public void Generate() {" \
                            "visited = new bool[sections.Count];" \
                            "List<ConectedComponent> components = new List<ConectedComponent>();" \
                            "for (int i = 0; i < sections.Count; i++) {" \
                                "visited[i] = false;" \
                            "}" \
                            "for (int i = 0; i < sections.Count; i++) {" \
                                "if(!visited[i]) { " \
                                    "sections[i].x = 0;" \
                                    "sections[i].y = 0;" \
                                    "ConectedComponent current = new ConectedComponent {" \
                                        "origin = new int[2] {0, 0}," \
                                        " corner = new int[2] {width - 1, height - 1}," \
                                        "elements = new List<int>()" \
                                    "};" \
                                    "Dfs(i, current);" \
                                    "components.Add(current);" \
                                "}" \
                            "}" \
                            "int[] origin = new int[] {0, 0};" \
                            "for (int i = 0; i < components.Count; i++) {" \
                                "MoveCoords(components[i], origin);" \
                                "origin[0] = components[i].corner[0];" \
                            "}" \
                            "int mapWidth = origin[0] + width;" \
                            "int mapHeight = origin[1] + height;" \
                            "for (int k = 0; k < sections.Count; k++) {" \
                                "if(sections[k] == null) { continue; }" \
                                "TileBase tile = Resources.Load<TileBase>(RuleTileGenerator.RULE_TILES_PATH + sections[k].filler) as TileBase;" \
                                "if(tile == null) { Debug.Log(\"Resource tile load failed\"); }" \
                                "for (int i = 0; i < width; i++) {" \
                                    "for (int j = 0; j < height; j++) {" \
                                        "int x = sections[k].x + i;" \
                                        "int y = sections[k].y + j;" \
                                        "if(sections[k].map[i, j] == 1) {" \
                                            "tilemap.SetTile(new Vector3Int(x, y, 0), tile);" \
                                        "}" \
                                    "}" \
                                "}" \
                            "}" \
                        "}"

#define MOVE_COORDS_FUN "private void MoveCoords(ConectedComponent component, int[] origin) {" \
                            "int Cx = component.origin[0] - origin[0];" \
                            "int Cy = component.origin[1] - origin[1];" \
                            "for (int i = 0; i < component.elements.Count; i++) {" \
                                "int idx = component.elements[i];" \
                                "sections[idx].x = sections[idx].x - Cx;" \
                                "sections[idx].y = sections[idx].y - Cy;" \
                            "}" \
                            "component.origin[0] = component.origin[0] - Cx;" \
                            "component.origin[1] = component.origin[1] - Cy;" \
                            "component.corner[0] = component.corner[0] - Cx;" \
                            "component.corner[1] = component.corner[1] - Cy;" \
                        "}"

#define JOIN_FUN    "private void Join(ConectedComponent component, Section origin, Section destiny, int direction) {" \
                        "if (direction == 0) {" \
                            "destiny.x = origin.x - width;" \
                            "destiny.y = origin.y;" \
                        "}" \
                        "else if (direction == 1) { " \
                            "destiny.x = origin.x;" \
                            "destiny.y = origin.y + height;" \
                        "}" \
                        "else if (direction == 2) {" \
                            "destiny.x = origin.x + width;" \
                            "destiny.y = origin.y;" \
                        "}" \
                        "else { " \
                            "destiny.x = origin.x;" \
                            "destiny.y = origin.y - height;" \
                        "}" \
                        "component.origin[0] = Min(origin.x, destiny.x);" \
                        "component.origin[1] = Min(origin.y, destiny.y);" \
                        "component.corner[0] = Max(origin.x, destiny.x) + width;" \
                        "component.corner[1] = Max(origin.y, destiny.y) + height;" \
                    "}"

#define DFS_FUN "private void Dfs(int node, ConectedComponent current) {" \
                    "visited[node] = true;" \
                    "current.elements.Add(node);" \
                    "for (int i = 0; i < 4; i++) {" \
                        "int nextNode = sections[node].neighbors[i];" \
                        "if (nextNode == -1) { continue; }" \
                        "if (!visited[nextNode]) {" \
                            "Join(current, sections[node], sections[nextNode], i);" \
                            "Dfs(nextNode, current);" \
                        "}" \
                    "}" \
                "}" 

#define MIN_FUN "private int Min(int a, int b) { if (a < b) return a; return b; }"

#define MAX_FUN "private int Max(int a, int b) { if (a > b) return a; return b; }"

#define CREATE_RULES_AND_TEMPLATES_FUN "public void CreateRulesAndTemplates(){%s}"

#define GENERATE_ALL_FUN    "public void GenerateAll() {" \
                                "ClearMap();" \
                                "width = %d;" \
                                "height = %d;" \
                                "sections = new List<Section>();" \
                                "templates = new Dictionary<string, Template>();" \
                                "CreateRulesAndTemplates();" \
                                "CreateMap();" \
                                "Generate();" \
                            "}"

#define RULET_TILE_DECLARATION  "List<Rule> %s = new List<Rule>(){%s};" \
                                "RuleTileGenerator.CreateRuleTile(\"%s\",%s);"

#define RULE_DECLARATION_V1 "new Rule{%s matrixOfNeighbors=new int[,] %s}"

#define RULE_DECLARATION_v2 "new Rule{%s matrixOfNeighbors=new int[,] {}"

#define TEMPLATE_DECLARATION "templates[\"%s\"] = new Template {%s algorithm = \"%s\"};"

#define TILE_CONTENT_DECLARATION "spritePath=\"%s\", spriteMultiplePath=\"%s\",isDefault=%s,isMultipleSprite=%s,"

#define CREATE_MAP_FUN "public void CreateMap(){%s}"

#define JOIN_SECTIONS_DECLARATION "sections[%s].neighbors[%d]=sections[%s].id;sections[%s].neighbors[%d]=sections[%s].id;"

#define SECTION_CONTAINER_DECLARATION   "sections = new List<Section> ();" \
                                        " for(int iterador = 0; iterador < %d; iterador++) {" \
                                            "sections.Add(new Section {" \
                                                "width = width," \
                                                "height = height," \
                                                "id = iterador," \
                                                "neighbors = new int[4]{-1,-1,-1,-1}," \
                                                "map = new int[width, height]" \
                                            "});" \
                                        "}"

#define SECTION_INIT_DECLARATION "sections[%s].Init(templates[\"%s\"])"

#endif