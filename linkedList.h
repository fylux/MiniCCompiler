#include <stdlib.h>

typedef int Element;

typedef struct List List;
typedef struct Node * Node;

struct Node
{
	Element elem;
	Node sig;
};

struct List
{
	Node head;
	Node tail;
};

void free_list(List * l);

int find_list(List * l, Element e);

void push_list(List * l, Element e);


