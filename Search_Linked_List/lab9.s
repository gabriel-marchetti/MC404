.section .data
buffer: .skip 0x10      # it will be enough for containing the input.

.section .text
.align 2
.global _start

_start:
    la a1, buffer
    li a2, 0x10
    jal read                    # read stdin to buffer.
    la a1, buffer

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
    li t5, 10                   # base-10 number.
    1:
    li t3, '0'
    lb t1, 0(a0)
    blt t1, t3, 1f              # detect boundaries of ASCII char decimal
    li t3, '9'
    addi t3, t3, 1
    bge t1, t3, 1f              # detect boundaries of ASCII char decimal
    # We've checked every boundary for input buffer.
    mul t0, t0, t5              # shift base-10 number that we hold
    addi t1, t1, -'0'           # adjust to decimal value.
    add t0, t0, t1
    j 1b
    1:

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