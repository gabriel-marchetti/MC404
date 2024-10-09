.section .text
.align 2
.global get_largest_number
################################################################################
# Description:  Get the largest value from a vector that contains 32-bit 
#               unsigned numbers.
# Inputs:
#               a2: Initial address of base vector.
#               a3: Size of base vector.
# Outputs:
#               a0: Maximum value.
#               a1: Address of Maximum Value.
################################################################################
get_largest_number:
    li t0, 0                                # will store maximum value.
    li t1, 0                                # will store maximum value address.
    1:
    beqz a3, 1f                             # detects end of cycle.
        lw t2, 0(a2)                        # get element from vector.
        bleu t2, t0, 2f
            mv t0, t2                       # new max value.
            mv t1, a2                       # new max value address.
        2:
        addi a3, a3, -1                     # decrease one iteration.
        addi a2, a2,  4                     # increase to new int address.
        j 1b
    1:
    mv a0, t0
    mv a1, t1
    ret