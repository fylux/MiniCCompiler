#ifndef INFO_H_HEADER_
#define INFO_H_HEADER_

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

typedef char * Element;

typedef struct List_var List_var;
typedef struct Var Var;
typedef struct List_op List_op;
typedef struct Op Op;
typedef struct List_str List_str;
typedef struct Str Str;


struct Op {
	char cod[8];
	char dst[4];
	char arg1[11];
	char arg2[11];
	Op * sig;
};

struct Var
{
	char elem[17];
	char type;
	Var * sig;
};

struct Str
{
	char * str;
	Str * sig;
};

struct List_var
{
	Var * head;
	Var * tail;
};

struct List_op
{
	Op * head;
	Op * tail;
};

struct List_str
{
	Str * head;
	Str * tail;
};


List_var * init_list_var();
List_op * init_list_op();
List_str * init_list_str();

void free_list_var(List_var * l);
void free_list_op(List_op * l);
void free_list_str(List_str * l);

Var * find_list_var(List_var * l, Element e);

void push_list_var(List_var * l, Element e,char type);
void push_list_op(List_op * l, Op * p);
void push_list_str(List_str * l, char * string);

void join_list_op(List_op * l, List_op * p);


void print_list_var(List_var * l);
void print_list_op(List_op * l);
void print_list_str(List_str * l);


Op * create_op(char * cod, char * dst, char * arg1, char * arg2);

char * get_reg();

void free_reg(int i);

char * get_dst(List_op * l);

int get_n_reg(char * t);



#endif
