//Programa principal

#include <stdio.h>
#include <stdlib.h>
#include "linkedList.h"
#include "syntax.tab.h"


extern List_var l;
extern List_op lo;

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern char *yytext;

int main(int argc, char **argv) {
	if (argc !=2) {
		printf("Uso: %s fichero.stl\n", argv[0]);
		exit(1);	
	}

	FILE *fichero = fopen(argv[1],"r");
	if (fichero == NULL ){ 
		printf("Error: no se puede abrir %s\n",argv[1]);
		exit(2);
	}

	yyin = fichero;
	int token;

	yyparse();

	free_list_var(&l);
	fclose(fichero);
	return 0;

}
