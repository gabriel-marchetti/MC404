.section .data
newline: .ascii "\n"

.section .bss
itoa_stack: .space 256
test_buffer: .space 256

.section .text
.align 2
# .global _start
# _start:
#     la a0, test_buffer
#     jal gets
#     la a0, test_buffer 
#     jal atoi
#     debug:
#     la a1, test_buffer
#     li a2, 10
#     jal itoa
#     la a0, test_buffer
#     jal puts

#     jal exit
###############################################################################
# Description:  Verify if sum of Node.val1 + Node.val2 = a1, it return the index
#               of node if condition is satisfied at this node. Otherwise return
#               -1.
# Inputs:
#               a0: Head_Node address.
#               a1: val.
# Outputs:
#               a0: Index of Node. (Can be negative if not found).
###############################################################################
.global linked_list_search
linked_list_search:
    li t0, 0                # index of node
    1:
    beqz a0, 1f             # break loop
    lw t1, 0(a0)
    lw t2, 4(a0)
    add t1, t1, t2          # t1 <- val1 + val2
    bne t1, a1, 2f
        mv a0, t0
        ret
    2:
    addi t0, t0, 1          # adds one to index.
    lw a0, 8(a0)            # get address of new node.
    j 1b
    1:
    li a0, -1               # didn't find node with sum.
    ret
###############################################################################
# Description:  Writes string pointed by a0 to stdout.
# Inputs:
#               a0: Pointer to String.
# Outputs:
#               None.
###############################################################################
.global puts
puts:
    li t0, 0                    # offset for buffer.
    li t6, '\n'                 
    1:
    add t1, a0, t0              # adds to t1 address buffer plus offset.
    lb  t2, 0(t1)               # read from string. 
    beq t2, t6, 1f
    beqz t2, 1f
        addi t0, t0, 1          # go-to next char at the string. (not null).
        j 1b
    1:
    mv a1, a0                   
    li a0, 1                    # stdout file-descriptor. 
    mv a2, t0                   # size of buffer.
    li a7, 64                   # syscall write.
    ecall
    li a0, 1                    # stdout file-descriptor.
    la a1, newline              # address of newline string. 
    li a2, 1
    li a7, 64                   # syscall write.
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
    addi sp, sp, -4
    sw a0, 0(sp)
    mv a1, a0                   # buffer address.
    li a0, 0                    # stdin file-descriptor
    li a2, 256                  # size of the buffer.
    li a7, 63                   # syscall read.
    ecall

    lw a0, 0(sp)
    addi sp, sp, 4
    ret
###############################################################################
# Description:  Get input address with some decimal representation and converts
#               it to a 32-bit signed number.
# Inputs:
#               a0: stream address.
# Outputs:
#               a0: 32-bit signed number.
###############################################################################
.global atoi
atoi:
    li t1, ' '
    1:
    lb t0, 0(a0)
    bne t0, t1, 1f
        addi a0, a0, 1
        j 1b
    1:
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
    li t5, '\n'             # checks for newline char.
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
    la t0, itoa_stack               
    li t5, 0                    # stack size
    bgez a0, 1f
        li t6, -1               # load negative sign
        mul a0, a0, t6          # converts to positive integer.
    1:
    beqz a0, 1f
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