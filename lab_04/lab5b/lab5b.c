// Enum of possible instruction types
typedef enum InstType { R, I, S, B, U, J} InstType;

// Struct with instruction data
typedef struct InstData {
    int opcode,
        rd,
        rs1,
        rs2,
        imm,
        funct3,
        funct7;
    InstType type;
} InstData;

#ifdef LOCALEXEC
#include <unistd.h>
#include <stdlib.h>
#else
int main();
// read function.
// Parameters: 
//    - __fd: file descriptor.
//    - __buff: destination buffer address.
//    - __n: number of bytes to read.
//
// Returns: number of bytes read 
int read(int __fd, const void *__buf, int __n){
  int bytes;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read (63) \n"
    "ecall \n"
    "mv %0, a0"
    : "=r"(bytes)
    :"r"(__fd), "r"(__buf), "r"(__n)
    : "a0", "a1", "a2", "a7"
  );
  return bytes;
}

// write function.
// Parameters: 
//    - __fd: file descriptor.
//    - __buff: source buffer address.
//    - __n: number of bytes to write.
//
// Returns: (nothing)
void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :
    :"r"(__fd), "r"(__buf), "r"(__n)
    : "a0", "a1", "a2", "a7"
  );
}

// exit function.
// Parameters: 
//    - code: exit code.
//
// Returns: (nothing)
void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :
    :"r"(code)
    : "a0", "a7"
  );
}

void _start(){
    int ret_code = main();
    exit(ret_code);
}
#endif

// Receives an int value and then display its hexadecimal representation in STDOUT.
// Parameters: 
//    - val: value to convert to hexadecimal representaion and display.
//
// Returns: (nothing)
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

// Compares the first n_char characters of two strings.
// Parameters: 
//    - str1: first string.
//    - str2: second string.
//    - n_char: number of chars to compare.
//
// Returns: 
//   0 if the strings are equal, 
//   1 if str1 is greater than str2 
//  -1 if str1 is lesser than str2
int strcmp_custom(char *str1, char *str2, int n_char){
    for (int i = 0; i < n_char; i++){
        if (str1[i] < str2 [i])
            return -1;
        else if (str1[i] > str2 [i])
            return 1;
    }    
    return 0;
}

// Reads a string of characters representing a number in decimal base from a buffer, converts to int and updates the number of chars read from the buffer.
// Parameters: 
//    - buffer: buffer address.
//    - read_chars: pointer to variable to be updated with the number of chars read form the buffer.
//
  // Returns: int value computed from the buffer. 
int dec_to_int(char buffer[], int *read_chars){
    int neg = 0, val = 0, curr;
    if (buffer[0] == '-')
        neg = 1;

    curr = neg;
    while(buffer[curr] >= '0' && buffer[curr] <= '9'){
        val = val*10;
        val = val + buffer[curr] - '0';
        curr++;
    }
    if (neg == 1)
        val = -val;
    *read_chars += curr + 1;
    return val;
}

// Gets the register id from a buffer and updates the number of chars read.
// Parameters: 
//    - buffer: buffer address.
//    - read_chars: pointer to variable to be updated with the number of chars read form the buffer.
//
// Returns: Register id 
int get_register(char buffer[], int *read_chars){
    int curr = 0;
    while (buffer[curr] != 'x'){
        curr++;
    }
    curr++;
    *read_chars += curr;
    return dec_to_int(&buffer[curr], read_chars);
}

// Gets the immediate value from a buffer and updates the number of chars read.
// Parameters: 
//    - buffer: buffer address.
//    - read_chars: pointer to variable to be updated with the number of chars read form the buffer .
//
// Returns: Immediate value
int get_immediate(char buffer[], int *read_chars){
    int curr = 0;

    while (!((buffer[curr] >= '0' && buffer[curr] <= '9') ||  buffer[curr] == '-')){
        curr++;
    }
    *read_chars += curr;
    return dec_to_int(&buffer[curr], read_chars);
}

// Parsing of instruction with format rd_imm.
// Parameters: 
//    - buffer: buffer address.
//    - rd: pointer to variable associated with destination register.
//    - imm: pointer to variable associated with immediate.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void rd_imm(char buffer[], int *rd, int *imm, int start){
    *rd = get_register(&buffer[start], &start);
    *imm = get_immediate(&buffer[start], &start);
}

// Parsing of instruction with format r1_r2_imm.
// Parameters: 
//    - buffer: buffer address.
//    - r1: pointer to variable associated with register 1.
//    - r2: pointer to variable associated with register 2.
//    - imm: pointer to variable associated with immediate.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void r1_r2_imm(char buffer[], int *r1, int *r2, int *imm, int start){
    *r1 = get_register(&buffer[start], &start);
    *r2 = get_register(&buffer[start], &start);
    *imm = get_immediate(&buffer[start], &start);
}

// Parsing of instruction with format r1_imm_r2.
// Parameters: 
//    - buffer: buffer address.
//    - r1: pointer to variable associated with register 1.
//    - r2: pointer to variable associated with register 2.
//    - imm: pointer to variable associated with immediate.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void r1_imm_r2(char buffer[], int *r1, int *r2, int *imm, int start){
    *r1 = get_register(&buffer[start], &start);
    *imm = get_immediate(&buffer[start], &start);
    *r2 = get_register(&buffer[start], &start);
}

// Parsing of instruction with format r1_r2_r3.
// Parameters: 
//    - buffer: buffer address.
//    - r1: pointer to variable associated with register 1.
//    - r2: pointer to variable associated with register 2.
//    - r3: pointer to variable associated with register 3.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void r1_r2_r3(char buffer[], int *r1, int *r2, int *r3, int start){
    *r1 = get_register(&buffer[start], &start);
    *r2 = get_register(&buffer[start], &start);
    *r3 = get_register(&buffer[start], &start);
}

// Parses a string with a RISC-V instruction and fills an InstData struct with the instruction's data.
// Parameters: 
//    - inst: instruction string.
//    - data: pointer to InstData struct.
//
// Returns: (nothing)
void get_inst_data(char inst[], InstData *data){
    int opcode = 0,
        rd = 0,
        rs1 = 0,
        rs2 = 0,
        imm = 0,
        funct3 = 0,
        funct7 = 0;
    InstType type = I;
    if (strcmp_custom(inst, "lui", 3) == 0){
        // lui rd, IMM
        // OPCODE = 0110111 = 55
        rd_imm(inst, &rd, &imm, 3);
        opcode = 55, type = U;
    } else if (strcmp_custom(inst, "auipc ", 6) == 0){
        // auipc rd, IMM
        // OPCODE = 0010111 = 23
        rd_imm(inst, &rd, &imm, 5);
        opcode = 23, type = U;
    } else if (strcmp_custom(inst, "jal ", 4) == 0){
        // jal rd, IMM
        // OPCODE = 1101111 = 111
        rd_imm(inst, &rd, &imm, 3);
        opcode = 111, type = J;
    } else if (strcmp_custom(inst, "jalr ", 5) == 0){
        // jalr rd, IMM(rs1)
        // OPCODE = 1100111 = 103  FUNCT3 = 0
        r1_imm_r2(inst, &rd, &rs1, &imm, 4);
        opcode = 103, type = I;
    } else if (strcmp_custom(inst, "beq ", 4) == 0){
        // beq rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 0
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, type = B;
    } else if (strcmp_custom(inst, "bne ", 4) == 0){
        // bne rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 1
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, funct3 = 1, type = B;
    } else if (strcmp_custom(inst, "blt ", 4) == 0){
        // blt rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 4
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, funct3 = 4, type = B;
    } else if (strcmp_custom(inst, "bge ", 4) == 0){
        // bge rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 5
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, funct3 = 5, type = B;
    } else if (strcmp_custom(inst, "bltu ", 5) == 0){
        // bltu rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 6
        r1_r2_imm(inst, &rs1, &rs2, &imm, 4);
        opcode = 99, funct3 = 6, type = B;
    } else if (strcmp_custom(inst, "bgeu ", 5) == 0){
        // bgeu rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 7
        r1_r2_imm(inst, &rs1, &rs2, &imm, 4);
        opcode = 99, funct3 = 7, type = B;
    } else if (strcmp_custom(inst, "lb ", 3) == 0){
        // lb rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 0
        r1_imm_r2(inst, &rd, &rs1, &imm, 2);
        opcode = 3;
    } else if (strcmp_custom(inst, "lh ", 3) == 0){
        // lh rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 1
        r1_imm_r2(inst, &rd, &rs1, &imm, 2);
        opcode = 3, funct3 = 1;
    } else if (strcmp_custom(inst, "lw ", 3) == 0){
        // lw rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 2
        r1_imm_r2(inst, &rd, &rs1, &imm, 2);
        opcode = 3, funct3 = 2;
    } else if (strcmp_custom(inst, "lbu ", 4) == 0){
        // lbu rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 4
        r1_imm_r2(inst, &rd, &rs1, &imm, 3);
        opcode = 3, funct3 = 4;
    } else if (strcmp_custom(inst, "lhu ", 4) == 0){
        // lhu rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 5
        r1_imm_r2(inst, &rd, &rs1, &imm, 3);
        opcode = 3, funct3 = 5;
    } else if (strcmp_custom(inst, "sb ", 3) == 0){
        // sb rs2, IMM(rs1)
        // OPCODE = 0100011 = 35 FUNCT3 = 0
        r1_imm_r2(inst, &rs2, &rs1, &imm, 2);
        opcode = 35, type = S;
    } else if (strcmp_custom(inst, "sh ", 3) == 0){
        // sh rs2, IMM(rs1)
        // OPCODE = 0100011 = 35 FUNCT3 = 1
        r1_imm_r2(inst, &rs2, &rs1, &imm, 2);
        opcode = 35, funct3 = 1, type = S;
    } else if (strcmp_custom(inst, "sw ", 3) == 0){
        // sw rs2, IMM(rs1)
        // OPCODE = 0100011 = 35 FUNCT3 = 2
        r1_imm_r2(inst, &rs2, &rs1, &imm, 2);
        opcode = 35, funct3 = 2, type = S;
    } else if (strcmp_custom(inst, "addi ", 5) == 0){
        // addi rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 0
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19;
    } else if (strcmp_custom(inst, "slti ", 5) == 0){
        // slti rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 2
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 2;
    } else if (strcmp_custom(inst, "sltiu ", 6) == 0){
        // sltiu rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 3
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 3;
    } else if (strcmp_custom(inst, "xori ", 5) == 0){
        // xori rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 4 
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 4;
    } else if (strcmp_custom(inst, "ori ", 4) == 0){
        // ori rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 6
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 6;
    } else if (strcmp_custom(inst, "andi ", 5) == 0){
        // andi rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 7
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 7;
    } else if (strcmp_custom(inst, "slli ", 5) == 0){
        // slli rd, rs1, shamt
        // OPCODE = 0010011 = 19 FUNCT3 = 1
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, imm = imm%32, funct3 = 1;
    } else if (strcmp_custom(inst, "srli ", 5) == 0){
        // srli rd, rs1, shamt
        // OPCODE = 0010011 = 19 FUNCT3 = 5
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, imm = imm%32, funct3 = 5;
    } else if (strcmp_custom(inst, "srai ", 5) == 0){
        // srai rd, rs1, shamt
        // OPCODE = 0010011 = 19 FUNCT3 = 5
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, imm = imm%32 + 1024, funct3 = 5, funct7 = 32;
    } else if (strcmp_custom(inst, "add ", 4) == 0){
        // add rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 0  FUNCT7 = 0 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, type = R;
    } else if (strcmp_custom(inst, "sub ", 4) == 0){
        // sub rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 0  FUNCT7 = 32 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct7 = 32, type = R;
    } else if (strcmp_custom(inst, "sll ", 4) == 0){
        // sll rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 1  FUNCT7 = 0 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 1, type = R;
    } else if (strcmp_custom(inst, "slt ", 4) == 0){
        // slt rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 2  FUNCT7 = 0 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 2, type = R;
    } else if (strcmp_custom(inst, "sltu ", 5) == 0){
        // sltu rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 3  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 4);
        opcode = 51, funct3 = 3, type = R;
    } else if (strcmp_custom(inst, "xor ", 4) == 0){
        // xor rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 4  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 4, type = R;
    } else if (strcmp_custom(inst, "srl ", 4) == 0){
        // srl rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 5  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 5, type = R;
    } else if (strcmp_custom(inst, "sra ", 4) == 0){
        // sra rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 5  FUNCT7 = 32  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 5, funct7 = 32, type = R;
    } else if (strcmp_custom(inst, "or ", 3) == 0){
        // or rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 6  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 2);
        opcode = 51, funct3 = 6, type = R;
    } else if (strcmp_custom(inst, "and ", 4) == 0){
        // and rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 7  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 7, type = R;
    }
    data->opcode = opcode;
    data->rd = rd;
    data->rs1 = rs1;
    data->rs2 = rs2;
    data->imm = imm;
    data->funct3 = funct3;
    data->funct7 = funct7;
    data->type = type;
    return;
}

#define getBit(w, i) ( (w >> i) & 1 )

int unpack(InstData data){
  InstType type = data.type;
  int unpacked_data = 0, index = 0, bit = 0, flag = -1;

  if( type == R ){
    flag = 1;
    for(int i = 0; i <= 6; i++){
      bit = getBit(data.opcode, i);  
      unpacked_data += (bit << index);
      index++;
    }
    for(int i = 0; i <= 4; i++){
      bit = getBit(data.rd, i);  
      unpacked_data += (bit << index);
      index++;
    }
    for(int i = 0; i <= 2; i++){
      bit = getBit(data.funct3, i);  
      unpacked_data += (bit << index);
      index++;
    }
    for(int i = 0; i <= 4; i++){
      bit = getBit(data.rs1, i);  
      unpacked_data += (bit << index);
      index++;
    }
    for(int i = 0; i <= 4; i++){
      bit = getBit(data.rs2, i);  
      unpacked_data += (bit << index);
      index++;
    }
    for(int i = 0; i <= 5; i++){
      bit = getBit(data.funct7, i);  
      unpacked_data += (bit << index);
      index++;
    }
  }
  else if( type == I ){
    flag = 1;

  }
  else if( type == S ){
    flag = 1;

  }
  else if( type == B ){
    flag = 1;

  }
  else if( type == U ){
    flag = 1;

  }
  else if( type == B ){
    flag = 1;

  }

  if(flag == -1){
    char error_buffer[] = "No type found unpacking data.\n";
    write(1, error_buffer, 31);
  }
}

void printInstData(InstData data){
  printf("Type: %c\n", data.type);
  printf("OpCode: %d\n", data.opcode);
  printf("rs1: %d\n", data.rs1);
  printf("rs2: %d\n", data.rs2);
  printf("rd: %d\n", data.rd);
  printf("imm: %d\n", data.imm);
  printf("func3: %d\n", data.funct3);
  printf("func7: %d\n", data.funct7);
}

int main()
{
    /*
        Use the provided functions and the previously implemented pack function to pack the contents
        of a RISC-V instruction on a single int variable, paying attention to each instruction's
        particularities and print the final result using the hex_code function.
    */
  char buffer[40];
  InstData data;
  int n = read(0, buffer, 40);
  get_inst_data(buffer, &data);

  printInstData(data);

  hex_code(unpack(data));

  return 0;
}
