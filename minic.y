%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "linkedList.h"


extern int yylex();

void yyerror(char *msg);
void declare_var(char * name);
List_op * load_var(char * name);
void assign_var(char * name, List_op * l1, List_op * l2);
void arithmetic_op(char * type, List_op * join, List_op * l1, List_op * l2);
char * concatenate(char * a, char * b);
char * int_to_string(int n);

List_var * list_var;
List_op * list_op;
List_str * list_str;

int senten = 0;
int nStr = -1;
//var = -1, let = 1
int varType = 0;

char int_type = 1;
char float_type = 2;
%}

%union {
	int num;
	char * str;
	List_op * l_op;
}

%token FUNC VAR LET IF ELSE WHILE PRINT READ SEMICOLON COMMA PLUS MINUS ASTERISK SLASH EQUAL PARENTHI PARENTHD BRACKETI BRACKETD 

%token<num> INTEGER 
%token<str> STRING ID
%type<num>  asig 
%type<l_op> expr statement print_list print_item 
%type<str>  read_list

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
| FUNC ID PARENTHI PARENTHD BRACKETI declarations { senten = 1; } statement_list BRACKETD {
}
;

declarations:
/*lambda*/
| declarations VAR /*{varType = -1;}*/ identifier_list SEMICOLON {}
| declarations LET /*{varType = 1;}*/ identifier_list SEMICOLON {}
;

identifier_list: 
asig {}
| identifier_list COMMA asig {}
;

asig:
ID {
	declare_var($1);
}
| ID EQUAL expr {
	declare_var($1);
	assign_var($1,list_op,$3);
}
;

statement_list:
/*lambda*/
| statement_list statement {
	join_list_op(list_op,$2);
}
;

statement :
ID EQUAL expr SEMICOLON {
	$$ = init_list_op();
	assign_var($1,$$,$3);
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
	$$ = $2;
	}
| READ read_list SEMICOLON {
	printf("aplica stament -> READ read_list \n");
}
;

print_list: print_list COMMA print_item {
	$$ = init_list_op();
	join_list_op($$,$1);
	join_list_op($$,$3);
}
| print_item {
	$$ = $1;
}
;

print_item: 
STRING {
	nStr++;
	push_list_str(list_str, $1);
	$$ = init_list_op();

	char * dst = get_reg();
	Op * la = create_op("la",dst,concatenate("$",concatenate("str_",int_to_string(nStr))),"");
	Op * op = create_op("move","$a0",dst,"");
	Op * li = create_op("li","$v0","4","");
	Op * syscall = create_op("syscall","","","");

	push_list_op($$,la);
	push_list_op($$,op);
	push_list_op($$,li);
	push_list_op($$,syscall);

	free_reg(get_n_reg(dst));
}
| expr {
	nStr++;
	$$ = init_list_op();
	char * dst = get_dst($1);

	join_list_op($$,$1);

	Op * op = create_op("move","$a0",dst,"");
	Op * li = create_op("li","$v0","1","");
	Op * syscall = create_op("syscall","","","");

	push_list_op($$,op);
	push_list_op($$,li);
	push_list_op($$,syscall);

	free_reg(get_n_reg(dst));
}
;

read_list : read_list COMMA ID {
	printf("aplica read_list -> read_list , id \n");
	load_var($3);
}
| ID {
	
}
;

expr :
expr PLUS expr {
	$$ = init_list_op();
	arithmetic_op("add",$$,$1,$3);
}
| expr MINUS expr {
	$$ = init_list_op();
	arithmetic_op("sub",$$,$1,$3);
}

| expr ASTERISK expr {
	$$ = init_list_op();
	arithmetic_op("mult",$$,$1,$3);
} 

| expr SLASH expr { 
	$$ = init_list_op();
	char * n1 = get_dst($1);
	char * n2 = get_dst($3);

	join_list_op($$,$1);
	join_list_op($$,$3);
	Op * op1 = create_op("div",n1,n2,"");
	Op * op2 = create_op("mflo",n1,"","");

	push_list_op($$,op1);
	push_list_op($$,op2);
	free_reg(get_n_reg(n2));
} 

| MINUS expr %prec UMINUS {
	$$ = init_list_op();
	char * dst = get_dst($2);
	char * zero = get_reg();

	join_list_op($$,$2);

	Op * op1 = create_op("li",zero,"0","");
	Op * op2 = create_op("sub",dst,zero,dst);

	push_list_op($$,op1);
	push_list_op($$,op2);
	free_reg(get_n_reg(zero));
}

| PARENTHI expr PARENTHD {
	$$ = $2;
}

| INTEGER  {
	$$ = init_list_op();
	char n[11];
	sprintf(n,"%d",$1);
	Op * op = create_op("li",get_reg(),n,"");
	push_list_op($$,op);
}

| ID {
	$$ = load_var($1);
}
;

%%

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

void yyerror(char *msg) {
	printf("Syntax Error	: %s\n",msg);
}

void declare_var(char * name) {
	//TODO Differente between let and var

	if (find_list_var(list_var,name) != NULL)
			printf("Error: redeclared variable %s\n", name);
	else
		push_list_var(list_var,name,int_type);
}


List_op * load_var(char * name) {
	Var * aux = find_list_var(list_var,name);
	if (aux == NULL)
		printf("Error: undeclared variable %s\n",name);
	else {
		List_op * l = init_list_op();

		char * dst = get_reg();
		Op * op = create_op("lw",dst,name,"");
		push_list_op(l,op);
		free_reg(get_n_reg(dst));
		return l;
	}

	return NULL;
}

void assign_var(char * name, List_op * l1, List_op * l2) {
	char * dst = get_dst(l2);
	Op * op = create_op("sw",dst,concatenate("_",name),"");
	free_reg(get_n_reg(dst));

	push_list_op(l2,op);
	join_list_op(l1,l2);
}

void arithmetic_op(char * type, List_op * join, List_op * l1, List_op * l2) {
	char * n1 = get_dst(l1);
	char * n2 = get_dst(l2);

	join_list_op(join,l1);
	join_list_op(join,l2);
	Op * op = create_op(type,n1,n1,n2);

	push_list_op(join,op);
	free_reg(get_n_reg(n2));
}

char * concatenate(char * a, char * b) {
	char * buf = malloc(strlen(a)+strlen(b));
	snprintf(buf, sizeof buf, "%s%s", a,b);
	return buf;
}

char * int_to_string(int n) {
	char * str = malloc(sizeof(char)*4);
	sprintf(str, "%d", n);
	return str;
}
