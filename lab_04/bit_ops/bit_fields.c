#include <stdio.h>
#define MASK(j) (1 << j)

struct Flags{
  unsigned leading : 3;
  unsigned flag1 : 1;
  unsigned flag2 : 1;
  unsigned trailing : 11;
};

int getBit(int w, unsigned j){
  return ( (w & MASK(j)) ) ? 1 : 0;
}

void printFlags(struct Flags flags){
  printf("leading: ");
  for(int i = 0; i <= 2; i++)
    printf("%d", getBit(flags.leading, i));
  printf(" ");
  printf("%d", getBit(flags.flag1, 0));
  printf(" ");
  printf("%d", getBit(flags.flag2, 0));
  printf(" ");
  for(int i = 0; i <= 11; i++)
    printf("%d", getBit(flags.trailing, i));
  printf("\n");
}

int main(){
  struct Flags flags;
  flags.leading = 5;
  flags.flag1 = 1;
  flags.flag2 = 0;
  flags.trailing = 28;
  printFlags(flags);

  for(int i = 0; i <= 15; i++){
    printf("%d", getBit(flags.trailing, i));
  }
  printf("\n");

  return 0;
}
