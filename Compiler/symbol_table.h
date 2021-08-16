#ifndef __SYMBOL_TABLE__
#define __SYMBOL_TABLE__

#include <stdlib.h>
#include <string.h> 
#include <math.h>

#define MAXN 9887

typedef struct tile {
	char *id;
	char *name;
	char *tileset;
	int rule[3][3];
	int flag;
}Tile;

typedef struct tilelist {
	Tile *data;	
	struct tilelist *next;
}TileList;

typedef struct smarttile {
	int count;
	TileList *tiles;
}Smarttile;

typedef struct section {
	char *algorithm;
	float _floats[2]; /* seed -> _floats[0], modifier[1] */
	/* interval -> ints[0], 
	 * minSectionWidth -> ints[1], 
	 * required_floor -> ints[2], 
	 * minpathwidth -> ints[3], 
	 * roughness -> ints[4],
	 * curviness -> ints[5],
	 * height -> ints[6],
	 * fillpercent -> ints[7],
	 * smooth_count -> ints[8],
	 * x -> ints[9],
	 * y -> ints[10],
	 * edge -> ints[11],
	 * maxpathwidth -> ints[12]
	 * */
	int _ints[13]; 
	Smarttile *filler;
}Section;

typedef struct symrec {
	char name[256]; 
	int type;  
	union{
		int _int;
		double _double;
		char _char;
		char* _string;
		int _bool;
		long long int _long;
		float _float;
		int _vector[3];
		Section *algo;
		Tile *tile;
		Smarttile *smart_tile;
		char **array;
	} value;
}symrec;

typedef struct tabla_hash {
	symrec *table[MAXN];
	int MOD;
}tabla_hash;

typedef struct pila{
	char *code;
	struct pila *next;
}Pila;

extern tabla_hash sym_table;
extern Pila *pila_codigo;
void push(Pila** p, char* code);
char* pop(Pila** p);

void putsym (char const *name, int sym_type);
symrec* getsym (char const *name);

void print_template();
#endif
