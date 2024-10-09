.section .data
numbers:
    .word 160, 54, 89, 23, 67, 101, 76, 45, 34, 92
    .word 18, 39, 73, 58, 21, 84, 66, 47, 99, 102

.section .text
.align 2
.global _start
_start:
    la a2, numbers
    li a3, 20
    jal get_largest_number
    debug:

    jal exit
exit:
    li a0, 0
    li a7, 93
    ecall