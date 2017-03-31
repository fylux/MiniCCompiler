%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "linkedList.h"

extern int yylex();
void yyerror(char *msg);

List_var list;

int senten = 0;
%}

%union {
	int num;
	char *str;	
}

%token FUNC VAR LET IF ELSE WHILE PRINT READ SEMICOLON COMMA PLUS MINUS ASTERISK SLASH EQUAL PARENTHI PARENTHD BRACKETI BRACKETD 

%token<num> INTEGER 
%token<str> ID STRING
%type<num>  asig expr 
%type<str> print_list print_item read_list

/* Precedencia y asociatividad de operadores */
//va de menos precedencia a más
%left PLUS MINUS
%left ASTERISK SLASH
%left UMINUS

%left NOELSE
%left ELSE


/*si conocemos el n%expect 0umero de conflictos desplaza reduce, podemos indicarlo con %expect */
%expect 0
%%
program :
////////////
/*vacio*/ { printf("Aplica entrada -> lambda \n");}
| FUNC ID PARENTHI PARENTHD BRACKETI declarations { senten = 1; } statement_list BRACKETD { }
;

declarations:
/*lambda*/
| declarations VAR identifier_list SEMICOLON {}
| declarations LET identifier_list SEMICOLON {}
;

identifier_list: 
asig {}
| identifier_list COMMA asig {}
;

asig:
ID {
	//find_list_var
}
| ID EQUAL expr {
	printf("create var\n");
	push_list_var(&list,$1,$3);
	$$=$3;
}
;

statement_list:
/*lambda*/
| statement_list statement
;

statement :
ID EQUAL expr SEMICOLON {
	printf("assign var \n");
	//push_list_var(&list,$1,$3);
	}
| BRACKETI statement_list BRACKETD {
	}
| IF PARENTHI expr PARENTHD statement ELSE statement {
	}
| IF PARENTHI expr PARENTHD statement %prec NOELSE {
	}
| WHILE  PARENTHI expr PARENTHD statement  {
	printf("aplica stament -> WHILE (expr) st \n");
	}
| PRINT print_list SEMICOLON {
	printf("aplica stament -> PRINT print_list \n");
	//syscall with printf of print_list
	}
| READ read_list SEMICOLON {
	printf("aplica stament -> READ read_list \n");
}
;

print_list: print_list COMMA print_item {
	printf("aplica print_list -> print_list , print_item \n");
	$$ = malloc(strlen($1)+strlen($3)+1+1);	
	sprintf($$, "%s,%s", $1,$3);
	}
| print_item {
	printf("aplica print_list -> print_item\n");
	}
;

print_item: 
STRING {
	printf("aplica print_item -> string\n");
	}
| expr {
	printf("aplica print_item -> expr \n");
	$$="expr"; //$$ = $1.to_string();
	}//sprintf($$, "%d", $1);}
;

read_list : read_list COMMA ID {
	printf("aplica read_list -> read_list , id \n");
	int aux=find_list_var(&list,$3);
	if(aux!=-1)	
		sprintf($$, "%s,%s", $1,$3);
	else
		sprintf($$, "%s,-2", $1);
}
| ID {
	printf("aplica read_list ->  id \n");
	int aux=find_list_var(&list,$1);
	if(aux!=-1) {
		printf("variable declarada \n");
		$$=$1;
	} else {
		printf("Error.Variable no declarada");
		sprintf($$, "-1");
	}
}
;

expr :
expr PLUS expr {printf("Aplica expr -> expr + expr \n"); $$=$1+$3;}

| expr MINUS expr {printf("Aplica expr-> expr - expr \n");$$=$1-$3;}

| expr ASTERISK expr { printf("Aplica expr -> expr * expr \n"); $$=$1*$3;} 

|expr SLASH expr { 
printf("Aplica expr -> expr / expr \n"); $$=$1/$3;} 

| MINUS expr %prec UMINUS {printf("Aplica expr -> MINUS po \n");$$=-$2;}

| PARENTHI expr PARENTHD { printf("Aplica expr -> (expr) \n"); $$=$2;}

| INTEGER  { printf("Aplica expr -> INT %d \n",$1);}
| ID {
	printf("expr->ID\n");
	int aux=find_list_var(&list,$1);
	if(aux!=-1) {printf("variable,valor= %d \n",aux);$$=aux;}
	else printf("Error.Variable no declarada");
}
;

/*
linea :
asig SEMICOLON { printf("Aplica linea -> expr SEMICOLON %d \n",$1);}
;

asig: ID EQUAL expr {printf("asig->asig=expr %s\n,",$1);$$=$3;

	push_list_var(&list,$1,$3);
	
	}
| stament {printf("asig->stament\n");$$=2;}
| expr {printf("asig->expr\n");}
;


stament :
PRINT print_list {printf("aplica stament -> PRINT print_list = %s \n",$2);$$=$2;}
|READ read_list {printf("aplica stament -> READ read_list = %s \n",$2);$$=$2;}
| WHILE  PARENTHI expr PARENTHD stament 
		{printf("aplica stament -> WHILE (expr) st \n");}

print_list: print_list COMMA print_item {printf("aplica print_list -> print_list , print_item \n");

	
	$$ = malloc(strlen($1)+strlen($3)+1+1);
		
	sprintf($$, "%s,%s", $1,$3);
}
| print_item {printf("aplica print_list -> print_item\n");}
;


print_item :
STRING {printf("aplica print_item -> string\n");}
| expr {printf("aplica print_item -> expr \n");$$="expr";}//sprintf($$, "%d", $1);}
;

read_list : read_list COMMA ID {printf("aplica read_list -> read_list , id \n");
	int aux=find_list_var(&list,$3);
	if(aux!=-1)	
		sprintf($$, "%s,%s", $1,$3);
	else sprintf($$, "%s,-2", $1);
}
| ID {printf("aplica read_list ->  id \n");

	int aux=find_list_var(&list,$1);
	if(aux!=-1) {printf("variable declarada \n");$$=$1;}
	else {printf("Error.Variable no declarada");sprintf($$, "-1");}
}

expr :
expr PLUS expr { printf("Aplica expr -> expr + expr \n"); $$=$1+$3;}

| expr MINUS expr {printf("Aplica expr-> expr - expr \n");$$=$1-$3;}

| expr ASTERISK expr { printf("Aplica expr -> expr * expr \n"); $$=$1*$3;} 

|expr SLASH expr { printf("Aplica expr -> expr / expr \n"); $$=$1/$3;} 

| expr POW expr {printf("Aplica expr -> expr POW expr \n");$$=pow($1,$3);}

| PARENTHI expr PARENTHD { printf("Aplica expr -> (expr) \n"); $$=$2;}

| MINUS expr %prec UMINUS {printf("Aplica expr -> MINUS po \n");$$=-$2;}
| INTEGER  { printf("Aplica expr -> INT %d \n",$1);}
| ID {
	printf("expr->ID\n");
	int aux=find_list_var(&list,$1);
	if(aux!=-1) {printf("variable,valor= %d \n",aux);$$=aux;}
	else printf("Error.Variable no declarada");
}
;*/
%%

void yyerror(char *msg) {
	printf("Error sintáctico: %s\n",msg);
}
