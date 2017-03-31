%{
#include <stdio.h>
#include "minic.tab.h"
#include <math.h>
#include <string.h>
#include "linkedList.h"
int comienzo;

%}

L	[a-zA-Z_]
D	[0-9]


 //%s las CONDICION DE CONTEXTO
%x comentario




%%

func { 
	printf("FUNC\n"); return FUNC;
}
var { 
	printf("VAR\n"); return VAR;
}
let { 
	printf("LET\n"); return LET;
}
if { 
	printf("IF\n"); return IF;
}
else { 
	printf("ELSE\n"); return ELSE;
}
while { 
	printf("WHILE\n"); return WHILE;
}
print { 
	printf("PRINT\n"); return PRINT;
}
read { 
	printf("READ\n"); return READ;
}
[;] { 
	printf("SEMICOLON\n"); return SEMICOLON;
}
[,] { 
	printf("COMMA \n"); return COMMA ;
}
[+]  { 
	printf("PLUS\n"); return PLUS;
}
[-]  { 
	printf("MINUS\n"); return MINUS;
}
[*]  { 
	printf("ASTERISK\n"); return ASTERISK;
}

[/]  { 
	printf("SLASH\n"); return SLASH;
}
[=]  { 
	printf("EQUAL\n"); return EQUAL;
}
[(]  { 
	printf("PARENTHI\n"); return PARENTHI;
}
[)]  { 
	printf("PARENTHD\n"); return PARENTHD;
}
[{]  { 
	printf("BRACKETI\n"); return BRACKETI;
}
[}]  { 
	printf("BRACKETD\n"); return BRACKETD;
}

[ \n\r\t]+ { /**/ }

{L}({L}|{D})* {
	if (yyleng > 16) {
		printf("ERROR [%i]: ID longer than 16 chars %s\n",yylineno,yytext);
	}
	else {
		yylval.str=strdup(yytext);
		printf("ID: %s\n",yytext);
//		strcpy(yylval.str,yytext);

		return ID;
	}
}

{D}+ {
	if (labs(atol(yytext)) > pow(2,31)) {
		printf("ERROR [%i]: |%s| greater than 2^31\n",yylineno,yytext);	
	}
	else {
		printf("INTEGER: %s\n",yytext);
		yylval.num = atoi(yytext);
		return INTEGER;
	}
}

\"[^\n"]*\" {
	printf("STRING: %s\n",yytext);
	yylval.str=strdup(yytext);
	return STRING;
		
}


\"[^\n"]* {
	printf("ERROR [%i]: Unclosed quotatin mark after string: %s\n",yylineno,yytext);
}


"/*"	{comienzo=yylineno; BEGIN(comentario);}

<comentario>. { /*IGNORAR*/}
<comentario>\n { /*IGNORAR*/}
<comentario>"*/" { BEGIN(INITIAL);}
<comentario><<EOF>> {printf("Unclosed comment [%d]\n",comienzo);} 


[^\n\r\t *a-zA-Z0-9_/(),;{}+"=-]+ {
	printf("Unknow token [%d]: %s\n",yylineno,yytext); 
}


