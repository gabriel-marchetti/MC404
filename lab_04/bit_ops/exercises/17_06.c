#include <stdio.h> 

unsigned short int multiplicationBits(unsigned short int x, unsigned short int y){
  unsigned short int acc = 0, current_bit = 0;

  while( current_bit < 16 ){
      if( y & 1 ){
      //printf("x: %hu y: %hu\n", x, y);
      acc += x;
    }
    y >>= 1;
    x <<= 1;
    current_bit++;
  }

  return acc;
}

int main(){
  unsigned short int x, y;
  scanf("%hu x %hu", &x, &y);

  printf("result: %hu\n", multiplicationBits(x, y));

  return 0;
}
