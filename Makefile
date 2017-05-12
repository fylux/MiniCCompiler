scanner : main.c lexico.c minic.tab.c minic.tab.h linkedList.o
	@gcc main.c lexico.c minic.tab.c linkedList.o -lfl -lm  -o $@ 

lexico.c : micro.l minic.tab.h
	@flex --yylineno -o $@ micro.l

minic.tab.c minic.tab.h : minic.y
	@bison -d minic.y

linkedList.o : linkedList.c linkedList.h
	@gcc -c linkedList.c

clean:
	rm -f scanner lexico.c minic.tab.c minic.tab.h linkedList.o main.s

run : scanner in
	@./scanner in 1> main.s;

spim :
	@spim -file main.s
