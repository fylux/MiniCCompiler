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
char * concat(char * a, char * b);
int is_mutable(Var * var);
char * int_to_string(int n);

List_var * list_var;
List_op * list_op;
List_str * list_str;

int nStr = -1;
int nJump = 0;

//var = 1, let = -1
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
%type<l_op> expr statement statement_list print_list print_item read_list read_item


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
| FUNC ID PARENTHI PARENTHD BRACKETI declarations statement_list BRACKETD {
	join_list_op(list_op,$7);
}
;

declarations:
/*lambda*/
| declarations VAR {varType = 1;} identifier_list SEMICOLON {}
| declarations LET {varType = -1;} identifier_list SEMICOLON {}
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
/*lambda*/ {
	$$ = init_list_op();
}
| statement_list statement {
	join_list_op($$,$2);
}
;

statement :
ID EQUAL expr SEMICOLON {
	$$ = init_list_op();
	Var * var = find_list_var(list_var,$1);
	if (var == NULL)
		printf("Error: undeclared var %s\n",$1);
	else if (!is_mutable(var))
		printf("Error: var %s is immutable\n",$1);
	else 
		assign_var($1,$$,$3);
}
| BRACKETI statement_list BRACKETD {
		$$ = $2;
	}
| IF PARENTHI expr PARENTHD statement ELSE statement {
	$$ = $3;

	char * dst = get_dst($3);
	Op * beqz = create_op("beqz",dst,concat("j_",int_to_string(++nJump)),"");
	Op * b = create_op("b",concat("j_",int_to_string(nJump+1)),"","");
	Op * jump1 = create_op(concat(concat("j_",int_to_string(nJump)),":"),"","","");
	Op * jump2 = create_op(concat(concat("j_",int_to_string(++nJump)),":"),"","","");
	
	push_list_op($$,beqz);
	join_list_op($$,$5);
	push_list_op($$,b);
	push_list_op($$,jump1);
	join_list_op($$,$7);
	push_list_op($$,jump2);

	free_reg(get_n_reg(dst));
}
| IF PARENTHI expr PARENTHD statement %prec NOELSE {
	$$ = $3;

	char * dst = get_dst($3);
	Op * beqz = create_op("beqz",dst,concat("j_",int_to_string(++nJump)),"");
	Op * jump = create_op(concat(concat("j_",int_to_string(nJump)),":"),"","","");

	push_list_op($$,beqz);
	join_list_op($$,$5);
	push_list_op($$,jump);

	free_reg(get_n_reg(dst));
}
| WHILE  PARENTHI expr PARENTHD statement  {
	$$ = init_list_op();

	char * dst = get_dst($3);
	Op * jump1 = create_op(concat(concat("j_",int_to_string(++nJump)),":"),"","","");
	Op * beqz = create_op("beqz",dst,concat("j_",int_to_string(nJump+1)),"");
	Op * jump2 = create_op(concat(concat("j_",int_to_string(++nJump)),":"),"","","");
	Op * loop = create_op("b",concat("j_",int_to_string(nJump-1)),"","");

	push_list_op($$,jump1);
	join_list_op($$,$3);
	push_list_op($$,beqz);
	join_list_op($$,$5);
	push_list_op($$,loop);
	push_list_op($$,jump2);
	
	free_reg(get_n_reg(dst));
}
| PRINT print_list SEMICOLON {
	$$ = $2;
	}
| READ read_list SEMICOLON {
	$$ = $2;
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
	Op * la = create_op("la",dst,concat("$",concat("str_",int_to_string(nStr))),"");
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

read_list : read_list COMMA read_item {
	$$ = init_list_op();
	join_list_op($$,$1);
	join_list_op($$,$3);
}
| read_item {
	$$ = $1;
}
;

read_item : ID {
	$$ = init_list_op();
	Var * var = find_list_var(list_var,$1);
	if (var == NULL)
		printf("Error: undeclared var %s\n",$1);
	else if (!is_mutable(var))
		printf("Error: var %s is immutable\n",$1);
	else {
		Op * li = create_op("li","$v0","5","");
		Op * syscall = create_op("syscall","","","");
		Op * sw = create_op("sw","$v0",concat("_",$1),"");

		push_list_op($$,li);
		push_list_op($$,syscall);
		push_list_op($$,sw);
	}
}


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
	printf("Syntax Error : %s\n",msg);
}

void declare_var(char * name) {
	if (find_list_var(list_var,name) != NULL)
			printf("Error: redeclared variable %s\n", name);
	else 
		push_list_var(list_var,name,int_type*varType);
}


List_op * load_var(char * name) {
	Var * aux = find_list_var(list_var,name);
	if (aux == NULL)
		printf("Error: undeclared variable %s\n",name);
	else {
		List_op * l = init_list_op();

		char * dst = get_reg();
		Op * op = create_op("lw",dst,concat("_",name),"");
		push_list_op(l,op);
		return l;
	}

	return NULL;
}

void assign_var(char * name, List_op * l1, List_op * l2) {
	char * dst = get_dst(l2);
	Op * op = create_op("sw",dst,concat("_",name),"");
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

char * concat(char * a, char * b) {
	char * buf = malloc(strlen(a)+strlen(b));
	snprintf(buf, sizeof buf, "%s%s", a,b);
	return buf;
}

char * int_to_string(int n) {
	char * str = malloc(sizeof(char)*4);
	sprintf(str, "%d", n);
	return str;
}

int is_mutable(Var * var) {
	return var->type > 0;
}