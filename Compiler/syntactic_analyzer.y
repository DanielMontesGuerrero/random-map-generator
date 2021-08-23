%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "symbol_table.h"
	#include "definitions.h"
	#include "templates.h"

	void yyerror(const char* message){
		printf("%s\n", message);
		exit(1);
	}

 %}

%define api.value.type union
%token <symrec*> IDENTIFIER 
%token <symrec*> INT FLOAT DOUBLE LONG BOOL CHAR STRING
%token <symrec*> CONST_CHAR CONST_BOOL CONST_LONG
%token <symrec*> CONST_INT CONST_FLOAT CONST_DOUBLE CONST_STRING
%nterm <symrec*> variable_declaration variable type expression condition constant vector rule tile
%nterm <int> logical_operator comparation_operator
%nterm <TileList*> tiles_list
%nterm <Tile*> tile_content
%nterm <symrec*> smarttile join
%nterm <Section*> section_declaration

%token FUNCTION
%token MAIN
%token <char*> ALGORITHM 
%token PLUSPLUS MINUSMINUS
%token FOR WHILE IF ELSE
%token <symrec*> RULE SECTIONS J_SECTIONS
%token <int> SMARTTILE
%token SET TILE SECTION
%token _BEGIN END NEW JOIN CONTAINER
%token NAME TILESET DEFAULT
%token <int> GREATER_EQ LESS_EQ AND_OP OR_OP NEQ GREATER LESS EQ

%precedence '='
%left '-' '+'
%left '*' '/'
%precedence NEG

%%
// declaracion inicial main
input
	: set_size initial_declaration main_function {
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code3) + strlen(code2) + strlen(code1) + 500));
		print_template();
		printf("%s", code1);
		printf(CREATE_RULES_AND_TEMPLATES_FUN, code2);
		printf("%s}", code3);
	}
	;
set_size
	: SET '=' '{' CONST_INT ',' CONST_INT '}' ';' {
		char code[500];
		sprintf(code, GENERATE_ALL_FUN, $4 -> value._int, $6 -> value._int);
		push(&pila_codigo, code);
	}
	;
initial_declaration
	: initial_declaration section {
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 10));
		sprintf(code,"%s%s", code1, code2);
		push(&pila_codigo, code);
	}
	| initial_declaration smarttile {
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 10));
		sprintf(code,"%s%s", code1, code2);
		push(&pila_codigo, code);
	}
	| smarttile	{ } 
	| section { }
	;
smarttile
	: SMARTTILE IDENTIFIER '{' tiles_list '}' {
		symrec* aux = getsym($2->name);
		if(aux != NULL) {
			printf("No te chifles, mae. La ingenieria no es para los chiflados\n");
			printf("%s\n", $2 -> name);
			exit(1);
		}
		$$ = (symrec*)malloc(sizeof(symrec)); 
		putsym($2 -> name, $1);
		$$ = getsym($2 -> name);
		$$ -> type = SMARTTILE;
		$$ -> value.smart_tile = (Smarttile*)malloc(sizeof(Smarttile));
		$$ -> value.smart_tile -> tiles = $4;
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 100 + 3*strlen($2 -> name)));
		sprintf(
			code, 
			RULET_TILE_DECLARATION, 
			$2 -> name, 
			code1, 
			$2 -> name,
			$2 -> name
		);
		push(&pila_codigo, code);
	}
	;
tiles_list
	: tile tiles_list {
		$$ = (TileList*) malloc(sizeof(TileList));
		$$ -> data = $1 -> value.tile;
		$$ -> next = $2;
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char* code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen(code2)+20));
		sprintf(code,"%s, %s", code1, code2);
		push(&pila_codigo, code);
	}
	| tile { 
		$$ = (TileList*) malloc(sizeof(TileList));
		$$ -> data = $1 -> value.tile;
		$$ -> next = NULL;
		char* code1 = pop(&pila_codigo);
		char* code = (char*)malloc(sizeof(char)*(strlen(code1)+20));
		sprintf(code, "%s", code1);
		push(&pila_codigo, code);
	}
	;

tile
	: TILE IDENTIFIER '{' tile_content rule '}'	{
		int isMultipleSprite = strlen($4 -> tileset);
		if(getsym($2 -> name) != NULL) {
			printf("60 anios, una protesis\n");
			exit(1);
		}
		putsym($2 -> name, _TILE_);
		symrec *aux = getsym($2 -> name);
		aux -> value.tile = $4;
		
		if($5 != NULL) {
			for(int i = 0; i < 3; i++) {
				for(int j = 0; j < 3; j++) {
					aux -> value.tile -> rule[i][j] = $5 -> value.tile -> rule[i][j];
				}
			}
		}
		aux -> value.tile -> id = (char*)malloc(sizeof(char)*strlen($2 -> name));
		strcpy(aux -> value.tile -> id, $2 -> name);
		$$ = aux;
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen(code2) + 100));
		if($5 != NULL) {
			sprintf(
				code,
				RULE_DECLARATION_V1,
				code1,
				code2
				);
		}
		else {
			sprintf(
				code,
				RULE_DECLARATION_v2,
				code1
				);
		}
		push(&pila_codigo, code);
	}
	;

section
	: SECTION IDENTIFIER ':' ALGORITHM '{' section_declaration '}' {
		if(getsym($2 -> name) != NULL) {
			printf("Mis gustos son God y los tuyos zzzz\n");
			exit(1);
		}
		putsym($2 -> name, _SECTION_);
		symrec* aux = getsym($2 -> name);
		aux -> type = _SECTION_;
		aux -> value.algo = $6;
		aux -> value.algo -> algorithm = (char*)malloc(sizeof(char)*(strlen($4)));
		strcpy(aux -> value.algo -> algorithm, $4);

		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen($4)+strlen($2 -> name)+100));
		sprintf(code, TEMPLATE_DECLARATION, $2 -> name,code1, $4);
		push(&pila_codigo, code);
	}
	;

section_declaration
	:  section_declaration IDENTIFIER '=' constant ';' { 
		$$ = $1;
		put_attribute($$,$2,$4);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = malloc(sizeof(char)*(strlen($2 -> name) + strlen(code2) + 100 + strlen(code1)));
		sprintf(code, "%s %s = %s,", code1, $2 -> name, code2);
		push(&pila_codigo, code);
	}
	| IDENTIFIER '=' constant ';' {
		$$ = (Section*)malloc(sizeof(Section));
		char *code1 = pop(&pila_codigo);
		char *code = malloc(sizeof(char)*(strlen($1 -> name) + strlen(code1) + 100));
		sprintf(code, "%s = %s,", $1 -> name, code1);
		push(&pila_codigo, code);
	}
	;
tile_content
	: NAME '=' CONST_STRING ';' TILESET '=' CONST_STRING ';' DEFAULT '=' CONST_BOOL ';' {
		$$ = (Tile*)malloc(sizeof(Tile));
		$$ -> name = (char*) malloc(sizeof(char)*strlen($3 -> value._string));
		strcpy($$ -> name, $3 -> value._string);
		$$ -> tileset = (char*) malloc(sizeof(char)*strlen($7 -> value._string));
		strcpy($$ -> tileset, $7 -> value._string);
		$$ -> flag = $11 -> value._bool;			

		char *code = (char*)malloc(sizeof(char)*(strlen($$ -> name) + strlen($$ -> tileset) + 1000));
		sprintf(code,
				TILE_CONTENT_DECLARATION,
				$$ -> name,
				$$ -> tileset,
				($$ -> flag? "true" : "false"),
				(strlen($$->tileset)? "true":"false")
			);
		push(&pila_codigo, code);
	}
	;

main_function
	: MAIN  code_block {
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 100));
		sprintf(code, CREATE_MAP_FUN,code1);
		push(&pila_codigo, code);
	}
	;
code_block
	: '{' statement_list '}' { }
	| '{' '}' { }
	| error { yyerrok; }
	;
rule
	: RULE '=' '{' vector ',' vector ',' vector '}' {
		$$ = (symrec*)malloc(sizeof(symrec));	
		$$ -> value.tile = (Tile*)malloc(sizeof(Tile));
		for(int i = 0; i < 3; i++)
			$$ -> value.tile -> rule[0][i]= $4 -> value._vector[i];
		for(int i = 0; i < 3; i++)
			$$ -> value.tile -> rule[1][i]= $6 -> value._vector[i];
		for(int i = 0; i < 3; i++)
			$$ -> value.tile -> rule[2][i]= $8 -> value._vector[i];
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + strlen(code3) + 10));
		sprintf(code, "{%s,%s,%s}", code1, code2, code3);
		push(&pila_codigo, code);
	}
	;
vector
	: '{' expression ',' expression ',' expression '}' {
		checkTypes($2 -> type, $4 -> type);
		checkTypes($4 -> type, $6 -> type);
		if($2 -> type != _INT_)  {
			printf("Hoy es noche de FREE FIRE!!!\n");
		}
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> value._vector[0] = $2 -> value._int;
		$$ -> value._vector[1] = $4 -> value._int; 
		$$ -> value._vector[2] = $6 -> value._int;
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + strlen(code3) + 10));
		sprintf(code, "{%s,%s,%s}", code1, code2, code3);
		push(&pila_codigo, code);
	}
	;
statement_list 
	: statement_list statement {
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2)+5));
		sprintf(code, "%s%s", code1, code2);
		push(&pila_codigo, code);
	}
	| statement { }
statement
	: variable_declaration ';'  {
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 10));
		sprintf(code, "%s", code1);
		push(&pila_codigo, code);
	}
	| for   { }
	| while { }
	| if	{ }
	| join ';' { }
	| expression ';' {	
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 10));
		sprintf(code, "%s;", code1);
		push(&pila_codigo, code);
	}
	;
join 
	: JOIN '(' expression ',' CONST_CHAR ',' expression ')' {
		if($3 -> type != _INT_ || $7 -> type != _INT_) {
			printf("Error en acceso a las secciones\n");
			exit(1);
		}
		symrec *aux = getsym("sections");
		if(aux == NULL) {
			printf("No has declarado sections!\n");
			exit(1);
		}
		int direccion;
		switch($5 -> value._char) {
			case 'l': direccion = 0; break;
			case 'u': direccion = 1; break;
			case 'r': direccion = 2; break;
			case 'd': direccion = 3; break;
			default:
				printf("No te chifles\n");
				exit(1);
		}
		$$ -> type = _SECTION_;
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 100));
		sprintf(code, 
			JOIN_SECTIONS_DECLARATION,
			code1,
			direccion,
			code2,
			code2,
			(direccion+2)%4,
			code1
		);
		push(&pila_codigo, code);
	}
	;

variable_declaration
	: type variable '=' expression {
		if(getsym($2 -> name) != NULL) {
			printf("Redeclaracion de variable!!!\n");
			exit(1);
		}
		checkTypes($1 -> type, $4 -> type);
		$$ -> type = $1 -> type;
		$2 -> type = $1 -> type;
		putsym($2 -> name, $1 -> type);
		symrec* aux = getsym($2 -> name);

		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen(code2)+strlen(code3)) + 10);
		sprintf(code, "%s %s = %s;", code1, code2, code3);
		push(&pila_codigo, code);	
	}
	| type variable '=' variable { 
		symrec *aux;
		if((aux = getsym($4 -> name)) == NULL) {
			printf("La variable no ha sido declarada!!!\n");
			exit(1);
		}
		if(getsym($2 -> name) != NULL) {
			printf("La variable se redeclaro\n");
			exit(1);
		}
		checkTypes($1 -> type, aux -> type);
		$$ -> type = aux -> type;
		putsym($2 -> name, aux -> type);
		
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen(code2)+strlen(code3)) + 10);
		sprintf(code, "%s %s = %s;", code1, code2, code3);
		push(&pila_codigo, code);	
	}
	| type variable { 
		if(getsym($2 -> name) != NULL) {
			printf("La variable se redeclaro\n");
			exit(1);
		}
		$$ -> type = $1 -> type;
		putsym($2 -> name, $1 -> type);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 10));
		sprintf(code, "%s,%s;",code1, code2);
		push(&pila_codigo, code);	
	}
	| CONTAINER SECTIONS '[' CONST_INT ']' {
		if(getsym($2 -> name) != NULL) {
			printf("Aun no declaras el tamanio de sections\n");
			exit(1);
		}
		char** array = (char**)malloc(sizeof(char*)*$4 -> value._int);
		putsym($2 -> name, _SECTION_);
		symrec* aux = getsym($2 -> name);
		$2 -> value.array = array;
		aux -> type = _SECTION_;
		$$ = aux;
		char *code = (char*)malloc(sizeof(char)*(500));
		sprintf(
			code,
			SECTION_CONTAINER_DECLARATION,
			$4 -> value._int
		);
		push(&pila_codigo, code);	
	}
	;
variable
	: IDENTIFIER {
		strcpy($$ -> name, $1 -> name); 
		char *code = (char*)malloc(sizeof($1 -> name));
		strcpy(code, $1 -> name);
		push(&pila_codigo, code);
	}
	;
while
	: WHILE '(' condition ')' code_block {
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code2) + strlen(code1) + 50));
		sprintf(code, "while(%s){%s}", code1, code2);
		push(&pila_codigo, code);
	}
	;
for 
	: FOR '(' variable_declaration ';' condition ';' expression ')' code_block {
		char *code4 = pop(&pila_codigo);
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen(code2)+strlen(code3)+strlen(code4) + 100));
		sprintf(code, "for(%s %s;%s){%s}", code1, code2, code3, code4);
		push(&pila_codigo, code);
	}
	;
if
	: IF '(' condition ')' code_block { 
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen(code2) + 50));
		sprintf(code, "if(%s){%s}", code1, code2);
		push(&pila_codigo, code);
	}
	| IF '(' condition ')' code_block ELSE code_block {  
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+strlen(code2)+strlen(code3) + 50));
		sprintf(code, "if(%s){%s}else{%s}", code1, code2, code3);
		push(&pila_codigo, code);
	}
	;
expression
	: constant { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = $1 -> type; 			
	}
	| expression '+' expression { 
		$$ = (symrec*)malloc(sizeof(symrec));
		checkTypes($1 -> type, $3 -> type);
		$$ -> type = $1 -> type;
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 4));
		sprintf(code, "%s+%s", code1, code2);
		push(&pila_codigo, code);
		
	}
	| expression '-' expression { 
		$$ = (symrec*)malloc(sizeof(symrec));
		checkTypes($1-> type, $3 -> type);
		$$ -> type = $1 -> type;

		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 4));
		sprintf(code, "%s-%s", code1, code2);
		push(&pila_codigo, code);
    }
	| expression '*' expression { 
		$$ = (symrec*)malloc(sizeof(symrec));
		checkTypes($1-> type, $3 -> type);
		$$ -> type = $1 -> type;

		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 4));
		sprintf(code, "%s*%s", code1, code2);
		push(&pila_codigo, code);

    }
	| expression '/' expression { 
		$$ = (symrec*)malloc(sizeof(symrec));
		checkTypes($1-> type, $3 -> type);
		$$ -> type = $1 -> type;
		
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 4));
		sprintf(code, "%s/%s", code1, code2);
		push(&pila_codigo, code);
	}
	| '-' expression %prec NEG { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = $2 -> type;
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 4));
		sprintf(code, "-%s", code1);
		push(&pila_codigo, code);
	}
	| '(' expression ')' { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = $2 -> type;

		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 4));
		sprintf(code, "(%s)", code1);
		push(&pila_codigo, code);
    }
	| variable PLUSPLUS { 
		$$ = (symrec*)malloc(sizeof(symrec));
		symrec* aux = getsym($1 -> name);
		if(aux == NULL) {
			printf("La variable no ha sido declarada\n");
			exit(1);
		}
		$$ -> type = aux -> type;

		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+5));
		sprintf(code, "%s++", code1);
		push(&pila_codigo, code);
	}
	| variable MINUSMINUS { 
		$$ = (symrec*)malloc(sizeof(symrec));
		symrec* aux = getsym($1 -> name);
		if(aux == NULL) {
			printf("La variable no ha sido declarada\n");
			exit(1);
		}
		$$ -> type = aux -> type;

		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1)+5));
		sprintf(code, "%s--", code1);
		push(&pila_codigo, code);
	}
	| variable { 
		$$ = (symrec*)malloc(sizeof(symrec));
		symrec* aux = getsym($1 -> name);
		if(aux == NULL) {
			printf("Se esta usando una variable no declarada\n");
			exit(1);
		}
		$$ -> type = aux -> type;
	}
	| condition { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _BOOL_;
		$$ -> value._bool = $1 -> value._bool;

							}
	| variable '=' expression { 
		symrec* aux = getsym($1 -> name);
		$$ = (symrec*)malloc(sizeof(symrec));
		if(aux == NULL) {
			printf("La variable no ha sido declarada\n");
			exit(1);
		}
		checkTypes(aux -> type, $3 -> type);
		$$ -> type = $3 -> type;
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 50));
		sprintf(code, "%s=%s", code1, code2);
		push(&pila_codigo, code);
	}
	| SECTIONS '[' expression ']' '=' variable {
		if($3 -> type != _INT_) {
			printf("Error en acceso a las secciones\n");
			exit(1);
		}
		symrec* aux = getsym($6 -> name);
		if(aux == NULL){ 
			printf("La variable no ha sido declarada\n");
			exit(1);
		}
		checkTypes(_SECTION_, aux -> type);
		$$ -> type = _SECTION_;
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + 50));
		sprintf(code, SECTION_INIT_DECLARATION, code1, code2);
		push(&pila_codigo, code);
	}
	;
condition
	: condition logical_operator condition { 
		$$ = (symrec*)malloc(sizeof(symrec));
		checkTypes($1 -> type, $3 -> type);
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + strlen(code3) + 10));
		sprintf(code,"%s%s%s", code1, code2, code3);
		push(&pila_codigo, code);
	}
	| expression  comparation_operator  expression { 
		$$ = (symrec*)malloc(sizeof(symrec));
		checkTypes($1 -> type, $3 -> type);
		$$ -> type = _BOOL_;
		char *code3 = pop(&pila_codigo);
		char *code2 = pop(&pila_codigo);
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + strlen(code2) + strlen(code3) + 10));
		sprintf(code, "%s%s%s", code1, code2, code3);
		push(&pila_codigo, code);
    }
	| CONST_BOOL { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _BOOL_;
		$$ -> value._bool = $1 -> value._bool;
		char code[10];
		if($$ -> value._bool) {
			strcpy(code, "true");
		}
		else{
			strcpy(code, "false");
		}
		push(&pila_codigo, code);
    }
	| '!' condition { 
		$$ = (symrec*)malloc(sizeof(symrec));
        	if($2 -> type != _BOOL_) {
        		printf("No coinciden los tipos de dato\n");
        		exit(1);
          	}
		$$ -> type = CONST_BOOL;
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 10));
		sprintf(code, "!%s", code1);
		push(&pila_codigo, code);
    }
	| '!' variable {
		symrec *aux = getsym($2 -> name);
		if(aux == NULL || aux -> type != _BOOL_) {
			printf("No nos interesa tu rollo, nomas que funcione\n");
			exit(1);
		}
		$$ -> value._bool = !(aux -> value._bool);
		$$ -> type = _BOOL_;
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 10));
		sprintf(code, "!%s", code1);
		push(&pila_codigo, code);
	}
	| '(' condition ')' { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = $2 -> type;
		char *code1 = pop(&pila_codigo);
		char *code = (char*)malloc(sizeof(char)*(strlen(code1) + 10));
		sprintf(code, "(%s)", code1);
		push(&pila_codigo, code);
    }
	;

logical_operator
	: AND_OP { 
		$$ = $1; 
		char code[4] = "&&";
		push(&pila_codigo,  code);
	}
	| OR_OP { 
		$$ = $1; 
		char code[4] = "||";
		push(&pila_codigo, code);
	}
	;
comparation_operator
	: GREATER_EQ { 
		$$ = $1; 	
		char code[4] = ">=";
		push(&pila_codigo, code);
	}
	| GREATER { 
		$$ = $1;
		char code[4] = ">";
		push(&pila_codigo, code);
	}
	| LESS_EQ { 
		$$ = $1; 
		char code[4] = "<=";
		push(&pila_codigo, code);
	}
	| LESS { 
		$$ = $1; 	
		char code[4] = "<";
		push(&pila_codigo, code);
	}
	| NEQ { 
		$$ = $1; 	
		char code[4] = "<";
		push(&pila_codigo, code);
	}
	| EQ { 
		$$ = $1; 
		char code[4] = "==";
		push(&pila_codigo, code);
	}
	;
constant
	: CONST_INT { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> value._int = $1 -> value._int; 
		$$ -> type = _INT_; 
		char code[25];
		sprintf(code, "%d", $$ -> value._int);
		push(&pila_codigo, code);
	}
	| CONST_FLOAT { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> value._float = $1 -> value._float; 
		$$ -> type = _FLOAT_; 
		char code[25];
		sprintf(code, "%fF", $$ -> value._float);
		push(&pila_codigo, code);
	}
	| CONST_DOUBLE { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> value._double = $1 -> value._double; 
		$$ -> type = _DOUBLE_; 
		char code[25];
		sprintf(code, "%fF", $$ -> value._double);
		push(&pila_codigo, code);
	}
	| CONST_CHAR { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> value._char = $1 -> value._char; 
		$$ -> type = _CHAR_;  
		char code[10];
		sprintf(code, "'%c'", $$ -> value._char);
		push(&pila_codigo, code);
	}
	| CONST_BOOL { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> value._bool = $1 -> value._bool; 
		$$ -> type = _BOOL_; 
		char code[10];
		sprintf(code, "%s", ($$ -> value._bool? "true" : "false"));
		push(&pila_codigo, code);
	}
	| CONST_STRING {
		$$ = (symrec*)malloc(sizeof(symrec));	
		int len = strlen($1 -> value._string);
		$$ -> value._string = (char*)malloc(sizeof(char)*len);
		strcpy($$ -> value._string, $1 -> value._string);
		$$ -> type = _STRING_;
		char* code = (char*)malloc(sizeof(char)*(strlen($1 -> value._string) + 4));
		sprintf(code, "\"%s\"", $1 -> value._string);
		push(&pila_codigo, code);
	}
	;
type
	: INT { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _INT_; 
		char code[7];
		sprintf(code, "int");
		push(&pila_codigo, code);
	}
	| FLOAT { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _FLOAT_; 
		char code[7];
		sprintf(code, "float");
		push(&pila_codigo, code);
	}
	| DOUBLE { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _DOUBLE_; 
		char code[7];
		sprintf(code, "double");
		push(&pila_codigo, code);
	}
	| LONG { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _LONG_; 
		char code[7];
		sprintf(code, "long");
		push(&pila_codigo, code);
	}
	| BOOL { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _BOOL_; 
		char code[7];
		sprintf(code, "bool");
		push(&pila_codigo, code);
	}
	| CHAR { 
		$$ = (symrec*)malloc(sizeof(symrec));
		$$ -> type = _CHAR_; 
		char code[7];
		sprintf(code, "char");
		push(&pila_codigo, code);
	}
	| STRING {
		$$  = (symrec*) malloc(sizeof(symrec));
		$$ -> type = _STRING_; 
		char code[7];
		sprintf(code, "string");
		push(&pila_codigo, code);
	}
	;

%%

int main(int argc, char** argv) {
	init();
	yyparse();
	return 0;
}