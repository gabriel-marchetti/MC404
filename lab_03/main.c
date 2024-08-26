#define STDIN_FD 0
#define STDOUT_FD 1
typedef enum {false, true} bool;

#ifdef LOCALEXEC
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#else
int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

// Function declaration.
int main();
int abs(int num);



void _start(){
  int ret_code = main();
  exit(ret_code);
}
#endif


int abs(int num){
  if( num < 0 ) return num * -1;
  return num;
}

int readDecimal(char buf[20], int n){
  int tmp = 0;
  int base = 1;
  int lsd_pos = n - 1; // Least-Significant Bit position;
  while( true ){
    if(lsd_pos < 0)
      break;
    if(buf[lsd_pos] >= '0' && buf[lsd_pos] <= '9'){
      tmp += (buf[lsd_pos] - '0') * base;
      base *= 10;
    }
    lsd_pos--;
  } 
 
  return tmp;
}

void printBuffer(char buf[20], int n){
  for(int i = 0; i < n; ++i){
    printf("%c", buf[i]);
  }
  printf("\n");
}

int readHexadecimal(char buf[20], int n){
  int tmp = 0;
  int lsd_pos = n-1;
  int base = 1;

  //printBuffer(buf, n);
  while(true){
    if(lsd_pos < 0)
      break;
    if(buf[lsd_pos] >= '0' && buf[lsd_pos] <= '9'){
      tmp += (buf[lsd_pos] - '0') * base;
      base *= 16;
    }
    if(buf[lsd_pos] >= 'A' && buf[lsd_pos] <= 'E'){
      tmp += (10 + buf[lsd_pos] - 'A') * base;
      base *= 16;
    }
    lsd_pos--;
  }

  return tmp;
}

void store_two_complement(char buf[32+3], int readValue){
  
}

void store_decimal(char *buf, int readValue){
  char aux_buf[20];
  int buf_index = 0;
  if(readValue < 0){
    buf[0] = '-';
    buf_index = 1;
  }
  readValue = abs(readValue);

  int size_num = 0;
  while(readValue){
    aux_buf[size_num] = readValue % 10;
    readValue /= 10;
    size_num++;
  }
  
  while(size_num){
    buf[buf_index] = aux_buf[size_num];
    size_num--;
    buf_index++;
  }
}

int main(){
  char buf[20];
  int n = read(STDIN_FD, buf, 20);

  bool isHexadecimal = (buf[0] == '0' && buf[1] == 'x'); 
  bool isNegative = (buf[0] == '-');

  int readValue = 0;
  switch (isHexadecimal) {
    case false:
      readValue = readDecimal(buf, n); 
      if(isNegative) readValue *= -1;
      break;
    case true:
      readValue = readHexadecimal(buf, n);
      break;
    default:
      break;
  } 
  char two_complement_buf[32+3]; // +3 Due to "Ob" at the beggining and "\n" at the end
  char decimal_buf[20]; // 20 is enough
  char hexadecimal_buf[8+3];
  char decimal_buf_swapped_endianess[20];

  printf("%d\n", readValue);


  return 0;
}
