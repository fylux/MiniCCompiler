#include "linkedList.h"

void free_list(List * l) {
	while(l->head!=NULL) {			
		Node aux = l->head;
		l->head = l->head->sig;
		free(aux);
	}
}
int find_list(List * l, Element e) {
	Node n = l->head;
	while(n!=NULL && n->elem != e) n = n->sig;
	return (n!=NULL);
}

void push_list(List * l, Element e) {
	Node aux = malloc(sizeof(struct Node));
	aux->elem = e;
	aux->sig = NULL;
	if (l->head == NULL) {
		l->head = aux;
		l->tail = aux;
	}	
	else {
		Node aux2 = l->tail;
		aux2->sig = aux;
		l->tail = aux2;
	}	

}
