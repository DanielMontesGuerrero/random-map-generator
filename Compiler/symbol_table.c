#include "symbol_table.h"

tabla_hash sym_table;
Pila *pila_codigo;

int checkTypes(int type1, int type2) {
		if(type1 == type2) return 0;
		printf("estas seguro que sabes programar?!!!\n");
		exit(1);
}

void init() {
	int i = 0;
	sym_table.MOD = 9887;
	for(i = 0; i < sym_table.MOD; i++) {
		sym_table.table[i] = NULL;
	}
	pila_codigo = NULL;
}

int get_hash(char const *name) {
	int i = 0;
	int ret = 0;
	int pot = 1;
	int prime = 31;
	for(i = 0; i < strlen(name); i++) {
		ret += (name[i]*pot)%sym_table.MOD;
		if(ret > sym_table.MOD)
			ret -= sym_table.MOD;
		pot = (pot * prime) % sym_table.MOD;
	}
	return ret % sym_table.MOD;
}

void putsym(char const *name, int sym_type) {
	int hash_val = get_hash(name);
	symrec *new_one = (symrec *) malloc (sizeof (symrec));
	strcpy(new_one -> name, name);
	new_one -> type = sym_type;
	sym_table.table[hash_val] = new_one;
}

symrec *getsym(char const *name) {
	int hash_val = get_hash(name);
	return sym_table.table[hash_val];
}

char *pop(Pila **p) {
	if((*p) == NULL) {
		printf("Error, la pila esta vacia\n");
		exit(1);
	}
	Pila* aux = (*p);
	char *code = (char*)malloc(sizeof(char)*(strlen((*p) -> code) + 4));
	strcpy(code, (*p) -> code);
	(*p) = (*p) -> next;
	free(aux);
	return code;
}

void push(Pila **p, char* code) {
	Pila *aux = (Pila*)malloc(sizeof(Pila));
	aux -> next = (*p);
	aux -> code = (char*)malloc(sizeof(char)*(strlen(code) + 4));
	strcpy(aux -> code, code);
	(*p) = aux;
}

void put_attribute(Section* section, symrec* attribute, symrec* constant) {
	if(strcmp(attribute -> name, "interval") == 0){
		checkTypes(_INT_, constant -> type);
		section -> _ints[0] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "minSectionWidth") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[1] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "requiredFloorPercent") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[2] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "minPathWidth") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[3] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "roughness") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[4] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "curvyness") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[5] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "height") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[6] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "fillPercent") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[7] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "smoothCount") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[8] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "x") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[9] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "y") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[10] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "edgeAreWalls") == 0) {
		checkTypes(_BOOL_, constant -> type);
		section -> _ints[11] = constant -> value._bool;
	}
	else if(strcmp(attribute -> name, "maxPathWidth") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[12] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "maxPathChange") == 0) {
		checkTypes(_INT_, constant -> type);
		section -> _ints[13] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "seed") == 0) {
		checkTypes(_DOUBLE_, constant -> type);
		section -> _floats[0] = constant -> value._double;
	}
	else if(strcmp(attribute -> name, "modifier") == 0) {
		checkTypes(_DOUBLE_, constant -> type);
		section -> _floats[1] = constant -> value._int;
	}
	else if(strcmp(attribute -> name, "filler") == 0) {
		checkTypes(_STRING_, constant -> type);
		symrec *aux = getsym(constant -> value._string);
		if(aux == NULL) {
			printf("seguro?\n");
			exit(1);
		}
		section -> filler = aux -> value.smart_tile;
	}
	else {
		printf("It's called anime and is art\n");
		exit(1);
	}
}

void print_template() {
	printf("using System.Collections.Generic;using UnityEngine;using UnityEditor;using UnityEngine.Tilemaps;public class MapGenerator : MonoBehaviour {  private Dictionary<string, Template> templates {    get;    set;  } private List<Section> sections {    get;    set;  }[Header(\"Reference here your Tilemap\")]public Tilemap tilemap;  public int width {    get;    set;  } public int height {    get;    set;  }  bool[] visited;  public void ClearMap() {    tilemap.ClearAllTiles();  } public void Generate() {     visited = new bool[sections.Count];    List<ConectedComponent> components = new List<ConectedComponent>();    for (int i = 0; i < sections.Count; i++) {      visited[i] = false;    }    for (int i = 0; i < sections.Count; i++) {      if(!visited[i]) {        sections[i].x = 0;        sections[i].y = 0;        ConectedComponent current = new ConectedComponent {origin = new int[2] {0, 0},corner = new int[2] {width - 1, height - 1},elements = new List<int>()};        Dfs(i, current);        components.Add(current);      }    }    int[] origin = new int[] {0, 0};    for (int i = 0; i < components.Count; i++) {      MoveCoords(components[i], origin);      origin[0] = components[i].corner[0];    }    int mapWidth = origin[0] + width;    int mapHeight = origin[1] + height;    for (int k = 0; k < sections.Count; k++) {  if(sections[k] == null) { continue; }    TileBase tile = Resources.Load<TileBase>(RuleTileGenerator.RULE_TILES_PATH + sections[k].filler) as TileBase;      if(tile == null) {        Debug.Log(\"Resource tile load failed\");      }      for (int i = 0; i < width; i++) {        for (int j = 0; j < height; j++) {          int x = sections[k].x + i;          int y = sections[k].y + j;          if(sections[k].map[i, j] == 1) {            tilemap.SetTile(new Vector3Int(x, y, 0), tile);          }        }      }    }  } private void MoveCoords(ConectedComponent component, int[] origin) {    int Cx = component.origin[0] - origin[0];    int Cy = component.origin[1] - origin[1];    for (int i = 0; i < component.elements.Count; i++) {      int idx = component.elements[i];      sections[idx].x = sections[idx].x - Cx;      sections[idx].y = sections[idx].y - Cy;    }    component.origin[0] = component.origin[0] - Cx;    component.origin[1] = component.origin[1] - Cy;    component.corner[0] = component.corner[0] - Cx;    component.corner[1] = component.corner[1] - Cy;  }"); 
	printf("private void Join(ConectedComponent component, Section origin, Section destiny, int direction) {    if (direction == 0) {      destiny.x = origin.x - width;      destiny.y = origin.y;    }    else if (direction == 1) {      destiny.x = origin.x;      destiny.y = origin.y + height;    }    else if (direction == 2) {      destiny.x = origin.x + width;      destiny.y = origin.y;    }    else {      destiny.x = origin.x;      destiny.y = origin.y - height;    }    component.origin[0] = Min(origin.x, destiny.x);    component.origin[1] = Min(origin.y, destiny.y);    component.corner[0] = Max(origin.x, destiny.x) + width;    component.corner[1] = Max(origin.y, destiny.y) + height;  } private void Dfs(int node, ConectedComponent current) {    visited[node] = true;    current.elements.Add(node);    for (int i = 0; i < 4; i++) {      int nextNode = sections[node].neighbors[i];      if (nextNode == -1) {        continue;      }      if (!visited[nextNode]) {        Join(current, sections[node], sections[nextNode], i);        Dfs(nextNode, current);      }    }  } private int Min(int a, int b) {    if(a < b) return a;    return b;  } private int Max(int a, int b) {    if(a > b) return a;    return b;  }"); 
}