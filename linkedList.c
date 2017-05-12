#include "linkedList.h"

int regs[10] = {0};


List_var * init_list_var(){
	List_var * l = malloc(sizeof(struct List_var));
	l->head=NULL;
	l->tail=NULL;
}

List_op * init_list_op(){
	List_op * l = malloc(sizeof(struct List_op));
	l->head=NULL;
	l->tail=NULL;
}

List_str * init_list_str(){
	List_str * l = malloc(sizeof(struct List_str));
	l->head=NULL;
	l->tail=NULL;
}



void free_list_var(List_var * l) {
	while(l->head!=NULL) {			
		Var * aux = l->head;
		l->head = l->head->sig;
		free(aux);
	}
}

void free_list_op(List_op * l) {
	while(l->head!=NULL) {			
		Op * aux = l->head;
		l->head = l->head->sig;
		free(aux);
	}
}

void free_list_str(List_str * l) {
	while(l->head!=NULL) {			
		Str * aux = l->head;
		l->head = l->head->sig;
		free(aux->str);
		free(aux);
	}
}


Var * find_list_var(List_var * l, Element e) {
	Var * n = l->head;
	int i = 0;
	while(n!=NULL && strcmp(n->elem,e) != 0) {
		n = n->sig;
		i++;
	} 
	
	return n;
}

void push_list_var(List_var * l, Element e, char type) {
	Var * aux = malloc(sizeof(struct Var));
	strcpy(aux->elem,e);
	aux->type = type;
	aux->sig = NULL;

	if (l->head == NULL) {
		l->head = aux;
		l->tail = aux;
	}	
	else {
		Var * aux2 = l->tail;
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

void push_list_str(List_str * l, char * string) {
	Str * aux = malloc(sizeof(struct Str));
	aux->str = strdup(string);
	aux->sig = NULL;

	if (l->head == NULL) {
		l->head = aux;
		l->tail = aux;
	}	
	else {
		Str * aux2 = l->tail;
		aux2->sig = aux;
		l->tail = aux;
	}
}


void join_list_op(List_op * l1, List_op * l2) {
	
	if (l1->head == NULL) {
		l1->head = l2->head;
		l1->tail = l2->tail;
	}
	else if (l2->head != NULL) {
		l1->tail->sig = l2->head;
		l1->tail = l2->tail;
	}
	
	free(l2);
}

void print_list_op(List_op * l) {
	Op * p = l->head;
	while(p != NULL) {
		if (p->cod[0] == 'j') //jump
			printf("%s",p->cod);
		else {
				printf("\t");
				printf("%s",p->cod);
			if (p->dst[0] != '\0')
				printf(" %s",p->dst);
			
			if (p->arg1[0] != '\0')
				printf(", %s",p->arg1);

			if (p->arg2[0] != '\0')
				printf(", %s",p->arg2);
		}
		printf("\n");
		p = p->sig;
	}
}

void print_list_var(List_var * l) {
	Var * p = l->head;
	while(p != NULL) {
			printf("_%s: .word 0\n",p->elem);
		p = p->sig;
	}
}

void print_list_str(List_str * l) {
	Str * p = l->head;
	for(int i = 0; p != NULL; i++) {
		printf("$str_%d:\n\t.asciiz %s\n",i,p->str);
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


char * get_reg() {
	int i = 0;
	int r = 10;
	for (; i<10;i++)
		if (!regs[i]) {
			r = i;
			regs[i]=1;
			break;
		}
	char * ret = malloc(sizeof(char)*4);
	sprintf(ret, "$t%d", r);
	return ret;
}

void free_reg(int i) {
	regs[i] = 0;
}

char * get_dst(List_op * l) {
	return l->tail->dst;
}

int get_n_reg(char * t) {
	return t[2]-'0';
}
