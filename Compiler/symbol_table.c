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
	printf(USING_HEADER);
	printf(CLASS_DELCARATION);
	printf(CLEAR_MAP_FUN);
	printf(GENERATE_FUN);
	printf(MOVE_COORDS_FUN);
	printf(JOIN_FUN);
	printf(DFS_FUN);
	printf(MIN_FUN);
	printf(MAX_FUN);
}