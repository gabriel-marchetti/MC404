.section .data
buffer: .skip 0x10              # it will be enough for containing the input.
write_buffer: .skip 0x10        # it will store the output.

.section .text
.align 2
.global _start

_start:
    la a1, buffer
    li a2, 0x10
    jal read                    # read stdin to buffer.
    la a0, buffer
    jal compute_decimal
    mv s1, a0                   # s1 will hold the value from decimal.
    
    la t0, head_node            # address of node in Linked List.
    li t1, -1                   # index of node at Linked List.
    li t2, 0                    # store index found. 
    next_node:
    beq t0, zero, end_next_node 
        lw t4, 0(t0)            # get val1
        lw t5, 4(t0)            # get val2
        add t4, t4, t5          # t4 <- val1 + val2
        bne s1, t4, 1f          # compare read number to node sum. 
            mv t1, t2 
            j end_next_node     # end loop
        1:
        lw t0, 8(t0)            # t0 receive next node address.
        addi t2, t2, 1          # index of node.
        j next_node
    end_next_node:

    la a0, write_buffer
    mv a1, s1 
    jal store_decimal_to_buffer # a0 will hold buffer size.
    
    debug:
    mv a2, a0
    la a0, write_buffer
    jal write                   # write to stdout.

    jal exit
################################################################################
# store_decimal_to_buffer.
#       stores a decimal to a buffer.
# inputs:
#       a0: buffer address.
#       a1: decimal value. 
# outputs:
#       a0: buffer size.
################################################################################
store_decimal_to_buffer:
    li t0, 0                    # buffer size.
    li t1, 10                   # base-10 number.
    mv t2, a1

    bgez t2, positive_case
        neg t2, t2
        li  t6, '-'
        sb  t6, 0(a0)           # store negative sign.
        addi t0, t0, 1          # increment index.
    positive_case:
    convert_loop:
        rem t4, t2, t1              # get remainder division by 10.
        addi t4, t4, '0'            # adjust to ASCII.
        add t5, a0, t0              # correct buffer address.
        sb t4, 0(t5)                
        div t2, t2, t1              # divide by 10
        addi t0, t0, 1
        bnez t2, convert_loop
    mv a0, t0
    ret
################################################################################
# compute_decimal:
#       reads a decimal to a0
# inputs:
#       a0: Buffer address.
# outputs:
#       a0: decimal value of decimal representation into buffer.
################################################################################
compute_decimal:
    li t0, 0                    # store decimal value into register.
    lb t1, 0(a0)                # get first char of buffer.
    li t2, 1                    # will be used to change sign if negative.
    li t3, '-'                  # checks for negative sign.
    bne t1, t3, 1f
        li t2, -1               # it is a negative number.
        addi a0, a0, 1          # go-to next char of buffer.
    1:
    li t5, 10                   # base-10 number.
    loop:
    lb t1, 0(a0)
    li t3, 10
    beq t1, t3, 1f              # checks new line char.
    li t3, '0'
    blt t1, t3, 1f             # detect boundaries of ASCII char decimal
    li t3, '9'
    bgt t1, t3, 1f             # detect boundaries of ASCII char decimal
    # We've checked every boundary for input buffer.
    mul t0, t0, t5              # shift base-10 number that we hold
    addi t1, t1, -'0'           # adjust to decimal value.
    add t0, t0, t1

    addi a0, a0, 1              # go-to next char.
    j loop
    1:

    mul t0, t0, t2
    mv a0, t0
    ret
################################################################################
# read:
#       read inputs from stdin and store it on some buffer.
# inputs:
#       a1: buffer address
#       a2: buffer size
#       a7: syscall read (63)
################################################################################
read:
    li a0, 0                    # stdin file-descriptor
    li a7, 63                   # sycall read
    ecall
    ret
################################################################################
# write:
#       write some buffer content to stdout.
# inputs:
#       a1: buffer address
#       a2: buffer size
#       a7: syscall write (64)
################################################################################
write:
    li a0, 1                    # stdout file-descriptor
    li a7, 64                   # syscall write
    ecall
    ret
################################################################################
# exit:
#       gracefully exit the procedure.
# inputs:
################################################################################
exit:
    li a0, 0                    # succeed identifier
    li a7, 93                   # syscall exit
    ecall