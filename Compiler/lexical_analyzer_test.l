%{
	#include<stdio.h>
%}

DIGIT [0-9]
LETTER [a-zA-Z]
SUFFIX (u|U|L|l)*

%%

 /* reserved words */
"set"       { printf("<set>"); }
"smarttile" { printf("<smarttile>"); }
"tile"      { printf("<tile>"); }
"section"   { printf("<section>"); }
"begin"     { printf("<begin>"); }
"end"       { printf("<end>"); }
"new"       { printf("<new>"); }
"join"      { printf("<join>"); }
"for"       { printf("<for>"); }
"while"     { printf("<while>"); }
"if"        { printf("<if>"); }
"container" { printf("<container>"); }
"int"       { printf("<int>"); }
"char"      { printf("<char>"); }
"string"    { printf("<string>"); }
"float"     { printf("<float>"); }
"bool"      { printf("<bool>"); }
"double"    { printf("<double>"); }
"long"      { printf("<long>"); }

 /* constans */
"true"|"false"                     { printf("<const_bool>"); }
{DIGIT}+L                          { printf("<const_long>"); }
{DIGIT}+                           { printf("<const_integer>"); }
{DIGIT}+"."{DIGIT}+D?              { printf("<const_double>"); }
{DIGIT}+"."{DIGIT}+F               { printf("<const_float>"); }
{LETTER}({LETTER}|{DIGIT}|[_\-$])* { printf("<identifier>"); }
"'"(\\.|[^\\'])"'"                 { printf("<const_char>"); }
\"(\\.|[^\\"])*\"                  { printf("<const_string>"); }

 /* operators */
"+"  { printf("+"); }
"*"  { printf("*"); }
"/"  { printf("/"); }
"-"  { printf("-"); }
"%"  { printf("%%"); }
"="  { printf("="); }
"<"  { printf("<"); }
">"  { printf(">"); }
">=" { printf(">="); }
"<=" { printf("<="); }
"&&" { printf("&&"); }
"!"  { printf("!"); }
"!=" { printf("!="); }
"||" { printf("||"); }
";"  { printf(";"); }
","  { printf(","); }
"("  { printf("("); }
")"  { printf(")"); }
"{"  { printf("{"); }
"}"  { printf("}"); }
"["  { printf("["); }
"]"  { printf("]"); }
":"  { printf(":"); }

%%

int main(int argc, char **argv) {
	++argv;
	argc--;
	if (argc > 0)
		yyin = fopen(argv[0], "r");
	else
		yyin = stdin;
	yylex();
}
