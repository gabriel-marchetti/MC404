#include <stdio.h>
#include <stdbool.h>

#define MAX_SIZE 150

typedef struct Node{
  int val;
  struct Node *left, *right;
} Node;

typedef struct Stack_node{
  int depth;
  Node *node;
}Stack_node;

typedef struct Stack{
  int top;
  Stack_node *arr[MAX_SIZE];
} Stack;

bool isEmpty(Stack *stack){
  return stack->top == -1;
}

void push(Stack *stack, struct Node* node, int depth){
  Stack_node aux;
  aux.node = node; aux.depth = depth;
  stack->arr[++stack->top] = &aux;
}

Stack_node* pop(Stack *stack){
  if( !isEmpty(stack) ){
    return NULL;
  }
  return stack->arr[stack->top--];
}

int recursive_tree_search(Node *node, int val){
  Stack stack;
  stack.top = -1;

  /* Initial Iteration */  
    
}

int main(){
  int val;
  Node root_node, node_1, node_2, node_3, node_4, node_5, node_6, node_7;

  root_node.val = 12; root_node.left = &node_1; root_node.right = &node_2;
  node_1.val = 5; node_1.left = &node_3; node_1.right = &node_4;
  node_2.val = -78; node_2.left = NULL; node_2.right = &node_5;
  node_3.val = -43; node_3.left = NULL; node_3.right = NULL;
  node_4.val = 361; node_4.left = NULL; node_4.right = NULL;
  node_5.val = 562; node_5.left = &node_6; node_5.right = &node_7;
  node_6.val = 9; node_6.left = NULL; node_6.right = NULL;
  node_7.val = -798; node_7.left = NULL; node_7.right = NULL;

  scanf("Escolha um valor para buscar na arvore: %d\n", &val);
  recursive_tree_search(&root_node, val);

  return 0;
}
