#define STDIN_FD 0
#define STDOUT_FD 1

#ifdef LOCALEXEC
#include <unistd.h>
#include <stdlib.h>
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

void _start(){
  int ret_code = main();
  exit(ret_code);
}
#endif

typedef enum {false, true} bool;

// Function declaration.
int main();
int abs(int num);

int abs(int num){
  if( num < 0 ) return num * -1;
  return num;
}

char digitToChar(int digit){
  return (char) digit + 48; 
}

char table[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
int convertHexToDec(char *buf, int n){
  int storedValue = 0;
  int base = 1;

  int k = 0;
  for(int i = n - 2; i >= 0; --i){
    for(k = 0; k < 16; ++k){
      if(buf[i] == table[k]) break;
    } 

    storedValue += base * k;
    base *= 16;
  }

  return storedValue;
}

int convertDecStrToDec(char *buf, int n){
  int storedValue = 0;
  int base = 1;

  int k = 0;
  for(int i = n - 2; i >= 0; --i){
    for(k = 0; k < 10; ++k){
      if(buf[i] == table[k]) break;
    } 

    storedValue += base * k;
    base *= 10;
  }

  return storedValue;
}

void convertDecToC2(int readValue, char *globalBuffer){
  char buf[32 + 3]; // +3 due to '\n', '0b';
  buf[0] = '0';
  buf[1] = 'b';
  buf[2] = (readValue < 0) ? '1': '0'; 
  buf[32 + 3 - 1] = '\n'; // -1 due to 0-index, note that 32 + 3 equals total size.
  int absValue = abs(readValue);
  int currentIndex = 32 - 1; // This is the LSB.

  int remainder = 0; 
  int quotient = (readValue < 0) ? absValue - 1 : absValue;
  while(true){
    remainder = readValue % 2;
    buf[currentIndex] = digitToChar(remainder);
    currentIndex--;  
    quotient = quotient / 2;
    if(quotient == 0) break;
  }

  globalBuffer = buf;
} 

int main(){
  char buf[20];
  int n = read(STDIN_FD, buf, 20);

  bool isHexadecimal = (buf[0] == '0' && buf[1] == 'x'); 
  bool isNegative = (buf[0] == '-');

  int readValue = 0;
  switch (isHexadecimal) {
    case false:
      readValue = convertHexToDec(buf, n);
      break;
    case true:
      readValue = convertDecStrToDec(buf, n);
      if(isNegative) readValue *= -1;
      break;
    default:
      break;
  } 
  
  char *c2_number, *dec_number, *hex_number, *unsigned_number;
  convertDecToC2(readValue, c2_number);
  write(STDOUT_FD, c2_number, n);

  write(STDOUT_FD, buf, n);

  return 0;
}
