#include "linkedList.h"

void free_list_var(List_var * l) {
	while(l->head!=NULL) {			
		Var aux = l->head;
		l->head = l->head->sig;
		free(aux);
	}
}
void free_list_op(List_op * l) {
	while(l->head!=NULL) {			
		Var aux = l->head;
		l->head = l->head->sig;
		free(aux);
	}
}

int find_list_var(List_var * l, Element e) {
	Var n = l->head;
	while(n!=NULL && strcmp(n->elem,e) != 0) n = n->sig;
	return (n!=NULL);
}

void push_list_var(List_var * l, Element e) {
	Var aux = malloc(sizeof(struct Var));
	strcpy(aux->elem,e);
	aux->sig = NULL;
	if (l->head == NULL) {
		l->head = aux;
		l->tail = aux;
	}	
	else {
		Var aux2 = l->tail;
		aux2->sig = aux;
		l->tail = aux;
	}	

}

void push_list_op(List_op * l, Op * p) {

	p->sig = NULL;
	if (l->head == NULL) {
		l->head = p;
		l->tail = p;
	}	
	else {
		Op * aux2 = l->tail;
		aux2->sig = p;
		l->tail = p;
	}	

}

//L1 and L2 not null
void join_list_op(List_op * l1, List_op * l2) {
	l1->tail->sig = l2->head;
	l1->tail = l2->tail;	
}

void print_list_op(List_op * l1) {
	Op * p = l1->head;
	while(p != NULL) {
		printf("%s %s %s %s\n",p->cod,p->dst,p->arg1,p->arg2);
		p = p->sig;
	}
}

Op * create_op(char * cod, char * dst, char * arg1, char * arg2) {
	Op * p = malloc(sizeof(struct Op));
	strcpy(p->cod,cod);
	strcpy(p->dst,dst);
	strcpy(p->arg1,arg1);
	strcpy(p->arg2,arg2);
	return p;
}
