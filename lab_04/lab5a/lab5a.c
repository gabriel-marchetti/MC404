#define STDIN_FD 0
#define STDOUT_FD 1
typedef enum {false, true} bool;

#define getBit(w, i) ( (w >> i) & 1 )

int main();
void print_buffers( char (*split_buffer)[5] );

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
    "li a7, 63           # syscall read code (63) \n"
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
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}
#endif

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

void split_to_buffers(char *buffer, char (*split_buffer)[5], int __n){
  int ibuffer = 0, index_cur_buffer = 0;
  for(int i = 0; i < __n; i++){
    if(buffer[i] == ' '){
      ibuffer++;
      index_cur_buffer = 0;
    } 
    else if(buffer[i] == '\n'){
      break;
    }
    else{
      split_buffer[ibuffer][index_cur_buffer] = buffer[i];
      index_cur_buffer++;
    }
  }
}

bool isdigit_buf(char c){
  if( '0' <= c && c <= '9' )
    return true;
  return false;
}

int convert_to_number(char* buffer){
  int aux = 0;
  bool isNegative = (buffer[0] == '-') ? true : false;
  int start_index = 1, final_index = start_index;
  while( isdigit_buf(buffer[start_index]) ){
    if(final_index >= 5) break;
    final_index++;
  }
  final_index--;
  int base = 1;
  for(int i = final_index; i >= start_index; i--){
    aux += base * ( buffer[i] - '0' );
    base *= 10;
  }
  if(isNegative) aux *= -1;

  return aux;
}

void convert_buffers_to_numbers(int *numbers, char (*split_buffer)[5]){
  //print_buffers(split_buffer);
  for(int i = 0; i < 5; i++){
    numbers[i] = convert_to_number(split_buffer[i]);
  }
}

void initialize_buffer(char (*split_buffer)[5]){
  for(int i = 0; i < 5; i++){
    for(int j = 0; j < 5; j++){
      split_buffer[i][j] = 0;
    }
  }
}

void print_buffers( char (*split_buffer)[5] ){
  char line_breaker[1]; line_breaker[0] = '\n';
  for(int i = 0; i < 5; i++){
    write(STDOUT_FD, split_buffer[i], 5);
    write(STDOUT_FD, line_breaker, 1);
  }
}

int main(){
  char buffer[30];
  char buffer_numbers[5][5];
  initialize_buffer(buffer_numbers);
  int n = read(STDIN_FD, (void *) buffer, 30);
  split_to_buffers(buffer, buffer_numbers, n);
  //print_buffers(buffer_numbers);
  //write(STDOUT_FD, (void *)buffer, n);
  int numbers[5];
  convert_buffers_to_numbers(numbers, buffer_numbers);
  //print_numbers(numbers);
  int answer_number = 0, bit = 0, index = 0;

  for(int i = 0; i <= 2; i++){
    bit = getBit(numbers[0], index++);
    answer_number += (bit << i);
  }
  index = 0;
  for(int i = 3; i <= 10; i++){
    bit = getBit(numbers[1], index++);
    answer_number += (bit << i);
  }
  index = 0;
  for(int i = 11; i <= 15; i++){
    bit = getBit(numbers[2], index++);
    answer_number += (bit << i);
  }
  index = 0;
  for(int i = 16; i <= 20; i++){
    bit = getBit(numbers[3], index++);
    answer_number += (bit << i);
  }
  index = 0;
  for(int i = 21; i <= 31; i++){
    bit = getBit(numbers[4], index++);
    answer_number += (bit << i);
  }
  hex_code(answer_number);

  return 0;
}
