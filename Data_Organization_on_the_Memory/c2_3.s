.section .text
.align 2

.global fill_array_int
fill_array_int:
    addi sp, sp, -416
    sw ra, 412(sp)
    sw fp, 408(sp)

    li t0, 0
    mv t1, sp
    1:
    li t4, 100
    bge t0, t4, 1f
        slli t4, t0, 2
        add t4, t1, t4
        sw t0, (t4)

        addi t0, t0, 1
        j 1b
    1:

    mv a0, sp
    jal mystery_function_int

    lw ra, 412(sp)
    lw fp, 408(sp)
    addi sp, sp, 416
    ret
.global fill_array_short
fill_array_short:
    addi sp, sp, -224
    sw ra, 220(sp)
    sw fp, 216(sp)

    mv t0, sp
    li t1, 0
    1:
    li t2, 100
    bge t1, t2, 1f
        slli t3, t1, 1
        add t3, t0, t3
        sh t1, (t3)

        addi t1, t1, 1
        j 1b
    1:

    mv a0, sp
    jal mystery_function_short

    lw ra, 220(sp)
    lw fp, 216(sp)
    addi sp, sp, 224
    ret
.global fill_array_char
fill_array_char:
    addi sp, sp, -112
    sw ra, 108(sp)
    sw fp, 104(sp)

    mv t0, sp
    li t1, 0
    1: 
    li t2, 100
    bge t1, t2, 1f
        add t2, t0, t1
        sb t1, (t2)

        addi t1, t1, 1
        j 1b
    1:

    mv a0, sp
    jal mystery_function_char

    lw ra, 108(sp)
    lw fp, 104(sp)
    addi sp, sp, 112
    ret