#include <stdio.h>
#include <stdlib.h>
#include "linkedList.h"
//#include "minic.tab.h"

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern char *yytext;

extern List_var * list_var;
extern List_str * list_str;
extern List_op * list_op;
extern char error;

int main(int argc, char **argv) {

	if (argc !=2) {
		printf("Uso: %s fichero.stl\n", argv[0]);
		exit(1);	
	}

	FILE *fichero = fopen(argv[1],"r");
	if (fichero == NULL ){ 
		printf("ERROR: cannot open %s\n",argv[1]);
		exit(2);
	}

	yyin = fichero;
	list_var = init_list_var();
	list_str = init_list_str();
	list_op = init_list_op();


	yyparse();

	fclose(fichero);

	if (!error) {
 		printf(".data\n");
		print_list_str(list_str);
		printf("\n");
		print_list_var(list_var);

		printf("\n.text\n.globl main\n\nmain:\n");
		print_list_op(list_op);
		
		printf("\n\tjr $ra\n");
	}

	free_list_var(list_var);
	free_list_op(list_op);
	free_list_str(list_str);

	return 0;

}
