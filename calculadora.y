%{
#include <stdio.h>
//#include <ctype.h>
extern int yylex();
void yyerror(char *msg);
%}

%token FUNC VAR LET IF ELSE WHILE PRINT READ ID INTEGER STRING SEMICOLON COMMA PLUS MINUS ASTERISK SLASH EQUAL PARENTHI PARENTHD BRACKETI BRACKETD


%%
entrada : /*vacio*/ { printf("Aplica entrada -> lambda \n"); }
| entrada linea { printf("Aplica entrada -> entrada linea \n"); }
;

linea : expr SEMICOLON { printf("Aplica linea -> expr = %d \n", $1); }
;

expr : expr PLUS term { printf("Aplica expr -> expr + term \n"); $$=$1+$3;}
| expr MINUS term { printf("Aplica expr -> expr - term \n"); $$=$1-$3;}
| term { printf("Aplica expr->term\n");}
;

term : term ASTERISK fact { printf("Aplica term -> term * fact \n"); $$=$1*$3;}
| term SLASH fact { printf("Aplica expr -> expr / term \n"); $$=$1/$3;}
| fact { printf("Aplica term -> fact \n");}
;

fact : PARENTHI expr PARENTHD { printf("Aplica fact -> (expr) \n"); $$=$2;}
| MINUS fact {printf("Aplica fact -> - fact \n"); $$ = -$2;} 
|INTEGER { printf("Aplica fact -> DIGITO \n");}
;
%%

void yyerror(char *msg) {
	printf("Error sintáctico: %s\n",msg);
}

