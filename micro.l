%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "linkedList.h"
#include "minic.tab.h"

int comienzo;
char flexError = 0;
%}

L	[a-zA-Z_]
D	[0-9]


 //%s las CONDICION DE CONTEXTO
%x comentario


%%

func { 
	return FUNC;
}
var { 
	return VAR;
}
let { 
	return LET;
}
if { 
	return IF;
}
else { 
	return ELSE;
}
while { 
	return WHILE;
}
print { 
	return PRINT;
}
read { 
	return READ;
}
true {
	return TRUE;
}
false {
	return FALSE;
}
bool {
	return BOOL;
}
int {
	return INT;
}
">=" {
	return GE;
}
"<=" {
	return LE;
}
"==" {
	return EQ;
}
"!=" {
	return NEQ;
}
"&&" {
	return AND;
}

"||" {
	return OR;
}

[>] {
	return GT;
}
[<] {
	return LT;
}
[!] {
	return NEGATION;
}
[;] { 
	return SEMICOLON;
}
[,] { 
	return COMMA ;
}
[+]  { 
	return PLUS;
}
[-]  {  
	return MINUS;
}
[*]  { 
	return ASTERISK;
}

[/]  { 
	return SLASH;
}
[=]  { 
	return EQUAL;
}
[(]  {  
	return PARENTHI;
}
[)]  { 
	return PARENTHD;
}
[{]  { 
	return BRACKETI;
}
[}]  { 
	return BRACKETD;
}

[ \n\r\t]+ { /**/ }

{L}({L}|{D})* {
	if (yyleng > 16) {
		fprintf(stderr,"ERROR [%i]: ID longer than 16 chars %s\n",yylineno,yytext);
		flexError = 1;
	}
	else {
		yylval.str=strdup(yytext);
//		strcpy(yylval.str,yytext);

		return ID;
	}
}

{D}+ {
	if (labs(atol(yytext)) > pow(2,31)) {
		fprintf(stderr,"ERROR [%i]: |%s| greater than 2^31\n",yylineno,yytext);
		flexError = 1;
	}
	else {
		yylval.num = atoi(yytext);
		return INTEGER;
	}
}

\"([^\n\\"]|\\+[^\\\n])*\" {
	yylval.str=strdup(yytext);
	return STRING;
		
}


\"[^\n"]* {
	fprintf(stderr,"ERROR [%i]: Unclosed quotatin mark after string: %s\n",yylineno,yytext);
	flexError = 1;
}


"/*"	{comienzo=yylineno; BEGIN(comentario);}

<comentario>. { /**/}
<comentario>\n { /**/}
<comentario>"*/" { BEGIN(INITIAL);}
<comentario><<EOF>> {fprintf(stderr,"Unclosed comment [%d]\n",comienzo);return 0;} 



[^\n\r\t&|!<> *a-zA-Z0-9_/(),;{}+"=\\-]+ {
	fprintf(stderr,"Unknow token [%d]: %s\n",yylineno,yytext); 
	flexError = 1;
}


