.section .data
.align 2
x: .word 5
y: .word 10

.section .text
.global _start

_start:

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
