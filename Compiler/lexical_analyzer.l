%{
	#include<stdio.h>
	#include"syntactic_analyzer.tab.h"
%}

DIGIT [0-9]
LETTER [a-zA-Z]
SUFFIX (u|U|L|l)*

%%

 /* reserved words */
"set"        { return SET; }
"smarttile"  { return SMARTTILE; }
"tile"       { return TILE; }
"section"    { return SECTION; }
"begin"      { return _BEGIN; }
"end"        { return END; }
"new"        { return NEW; }
"join"       { return JOIN; }
"for"        { return FOR; }
"while"      { return WHILE; }
"if"         { return IF; }
"container"  { return CONTAINER; }
"int"        { return INT; }
"char"       { return CHAR; }
"string"     { return STRING; }
"float"      { return FLOAT; }
"bool"       { return BOOL; }
"double"     { return DOUBLE; }
"long"       { return LONG; }

 /* constans */
"true"|"false"                     { return CONST_BOOL; }
{DIGIT}+L                          { return CONST_LONG; }
{DIGIT}+                           { return CONST_INT; }
{DIGIT}+"."{DIGIT}+D?              { return CONST_DOUBLE; }
{DIGIT}+"."{DIGIT}+F               { return CONST_FLOAT; }
{LETTER}({LETTER}|{DIGIT}|[_\-$])* { return IDENTIFIER; }
"'"(\\.|[^\\'])"'"                 { return CONST_STRING; }
\"(\\.|[^\\"])*\"                  { return CONST_CHAR; }

 /* operators */
"+"  { return '+'; }
"*"  { return '*'; }
"/"  { return '/'; }
"-"  { return '-'; }
"%"  { return '%'; }
"="  { return '='; }
"<"  { return '<'; }
">"  { return '>'; }
">=" { return GREATER_EQ; }
"<=" { return LESS_EQ; }
"&&" { return AND_OP; }
"!"  { return '!'; }
"!=" { return NEQ; }
"||" { return OR_OP; }
";"  { return ';'; }
","  { return ','; }
"("  { return '('; }
")"  { return ')'; }
"{"  { return '{'; }
"}"  { return '}'; }
"["  { return '['; }
"]"  { return ']'; }
":"  { return ':'; }

.

%%

