.section .text
.align 2

.global node_creation
node_creation:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw fp, 24(sp)

    mv a0, sp
    li t1, 30
    sw t1, 0(a0)
    li t1, 25
    sb t1, 4(a0)
    li t1, 64
    sb t1, 5(a0)
    li t1, -12
    sh t1, 6(a0)

    jal mystery_function

    lw ra, 28(sp)
    lw fp, 24(sp)
    addi sp, sp, 32
    ret