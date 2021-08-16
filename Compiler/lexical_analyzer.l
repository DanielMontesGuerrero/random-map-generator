%{
	#include<stdio.h>
	#include "symbol_table.h"
	#include"syntactic_analyzer.tab.h"
	#define _BOOL_ 1
	#define _INT_ 2
	#define _LONG_ 3
	#define _FLOAT_ 4
	#define _DOUBLE_ 5
	#define _CHAR_ 6
	#define _STRING_ 7
	#define _TILE_ 8
	#define _SMARTTILE_ 9
	#define _SECTION_ 10
	#define _CONTAINER_ 11
	#define PERLIN_NOISE 20
	#define SMOOTHED_PERLIN_NOISE 21
	#define RANDOM_WALK 22
	#define SMOOTHED_RANDOM_WALK 23
	#define PERLIN_NOISE_CAVE 24
	#define RANDOM_WALK_CAVE 25
	#define DIRECCIONAL_TUNNEL 26
	#define CELLULAR_AUTOMATA 27 
	#define MOORE_CELLULAR_AUTOMATA 28
	#define VON_NEUMANN_CELLULAR_AUTOMATA 29
%}

DIGIT [0-9]
LETTER [a-zA-Z]
SUFFIX (u|U|L|l)*

%%

 /* reserved words */
"set size"        { return SET; }
"smarttile"  { 
	yylval.SMARTTILE = SMARTTILE;
	return SMARTTILE; 
	}
"tileset"    { return TILESET; }
"tile"       { return TILE; }
"section"    { return SECTION; }
"name" 	     { return NAME; }
"default"    { return DEFAULT; }
"sasageyo"   { return MAIN; }
"end"        { return END; }
"new"        { return NEW; }
"join"       { return JOIN; }
"for"        { return FOR; }
"while"      { return WHILE; }
"if"         { return IF; }
"container"  { return CONTAINER; }
"int"        { 
	yylval.INT = (symrec*)malloc(sizeof(symrec));
	yylval.INT -> type = _INT_; 
	return INT; 
	}
"char"       { 
	yylval.CHAR = (symrec*)malloc(sizeof(symrec));
	yylval.CHAR -> type = _CHAR_; 
	return CHAR; 
	}
"string"     { 
	yylval.STRING = (symrec*)malloc(sizeof(symrec));
	yylval.STRING -> type = _STRING_; 
	return STRING; 
	}
"float"      { 
	yylval.FLOAT = (symrec*)malloc(sizeof(symrec));
	yylval.FLOAT -> type = _FLOAT_; 
	return FLOAT; 
	}
"bool"       { 
	yylval.BOOL = (symrec*)malloc(sizeof(symrec));
	yylval.BOOL -> type  = _BOOL_; 
	return BOOL; 
	}
"double"     { 
	yylval.DOUBLE = (symrec*)malloc(sizeof(symrec));
	yylval.DOUBLE -> type = _DOUBLE_; 
	return DOUBLE;
	}
"long"       { 
	yylval.LONG = (symrec*)malloc(sizeof(symrec));
	yylval.LONG -> type = _LONG_; 
	return LONG; 
	}
"j_sections" {
	yylval.J_SECTIONS = (symrec*)malloc(sizeof(symrec));
	strcpy(yylval.J_SECTIONS -> name, yytext);
	return J_SECTIONS; 
}
"sections" {
	yylval.SECTIONS = (symrec*)malloc(sizeof(symrec));
	strcpy(yylval.SECTIONS -> name, yytext);
	return SECTIONS; 
	}
"else"	     			{ 
					return ELSE;
				}
"PerlinNoise" 			{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("PerlinNoise"));
					strcpy(yylval.ALGORITHM, "PerlinNoise");
					return ALGORITHM;
				}
"PerlinNoiseSmoothed"		{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("PerlinNoiseSmoothed"));
					strcpy(yylval.ALGORITHM, "PerlinNoiseSmoothed");
					return ALGORITHM;
				}
"RandomWalkSmoothed"		{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("SmoothedRandomWalk"));
					strcpy(yylval.ALGORITHM, "RandomWalkSmoothed");
					return ALGORITHM;
				}
"PerlinNoiseCave"		{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("PerlinNoiseCave"));
					strcpy(yylval.ALGORITHM, "PerlinNoiseCave");
					return ALGORITHM;
				}
"RandomWalkCave"		{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("RandomWalkCave"));
					strcpy(yylval.ALGORITHM, "RandomWalkCave");
					return ALGORITHM;
				}
"CellularAutomata"		{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("CellularAutomata"));
					strcpy(yylval.ALGORITHM, "CellularAutomata");
					return ALGORITHM;
				}
"MooreCellularAutomata"		{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("MooreCellularAutomata"));
					strcpy(yylval.ALGORITHM, "MooreCellularAutomata");
					return ALGORITHM;
				}
"VonNeumannCellularAutomata" 	{
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("VonNeumannCellularAutomata"));
					strcpy(yylval.ALGORITHM, "VonNeumannCellularAutomata");
					return ALGORITHM;
				}
"RandomWalk" 			{ 
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("RandomWalk"));
					strcpy(yylval.ALGORITHM, "RandomWalk");
					return ALGORITHM; 
				}
"DirectionalTunnel" 		{ 
					yylval.ALGORITHM = (char*)malloc(sizeof(char)*strlen("DirectionalTunnel"));
					strcpy(yylval.ALGORITHM, "DirectionalTunnel");
					return ALGORITHM; 
				}
"rule"	     { return RULE; }
"--"  { return MINUSMINUS; }
"++"  { return PLUSPLUS; }
"=="  { yylval.EQ = EQ; return EQ; }

 /* constans */
"true"|"false"                     {
	yylval.CONST_BOOL = (symrec*)malloc(sizeof(symrec));
	if(strcmp(yytext, "true") == 0){
		yylval.CONST_BOOL -> value._bool = 1; 
	}
	else {
		yylval.CONST_BOOL -> value._bool = 0;
	}
	return CONST_BOOL; 
	}
{DIGIT}+L                          { 
	yylval.CONST_LONG = (symrec*)malloc(sizeof(symrec));
	yylval.CONST_LONG -> value._long = atoi(yytext); 
	return CONST_LONG; 
	}
{DIGIT}+                           { 
	yylval.CONST_INT = (symrec*)malloc(sizeof(symrec));
	yylval.CONST_INT -> value._int = atoi(yytext); 
	return CONST_INT; 
	}
{DIGIT}+"."{DIGIT}+f               { 
	yylval.CONST_FLOAT = (symrec*)malloc(sizeof(symrec));
	yylval.CONST_FLOAT -> value._float = atof(yytext); 
	return CONST_FLOAT; 
	}

{DIGIT}+"."{DIGIT}+D?          	   { 
	yylval.CONST_DOUBLE = (symrec*)malloc(sizeof(symrec));
	yylval.CONST_DOUBLE -> value._double = atof(yytext); 
	return CONST_DOUBLE; 
	}
{LETTER}({LETTER}|{DIGIT}|[_$])* { 
	yylval.IDENTIFIER = (symrec*)malloc(sizeof(symrec));
	strcpy(yylval.IDENTIFIER -> name, yytext); 
	return IDENTIFIER; 
	}
\"(\\.|[^\\"])*\"                { 
	yylval.CONST_STRING  = (symrec*)malloc(sizeof(symrec));
	yytext++;
	int len = strlen(yytext);
	yytext[len-1] = '\0';
	yylval.CONST_STRING -> value._string = (char*)malloc(sizeof(char)*(len-1));
	strcpy(yylval.CONST_STRING -> value._string, yytext);
	return CONST_STRING; 
	}
'(\\.|[^\\"])'            	{
	yylval.CONST_CHAR = (symrec*)malloc(sizeof(symrec));
	yylval.CONST_CHAR -> value._char = yytext[1];
	return CONST_CHAR; 
	}

 /* operators */
"+"  { return '+'; }
"*"  { return '*'; }
"/"  { return '/'; }
"-"  { return '-'; }
"%"  { return '%'; }
"="  { return '='; }
"<"  { yylval.LESS = LESS; return LESS; }
">"  { yylval.GREATER = GREATER; return GREATER; }
">=" { yylval.GREATER_EQ = GREATER_EQ; return GREATER_EQ; }
"<=" { yylval.LESS_EQ = LESS_EQ; return LESS_EQ; }
"&&" { yylval.AND_OP = AND_OP; return AND_OP; }
"!"  { return '!'; }
"!=" { yylval.NEQ = NEQ; return NEQ; }
"||" { yylval.OR_OP = OR_OP; return OR_OP; }
";"  { return ';'; }
","  { return ','; }
"("  { return '('; }
")"  { return ')'; }
"{"  { return '{'; }
"}"  { return '}'; }
"["  { return '['; }
"]"  { return ']'; }
":"  { return ':'; }
"$"  { return '$'; }
"?"  { return '?'; }

"//"*
.
%%

