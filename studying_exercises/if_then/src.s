.section .data
.align 2
x: .word 200

.section .text
.global _start

_start:
    la t6, x
    lw t0, 0(t6)            # t0 <- x
    # get values from x and y
    li t1, 10               # used for condition.
    blt t0, t1, 1f
        li t0, 10
    1:
    debug:
    
    jal exit
################################################################################
# exit:
# inputs:
#           a0: status indicator (succeed)
#           a7: exit syscall (93)
################################################################################
exit:
    li a0, 0                    # succeed status
    li a7, 93                   # exit syscall
    ecall
