%{
#include <stdio.h>
#include <string.h>
#include "linkedList.h"

List l={NULL,NULL};


extern int yylex();
void yyerror(char *msg);

%}

%union {
	int i;
	char c[17];
}

%token FUNC VAR LET IF ELSE WHILE PRINT READ STRING SEMICOLON COMMA PLUS MINUS ASTERISK SLASH EQUAL PARENTHI PARENTHD BRACKETI BRACKETD

%token<i> INTEGER

%token<c> ID

%type<i> expr expr2 fact;

%%
entrada : /*vacio*/ { printf("Aplica entrada -> lambda \n"); }
| entrada linea { printf("Aplica entrada -> entrada linea \n"); }
;

linea : expr SEMICOLON { printf("Aplica linea -> expr = %d \n", $1); }
| assign SEMICOLON { printf("Aplica linea -> assign\n"); }
;

assign : ID EQUAL expr { printf("Aplica assign -> %s = %d\n",$1,$3);}
;

expr : expr PLUS expr2 { printf("Aplica expr -> expr + expr2 \n"); $$=$1+$3;}
| expr MINUS expr2 { printf("Aplica expr -> expr - expr2 \n"); $$=$1-$3;}
| expr2 { printf("Aplica expr -> expr2\n");}
;

expr2 : expr2 ASTERISK fact { printf("Aplica expr2 -> expr2 * fact \n"); $$=$1*$3;}
| expr2 SLASH fact { printf("Aplica expr2 -> expr2 / term \n"); $$=$1/$3;}
| fact { printf("Aplica expr2 -> fact \n");}
;

fact : PARENTHI expr PARENTHD { printf("Aplica fact -> (expr) \n"); $$=$2;}
| MINUS fact {printf("Aplica fact -> - fact \n"); $$ = -$2;} 
| INTEGER { printf("Aplica fact -> DIGITO \n"); $$=$1;}
| ID { printf("Aplica fact -> ID \n"); $$=0; /*TODO*/ }
;
%%

void yyerror(char *msg) {
	printf("Error sintáctico: %s\n",msg);
	push_list(&l,5);
	push_list(&l,3);
	push_list(&l,2);
	printf("%d\n",find_list(&l,2));
	free_list(&l);
	printf("%d\n",find_list(&l,2));
}

