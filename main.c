//Programa principal

#include "minic.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include "linkedList.h"
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern char *yytext;
extern List_var list;
//extern int yydebug;
int main(int argc, char **argv) {
	//return yyparse();
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
	ini_list_var(&list);
//	yydebug = 0;
	yyparse();

	/*while ( (token= yylex())!=0){
	if (token == ID)
		printf("ID visto en main: %s\n",yytext);					
	}*/

	fclose(fichero);
	return 0;

}
