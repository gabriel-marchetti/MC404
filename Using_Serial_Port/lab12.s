.section .bss
buffer: .space 512
itoa_stack: .space 256

.section .data
.align 2
WRITE_STATUS_REG: .word 0xFFFF0100
WRITE_BYTE_REG:   .word 0xFFFF0101
READ_STATUS_REG:  .word 0xFFFF0102
READ_BYTE_REG:    .word 0xFFFF0103
buffer_size: .half 512

.section .text
.align 2
.global _start
_start:
    la a0, buffer
    la t0, buffer_size
    lhu a1, buffer_size
    jal read

    jal exit
###########################################
# Description:  Determine which action the program must do.
# Inputs:
#           a0: An integer indicating which action the program must do.
###########################################
switch:
    li t0, 1
    beq t0, a0, operation1
    li t0, 2
    beq t0, a0, operation2
    li t0, 3
    beq t0, a0, operation3
    li t0, 4
    beq t0, a0, operation4

operation1:

operation2:

operation3:

operation4:

###########################################
# Description:  Read from Serial Port Peripheral until '\n' to buffer.
# Inputs:
#           a0: buffer address.
#           a1: buffer max-size.
###########################################
read:
    li t0, 0                        # index of current char.
    1:
    bgeu t0, a1, 1f                 # checks max-size
    li t1, 0x1              
    li t6, READ_STATUS_REG          # load READ_STATUS_REG address.
    sb t1, (t6)                     # sets read status to '1'. 
    2:
        lb t1, (t6)                 # gets read status.
        bnez t1, 2b
    # READ_STATUS_REG is set to zero, then reading is complete.
    li t6, READ_BYTE_REG            # load READ_BYTE_REG address.
    lb t1, (t6)                     # get content from READ_BYTE_REG.
    li t2, '\n'                     # checks for '\n' character.
    beq t1, t2, 1f                  # terminate process.

    add t2, a0, t0                  # buffer address to store byte.
    sb t1, 0(t2)                    # store byte at buffer.
    addi t0, t0, 1                  # increase index of buffer.
    1:

    add t2, a0, t0                  # null-terminated string.
    sb zero, 0(t2)                  
    ret
###############################################################################
# Description:  Get input address with some decimal representation and converts
#               it to a 32-bit signed number.
# Inputs:
#               a0: input stream address.
# Outputs:
#               a0: 32-bit signed number.
###############################################################################
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
###########################################
# Description:  Gracefully exit the program, i.e., can set program status.
# Inputs:
#               a0: program status.
###########################################
exit:
    li a7, 93
    ecall