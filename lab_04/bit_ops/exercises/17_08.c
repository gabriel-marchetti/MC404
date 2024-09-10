#include <stdio.h> 

typedef enum {false, true} bool;

bool isPowerOfTwo(unsigned a){
  unsigned short num_ones = 0;
  for(int i = 0; i < 32; i++){
    if( a & 1 ) num_ones++;
    a >>= 1; 
  }

  if(num_ones == 1) return true;
  return false;
}

int main(){
  unsigned x;
  scanf("%d", &x);
  printf("isPowerOfTwo: %d\n", isPowerOfTwo(x));

  return 0;
}
