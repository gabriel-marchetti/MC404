.section .data
numbers: .skip 40                   # int numbers[10]

.section .text
.align 2
.global _start
_start:
    la s0, numbers
    li t0, 15
    sw t0, 0(s0)
    li t0, 2
    sw t0, 4(s0)
    li t0, 3
    sw t0, 8(s0)
    li t0, 4
    sw t0, 12(s0)
    li t0, 3
    sw t0, 16(s0)
    li t0, 5
    sw t0, 20(s0)
    li t0, 8
    sw t0, 24(s0)
    li t0, 7
    sw t0, 28(s0)
    li t0, 7
    sw t0, 32(s0)
    li t0, 20
    sw t0, 36(s0)
    ###### initialize some array ######
    la a0, numbers
    li a1, 10
    jal get_largest_number
    debug:

    jal exit
################################################################################
# Inputs:
#           a0: address of array first index.
#           a1: size of array
# Outputs:
#           a0: largest number in array.
################################################################################
get_largest_number:
    li t0, 0                            # will store largest number.
    li t1, 0                            # index.
    li t2, 4                            # number of bytes used for each int.
    1:
    bge t1, a1, 1f                      # break if boundarie of array found.
        mul t3, t1, t2                  # offset to number.
        add t3, a0, t3
        lw t4, 0(t3)                    # get value from index.
        blt t4, t0, 2f
            mv t0, t4                   # new largest number.
        2:
        addi t1, t1, 1
        j 1b
    1:
    mv a0, t0                           # ABI return address
    ret
exit:
    li a0, 0
    li a7, 93
    ecall