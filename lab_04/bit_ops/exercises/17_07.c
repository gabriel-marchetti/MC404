#include <stdio.h> 
#define MASK(j) (1 << j)

void setBits(unsigned *w, unsigned short i, unsigned short j, unsigned short value){
  if(i < 0 || j < 0){
    printf("O índice não pode ser negativo\n");
    return;
  }
  if(i > 31 || j > 31){
    printf("O índice não pode ser maior que 31\n");
    return;
  }
  if(i > j){
    // i = 2 && j = 3
    i = i + j;
    // i = 5 && j = 3
    j = i - j;
    // i = 5 && j = 2
    i = i - j;
    // i = 3 && j = 2
  }

  unsigned aux = *w;
  for(int k = i; k <= j; k++){
    if(value == 0){
      aux = aux & MASK(k); 
    }
    else{
      aux = aux | MASK(k);
    }
  }

  *w = aux;
}

int main(){
  unsigned w = 0;
  setBits(&w, 0, 3, 1);
  printf("w: %u\n", w);
  setBits(&w, 0, 3, 0);
  printf("w: %u\n", w);
  

  return 0;
}
