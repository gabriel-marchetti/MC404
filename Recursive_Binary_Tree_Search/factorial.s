.section .bss
itoa_stack: .space 256
buffer: .space 256

.section .text
.align 2
.global _start
_start:
    la a0, buffer
    jal gets
    jal atoi
    jal fibonacci

    la a1, buffer
    li a2, 10
    jal itoa
    la a0, buffer
    jal puts

    jal exit
###############################################################################
# Description:  Computes the factorial of a number.
# Inputs:
#               a0: argument of factorial (a0)!.
# Outputs:
#               a0: the factorial itself.
###############################################################################
factorial:
    addi sp, sp, -8                 # save registers
    sw a0, 4(sp)
    sw ra, 0(sp)
    li t0, 1                        # temporary variable = 1
    bgt a0, t0, else                # general case of factorial
        li a0, 1                        # base case.
        addi sp, sp, 8                  # restore stack.
        jr ra                   
    else:
        addi a0, a0, -1                 # go-to subcase
        jal  factorial
        lw t1, 4(sp)                    # restore n to t1
        lw ra, 0(sp)                    # restore ra
        addi sp, sp, 8                  # restore stack.
        mul a0, a0, t1                  
        jr ra
###############################################################################
# Description:  Computes the a0-th fibonacci number.
# Inputs:
#               a0: argument of factorial fib(a0)
# Outputs:
#               a0: the fibonacci number itself.
###############################################################################
fibonacci:
    addi sp, sp, -16                     # save register
    sw a0, 4(sp)                        # save current fibonacci number.
    sw ra, 0(sp)                        # save return address.
    li t1, 1                            # for checking base-case.

    bnez a0, 1f
        # Here it equals zero.    
        li a0, 0                        # 0-th base case.
        lw ra, 0(sp)                    # restore return addres.
        addi sp, sp, 16                  # restore stack.
        ret
    1:
    bne a0, t1, 2f 
        # Here it equals one.
        li a0, 1                        # 1-th base case.
        lw ra, 0(sp)                    # restore return address.
        addi sp, sp, 16                 # restore stack.
        ret
    2:
    # Here we have the general case of the fibonacci number.
    add a0, a0, -1
    jal fibonacci
    sw a0, 8(sp)

    lw a0, 4(sp)
    addi a0, a0, -2
    jal fibonacci
    sw a0, 12(sp)

    lw ra, 0(sp)                        # restore return address
    lw t1, 8(sp)                        # load fib(n-1)
    lw t2, 12(sp)                       # load fib(n-2)

    add a0, t1, t2                      # add both numbers.
    addi sp, sp, 16
    ret 
###############################################################################
# Description:  Writes string (terminated with null or new line)
#               pointed by a0 to stdout.
# Inputs:
#               a0: Pointer to String.
# Outputs:
#               None.
###############################################################################
.global puts
puts:
    addi sp, sp, -4                 # allocate space necessary for ra
    sw ra, 0(sp)                    # store ra

    mv s0, a0                       # address of beggining of buffer (index).
    li s1, 0                        # size of buffer in bytes
    mv s6, a0                       # save address

    li t3, 0                        # null char
    1:
    lb t2, 0(s0)
    beq t2, t3, 1f
        addi s0, s0, 1              # go-to next char
        addi s1, s1, 1              # increase buffer size
        j 1b
    1:
    li t2, '\n'
    sb t2, 0(s0)                    # load new-line char at the end of buffer
    addi s1, s1, 1                  # increase size

    mv a1, s6                       # restore address
    mv a2, s1
    li a0, 1
    jal write

    lw ra, 0(sp)
    addi sp, sp, 4
    ret
###############################################################################
# a1: address of buffer.
# a2: size in bytes of buffer.
###############################################################################
.global write
write:
    li a7, 64
    ecall
    ret

###############################################################################
# Description:  get input from stdin.
# Inputs:
#               a0: buffer address.
# Outputs:
#               a0: buffer address with stdin inputs.
###############################################################################
.global gets
gets:
    addi sp, sp, -4     # Salvando conteúdo de RA
    sw ra, 0(sp)

    mv t0, a0               # t0 <- a0 (endereço do buffer a ser preenchido)
    mv s11, a0      
    li t1, '\n'             # t1 <- '/n' para comparação
    li a2, 1                # Número de bytes a serem lidos

    0:
        li a0, 0
        mv a1, t0
        li a2, 1
        jal read            # Lê o stdin
        lbu t2, 0(t0)       # Carrega o caracter que acabou de ser lido no t2
        addi t0, t0, 1      # t0++
        bne t2, t1, 0b      # Volta à label '0' anterior se t2 != '/n'
    li t1, 0  
    sb t1, -1(t0)           # Coloca NULL no final da string

    mv a0, s11

    lw ra, (sp)             # Recuperando conteúdo de RA
    addi sp, sp, 4
    ret
###############################################################################
# Description:  read some stream from specific file-descriptor defined in a0
# Inputs:
#               a0: file descriptor (stdin)
#               a1: address from stream
#               a2: num of bytes
#               a7: syscall read (63)
# Outputs:
#               a0: number of bytes read.
###############################################################################
.global read
read:
    li a7, 63
    ecall
    ret

###############################################################################
# Description:  Get input address with some decimal representation and converts
#               it to a 32-bit signed number.
# Inputs:
#               a0: input stream address.
# Outputs:
#               a0: 32-bit signed number.
###############################################################################
.global atoi
atoi:
    # a0 will hold first non-whitespace character.
    lb t0, 0(a0)
    li t1, '-'
    li t2, 1
    bne t0, t1, 1f          # checks negative sign.
        li t2, -1
        addi a0, a0, 1
    1:
    li t1, 0                # will hold the decimal value.
    li t3, 10               # base-10 number.
    li t5, 0                # checks for null char.
    2:
    lb t0, 0(a0)
    beq t0, t5, 2f          # checks for newline character.
        addi t0, t0, -'0'       # adjust ASCII to decimal.
        mul t1, t1, t3          # shift base-10 number.
        add t1, t1, t0          # sum "unit".
        addi a0, a0, 1          # shift to next char.
        j 2b
    2:
    mul t1, t1, t2              # change sign if negative.
    mv a0, t1
    ret
###############################################################################
# Description:  Gets a number stored at register a0 and store it ASCII represen-
#               tation at buffer a1 with base at a2. String stored will be null
#               terminated.
# Inputs:
#               a0: value.
#               a1: buffer to store the ASCII representation.
#               a2: base.
# Outputs:
#               a0: buffer address.
###############################################################################
.global itoa
itoa:
    addi sp, sp, -4             # alocate space to program stack.
    sw a1, 0(sp)                # store buffer address (used for return).

    # deals with zero-th case, i.e., a0 = 0
    li s5, 0

    la t0, itoa_stack               
    li t5, 0                    # stack size
    bgez a0, 1f
        li t6, -1               # load negative sign
        mul a0, a0, t6          # converts to positive integer.
    1:
    beqz s5, 2f
    beqz a0, 1f
    2:
        addi s5, s5, 1
        rem t2, a0, a2
        li t3, 9
        ble t2, t3, itoa_if
        j itoa_else
        itoa_if:
            # deals with ASCII between '0' and '9'.
            addi t2, t2, '0'        # adjust to ASCII. 
            addi t0, t0, 1          # go-to next free space at the stack. 
            sb t2, 0(t0)            # store byte.
            addi t5, t5, 1          # increase size of stack.
            j itoa_cont 
        itoa_else:
            # deals with ASCII between 'a' and 'f' for hexadecimal.
            addi t2, t2, -10        # adjust 'a' to zero and other character
            addi t2, t2, 'A'        # adjust to ASCII value.
            addi t0, t0, 1          # go-to next free space at the stack.
            sb t2, 0(t0)            # store byte.
            addi t5, t5, 1          # increase size of stack 
            j itoa_cont
        itoa_cont:
        divu a0, a0, a2
        j 1b 
    1:
    # Stack has all elements. Dealing with negative case.
    lw a1, 0(sp)
    bgez t6, 1f     # Deals with negative case.
        li t2, '-'
        sb t2, 0(a1)
        addi a1, a1, 1
    1:              # Deals with other ASCII characters that are numbers.
    lb t1, 0(t0)
    beqz t5, 1f
        sb t1, 0(a1)
        addi a1, a1, 1
        addi t0, t0, -1
        addi t5, t5, -1
        j 1b
    1:
    li t0, 0
    sb t0, 0(a1)

    li t1, 0                # null terminated string.
    sb t1, 0(a1)            # store null-terminated string.
    addi a1, a1, 1          # adjust index.
    lw a0, 0(sp)            # store buffer to a0.
    addi sp, sp, 4          # restore program stack.
    ret
###############################################################################
# Description:  Execute the exit syscall with succeed indicator.
# Inputs:
#               a0: Succeed Indicator
#               a7: Syscall
# Outputs:
#               None.
###############################################################################
.global exit
exit:
    li a7, 93
    ecall