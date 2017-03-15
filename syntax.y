%{
#include <stdio.h>
#include <string.h>
#include "linkedList.h"

List_var l = {NULL,NULL};
List_op lo = {NULL,NULL};
List_var l_str = {NULL,NULL};
int n_str = 0;


extern int yylex();
void yyerror(char *msg);

%}

%union {
	int i;
	char c[17];
	List_op p;
}

%token FUNC VAR LET IF ELSE WHILE PRINT READ SEMICOLON COMMA PLUS MINUS ASTERISK SLASH EQUAL PARENTHI PARENTHD BRACKETI BRACKETD

%token<i> INTEGER

%token<c> ID STRING

%type<p> expr expr2 fact assign print entrada linea;

%%
entrada : /*empty*/ {
	//printf("entrada -> lambda \n");
}
| entrada linea SEMICOLON{
	//printf("entrada -> entrada linea \n");
	print_list_op(&$2);
}
;

linea : expr {
	//printf("linea -> expr \n");
}
| assign{
	//printf("linea -> assign\n");
}
| print {

}
;

print : PRINT PARENTHI STRING PARENTHD { 
	push_list_var(&l_str,$3);
	//print_list_var(&l_str);
	
	char str_dir[7];
	sprintf(str_dir,"_str%d",n_str);
	Op * p1 = create_op("li","$v0","4","");
	Op * p2 = create_op("la","$a0",str_dir,"");
	Op * p3 = create_op("syscall","","","");
	$$ = (List_op){NULL,NULL};
	push_list_op(&$$,p1);
	push_list_op(&$$,p2);
	push_list_op(&$$,p3);

	n_str++; //_str[0-9]+
}
;

assign : ID EQUAL expr {
	//printf("assign -> ");
	/*push_list_var(&l,$1);
	$$ = (List_op){NULL,NULL};
	join_list_op(&$$,&$3);*/
	//print_list_var(&l);
}
;

expr : expr PLUS expr2 {
	//printf("expr -> expr + expr2 \n");
	join_list_op(&$$,&$3);
	
	Op * p = create_op("add",get_dst(&$1),get_dst(&$1),get_dst(&$3));
	
	push_list_op(&$$,p);
	//print_list_op(&$$);

	free_reg(get_n_reg(get_dst(&$3)));
}
| expr MINUS expr2 {
	//printf("expr -> expr - expr2 \n");
}
| expr2 {
	//printf("expr -> expr2\n");
}
;

expr2 : expr2 ASTERISK fact {
	//printf("expr2 -> expr2 * fact \n");
}
| expr2 SLASH fact {
	//printf("expr2 -> expr2 / term \n");
}
| fact {
	//printf("expr2 -> fact \n");
}
;

fact : PARENTHI expr PARENTHD {
	//printf("fact -> (expr) \n");
}
| MINUS fact {
	//printf("fact -> - fact \n");
} 
| INTEGER {
	//printf("fact -> DIGITO %d\n",$1);
	char r1[10];
	sprintf(r1, "%d", $1);
	Op * p = create_op("l1",get_reg(),r1,"");	
	$$ = (List_op){NULL,NULL};
	push_list_op(&$$,p);
}
| ID {
	//printf("fact -> ID \n");
	int var_position = find_list_var(&l,$1);
	if ( var_position == -1)
		printf("La variable %s no ha sido declarada\n",$1);
	else {
		char * var_name[5];
		sprintf(var_name,"_%d",var_position);
		Op * p = create_op("lw",get_reg(),var_name,"");	
		$$ = (List_op){NULL,NULL};
		push_list_op(&$$,p);
	}
}
;
%%

void yyerror(char *msg) {
	printf("Error sintáctico: %s\n",msg);
}

