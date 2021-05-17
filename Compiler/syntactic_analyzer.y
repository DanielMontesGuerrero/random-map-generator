%{
	#include <stdio.h>
	void yyerror(const char* message){
		printf("%s\n", message);
	}
%}


%token /*<symrec*>*/ IDENTIFIER FUNCTION
%token INT FLOAT DOUBLE LONG BOOL CHAR STRING
%token FOR WHILE IF
%token SET SMARTTILE TILE NAME PATH MAPWIDTH SECTION
%token _BEGIN END NEW JOIN CONTAINER
%token CONST_INT CONST_FLOAT CONST_DOUBLE CONST_STRING
%token CONST_CHAR CONST_BOOL CONST_LONG
%token GREATER_EQ LESS_EQ AND_OP OR_OP NEQ

%precedence '='
%left '-' '+'
%left '*' '/'
%precedence NEG

%%

input
	: %empty
	| code_block
	;

code_block
	: statement              { printf("statement\n"); }
	| statement code_block   { printf("statement code_block\n"); }
	| error                  { yyerrok; }
	;

statement
	: variable   { printf("variable\n"); }
	| expression { printf("exprecion\n"); }
	| FUNCTION     { printf("funcion\n"); }
	| for          { printf("for\n"); }
	| while        { printf("while\n"); }
	| if           { printf("if\n"); }
	;

variable
	: type IDENTIFIER '['CONST_INT']' '=' expression             { printf("tipo identificador[entero] = expression\n"); }
	| type IDENTIFIER '=' IDENTIFIER                             { printf("tipo idenfificador = idenfificador\n"); }
	| type IDENTIFIER '[' CONST_INT ']'                          { printf("tipo idenfificador[entero]\n"); }
	| type IDENTIFIER ';'                                           { printf("tipo idenfificador\n"); }
	| type IDENTIFIER '['CONST_INT ']' '=' '{' const_list '}'    { printf("tipo idenfificador[entero] = {lista}\n"); }
	| type IDENTIFIER '=' constant                               { printf("tipo idenfificador = constante;\n"); }
	| variable ';'
	;

while
	: WHILE '(' condition ')' '{' code_block '}'   { printf("while\n"); }
	;

for 
	: FOR '(' variable ';' condition ';' expression ')' '{' code_block '}'   { printf("for\n"); }
	;

if
	: IF '(' condition ')' '{' code_block '}'   { printf("if\n"); }

expression
	: constant                       { printf("constate: "); }
	| IDENTIFIER                     { printf("idenfificador\n"); }
	| IDENTIFIER '=' expression      { printf("idenfificador = exprecion\n"); }
	| FUNCTION  '(' expression ')'   { printf("funcion\n"); }
	| expression '+' expression      { printf("exprecion + exprecion\n"); }
	| expression '-' expression      { printf("exprecion - exprecion\n"); }
	| expression '*' expression      { printf("expression * expression\n"); }
	| expression '/' expression      { printf("expression / expression\n"); }
	| '-' expression %prec NEG       { printf("- expression\n"); }
	| '(' expression ')'             { printf("(expression)\n"); }
	| condition                      { printf("condicion\n"); }
	| expression ';'
	;

condition
	: condition logical_operator condition  { printf("condicion op condicion\n"); }
	| IDENTIFIER                            { printf("idenfificador\n"); }
	| constant                              { printf("constante: "); }
	| '!' condition                         { printf("no condicion\n"); }
	| '(' condition ')'                     { printf("(condicion)\n"); }
	;

logical_operator
	: '<'
	| '>'
	| GREATER_EQ
	| LESS_EQ
	| AND_OP
	| NEQ
	| OR_OP
	;

const_list
	: constant ',' const_list  { printf("costante, lista\n"); }
	| constant                 { printf("constante: "); }
	;

constant
	: CONST_INT     { printf("const_int\n"); }
	| CONST_FLOAT   { printf("const_float\n"); }
	| CONST_DOUBLE  { printf("const_double\n"); }
	| CONST_CHAR    { printf("const_char\n"); }
	| CONST_BOOL    { printf("const_bool\n"); }
	;

type
	: INT      { printf("int\n"); }
	| FLOAT    { printf("float\n"); }
	| DOUBLE   { printf("double\n"); }
	| LONG     { printf("long\n"); }
	| BOOL     { printf("bool\n"); }
	| CHAR     { printf("char\n"); }
	;


%%

int main(int argc, char** argv) {
	yyparse();
	return 0;
}
