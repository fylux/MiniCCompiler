%{
#include <stdio.h>
#include <string.h>
#include "linkedList.h"

List_var l = {NULL,NULL};
List_op lo = {NULL,NULL};

extern int yylex();
void yyerror(char *msg);
char * get_reg();
%}

%union {
	int i;
	char c[17];
	List_op p;
}

%token FUNC VAR LET IF ELSE WHILE PRINT READ STRING SEMICOLON COMMA PLUS MINUS ASTERISK SLASH EQUAL PARENTHI PARENTHD BRACKETI BRACKETD

%token<i> INTEGER

%token<c> ID

%type<p> expr expr2 fact assign;

%%
entrada : /*vacio*/ { printf("entrada -> lambda \n"); }
| entrada linea { printf("entrada -> entrada linea \n"); }
;

linea : expr SEMICOLON { printf("linea -> expr \n"); }
| assign SEMICOLON { printf("linea -> assign\n"); }
;

assign : ID EQUAL expr {
	printf("assign -> ");
	push_list_var(&l,$1);
}
;

expr : expr PLUS expr2 {
	printf("expr -> expr + expr2 \n");
	join_list_op(&$$,&$3);
	
	Op * p = create_op("add",get_reg(),"r1","r2");
	
	push_list_op(&$$,p);
	print_list_op(&$$);
}
| expr MINUS expr2 {
	printf("expr -> expr - expr2 \n");
}
| expr2 {
	printf("expr -> expr2\n");
}
;

expr2 : expr2 ASTERISK fact {
	printf("expr2 -> expr2 * fact \n");
}
| expr2 SLASH fact {
	printf("expr2 -> expr2 / term \n");
}
| fact {
	printf("expr2 -> fact \n");
}
;

fact : PARENTHI expr PARENTHD {
	printf("fact -> (expr) \n");
}
| MINUS fact {
	printf("fact -> - fact \n");
} 
| INTEGER {
	printf("fact -> DIGITO %d\n",$1);
	char r1[10];
	sprintf(r1, "%d", $1);
	Op * p = create_op("l1",get_reg(),r1,"-");	
	$$ = (List_op){NULL,NULL};
	push_list_op(&$$,p);
}
| ID {
	printf("fact -> ID \n");
	if (!find_list_var(&l,$1))
		printf("La variable %s no ha sido declarada\n",$1);
}
;
%%

void yyerror(char *msg) {
	printf("Error sintáctico: %s\n",msg);
}

char * get_reg(){
	return "$1";
}


