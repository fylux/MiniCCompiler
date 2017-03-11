
scanner : main.c lexical.c syntax.tab.c syntax.tab.h linkedList.o
	gcc main.c lexical.c syntax.tab.c linkedList.o -lfl -o $@ 

lexical.c : micro.l syntax.tab.h
	flex --yylineno -o $@ micro.l

syntax.tab.c syntax.tab.h : syntax.y
	bison -d syntax.y

linkedList.o : linkedList.c linkedList.h
	gcc -c linkedList.c
clean:
	rm -f scanner lexical.c syntax.tab.c syntax.tab.h linkedList.o

run : scanner in
	./scanner in
