#include <stdio.h>
#define MASK(j) (1 << j)

void printOctal(unsigned x){
  unsigned short tmp, base;

  for(int i = 0; i <= 10; i++){
    tmp = 0;
    base = 1;
    for(int j = 0; j < 3; j++){
      tmp += (x & 1) * base;
      x >>= 1;
      base *= 2;
    }
    printf("%d", tmp);
  }

  printf("\n");
}

void printHexadecimal(unsigned x){
  unsigned short tmp, base;

  for(int i = 0; i <= 7; i++){
    tmp = 0;
    base = 1;
    for(int j = 0; j < 4; j++){
      tmp += (x & 1) * base;
      x >>= 1;
      base *= 2;
    }

    if(tmp >= 0 && tmp <= 9){
      printf("%c", '0' + tmp);
    }
    else{
      printf("%c", 'A' + tmp - 10);
    }
  }

  printf("\n");
}

int main(){
  unsigned x;
  scanf("%d", &x);
  printf("Octal: "); printOctal(x);
  printf("Hexadecimal: "); printHexadecimal(x);

  return 0;
}
