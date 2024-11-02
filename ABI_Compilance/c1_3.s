.section .text
.align 2

.global operation
operation:
    addi sp, sp, -48
    sw ra, 44(sp)
    sw fp, 40(sp)

    li a0, 1
    li a1, -2
    li a2, 3
    li a3, -4
    li a4, 5
    li a5, -6
    li a6, 7
    li a7, -8

    li t0, -14
    sw t0, 20(sp)
    li t0, 13
    sw t0, 16(sp)
    li t0, -12
    sw t0, 12(sp)
    li t0, 11
    sw t0, 8(sp)
    li t0, -10
    sw t0, 4(sp)
    li t0, 9
    sw t0, 0(sp)

    jal mystery_function
    lw ra, 44(sp)
    lw fp, 40(sp)
    addi sp, sp, 48
    ret
