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
    printf("%2c ", buf[i]);
  }
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

int store_two_complement(char buf[32+3], int readValue){
  buf[0] = '0'; buf[1] = 'b';
  if(readValue == 0){
    buf[2] = '0';
    buf[3] = '\n';
    return 4;
  }

  unsigned int aux_binary_number;
  if(readValue < 0){
    aux_binary_number = ~(abs(readValue)) + 1;
  }
  else{
    aux_binary_number = readValue;
  }

  char aux_buf[32];
  int current_bit = 0, aux_buf_index = 0, buf_index = 2;
  while(aux_binary_number){
    current_bit = (aux_binary_number & 1) + '0';
    aux_buf[aux_buf_index++] = current_bit;
    aux_binary_number >>= 1;
  } 
  
  while(aux_buf_index){
    buf[buf_index++] = aux_buf[--aux_buf_index];
  }
  buf[buf_index++] = '\n';

  return buf_index;
}

int store_decimal(char *buf, int readValue){
  char aux_buf[20];
  int buf_index = 0;
  if(readValue == 0){
    buf[0] = '0';
    buf[1] = '\n';
    return 1;
  }
  if(readValue < 0){
    buf[0] = '-';
    buf_index = 1;
  }

  int size_num = 0;
  unsigned int aux_readValue = abs(readValue);
  while(aux_readValue){
    aux_buf[size_num++] = aux_readValue % 10;
    aux_readValue /= 10;
  }
  
  while(size_num){
    buf[buf_index++] = aux_buf[--size_num] + '0';
  }
  buf[buf_index++] = '\n';

  return buf_index; 
}

int store_hexadecimal(char *hex_buf, char *bin_buf, int bin_size){
  int counter = 0;
  int value_hex_bit = 0, hex_buf_index = 2, aux_hex_buf_index = 0, base = 1;
  char aux_hex_buf[8];

  hex_buf[0] = '0'; hex_buf[1] = 'x';
  //printf("------------------------------\n");
  //for(int i = 0; i < bin_size - 1; i++)
  //  printf("%2d ", i);
  //printf("\n");
  //printBuffer(bin_buf, bin_size);

  //printf("bin_size: %d\n", bin_size);
  for(int i = bin_size - 2; i >= 2; i--){
    value_hex_bit += (bin_buf[i] - '0') * base; 
    base *= 2;

    if( (counter+1) % 4 == 0 ){
      aux_hex_buf[aux_hex_buf_index++] = value_hex_bit;
      value_hex_bit = 0;
      base = 1;
    }
    counter++;
  } 
  if(counter % 4 != 0){
    aux_hex_buf[aux_hex_buf_index++] = value_hex_bit; 
  }

  while(aux_hex_buf_index)
    hex_buf[hex_buf_index++] = aux_hex_buf[--aux_hex_buf_index];

  // Convert to ASCII.
  int value;
  for(int i = 2; i < hex_buf_index; i++){
    value = hex_buf[i]; 
    if( value >= 0 && value <= 9 )
      hex_buf[i]+= '0';
    if( value >= 10 && value <= 15){
      hex_buf[i] = hex_buf[i] - 10 + 'a';
    }
  }
  
  hex_buf[hex_buf_index++] = '\n';
  return hex_buf_index;
}

int store_swap_endianess(char *swap_end_buf, char *bin_buf, int bin_size){
  char aux_bin_buf[32];
  int aux_index = 0, size_aux_buf;
  //for(int i = 0; i < bin_size - 1; i++)
  //  printf("%2d ", i);
  //printf("\n");
  //printBuffer(bin_buf, bin_size);
  //printf("bin_size: %d\n", bin_size);

  size_aux_buf = 0;
  for(int i = bin_size - 2; i >= 2; i--){
    aux_bin_buf[aux_index++] = bin_buf[i];
    size_aux_buf++;
  } 
  //printf("%d\n", size_aux_buf);
  //printBuffer(aux_bin_buf, bin_size - 1);
  
  unsigned int uns_decimal = 0;
  int group = 1;
  for(int i = 0; i < size_aux_buf; i++){
    if( i % 4 == 0 )
      group++;
    uns_decimal += (aux_bin_buf[i] - '0') << ( group * 4 - ((i % 4) + 1) );
  }
  printf("%d\n", uns_decimal);


  return 0;
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

  int n_two_complement = store_two_complement(two_complement_buf, readValue);
  write(STDOUT_FD, two_complement_buf, n_two_complement);

  int n_decimal = store_decimal(decimal_buf, readValue);
  write(STDOUT_FD, decimal_buf, n_decimal);

  int n_hexadecimal = store_hexadecimal(hexadecimal_buf, two_complement_buf, n_two_complement);
  write(STDOUT_FD, hexadecimal_buf, n_hexadecimal);

  int n_swapped_endianess = store_swap_endianess(decimal_buf_swapped_endianess, two_complement_buf, n_two_complement);
  write(STDOUT_FD, decimal_buf_swapped_endianess, n_swapped_endianess);


  return 0;
}
