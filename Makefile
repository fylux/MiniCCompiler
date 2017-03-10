
scanner : main.c lexico.c calculadora.tab.c calculadora.tab.h
	gcc main.c lexico.c calculadora.tab.c -lfl -o $@ 

lexico.c : micro.l calculadora.tab.h
	flex --yylineno -o $@ micro.l

calculadora.tab.c calculadora.tab.h : calculadora.y
	bison -d calculadora.y

clean:
	rm -f scanner lexico.c calculadora.tab.c calculadora.tab.h

run : scanner in
	./scanner in
