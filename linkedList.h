#ifndef INFO_H_HEADER_
#define INFO_H_HEADER_
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef char * Element;

typedef struct List_var List_var;
typedef struct Var * Var;
typedef struct List_op List_op;
typedef struct Op Op;


struct Op {
	char cod[8];
	char dst[4];
	char arg1[10];
	char arg2[10];
	Op * sig;
};

struct Var
{
	char elem[17];
	Var sig;
};

struct List_var
{
	Var head;
	Var tail;
};

struct List_op
{
	Op * head;
	Op * tail;
};

void free_list_var(List_var * l);
void free_list_op(List_op * l);

int find_list_var(List_var * l, Element e);

void push_list_var(List_var * l, Element e);
void push_list_op(List_op * l, Op * p);

void join_list_op(List_op * l, List_op * p);


void print_list_var(List_var * l);
void print_list_str(List_var * l);
void print_list_op(List_op * l);


Op * create_op(char * cod, char * dst, char * arg1, char * arg2);

char * get_reg();

void free_reg(int i);

char * get_dst(List_op * l);

int get_n_reg(char * t);

#endif
