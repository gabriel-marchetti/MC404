#include <stdio.h>
#define MASK(j) (1 << j)
#define getBit(w, i) ((w >> i) & 1)

typedef enum {false, true} bool;
/**
  * tmp: Store temporary sum.
  * cin: Carry In.
  * cout: Carry Out.
  */
int sum(int x, int y){
  int tmp = 0, cin = 0, cout = 0, bit = 0;
  int j = 0;
  while( true ){
    if( j > 31 ) break;
    cin = cout;
    bit = ( (x >> j) ^ (y >> j) ^ cin ) & 1; 
    cout = ((x >> j) & (y >> j)) | ( ((x >> j) ^ (y >> j)) & cin );
    tmp = tmp + (bit << j);
    j++;
  }

  return tmp;
}

int getBitFunc(int w, unsigned j){
  return ( (w & ( 1 << MASK(j)) ) == 0 ) ? 0 : 1;
}

void printBinary(int w){
  for(int i = 31; i >= 0; i--){
    printf("%d", getBit(w, i));
  }
  printf("\n");
}

int main(){
  int x, y;
  //scanf("%d + %d", &x, &y);
  //printf("%d\n", sum(x, y));

  printBinary(20);
  printBinary(30);
  printBinary(40);
  printBinary(761);
  printBinary(-10);

  return 0;
}
