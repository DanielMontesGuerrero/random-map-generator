compiler.out: lex.yy.o syntactic_analyzer.tab.o
	gcc lex.yy.o syntactic_analyzer.tab.o -lfl -o compiler.out

lex.yy.c: lexical_analyzer.l syntactic_analyzer.tab.h
	flex lexical_analyzer.l

syntactic_analyzer.tab.c syntactic_analyzer.tab.h: syntactic_analyzer.y
	bison -d syntactic_analyzer.y

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

syntactic_analyzer.tab.o: syntactic_analyzer.tab.c
	gcc -c syntactic_analyzer.tab.c

clean:
	rm compiler.out syntactic_analyzer.tab.* lex.yy.*
