.section .text
.align 2

.global middle_value_int
# a0: int *array
# a1: int n
middle_value_int:
    li t0, 2
    div a1, a1, t0                  # divide by 2
    li t0, 4
    mul a1, a1, t0                  # int size

    add a0, a0, a1                  # get array[n]

    lw a0, (a0)                     
    ret
.global middle_value_short
# a0: int *array
# a1: int n
middle_value_short:
    li t0, 2
    div a1, a1, t0
    li t0, 2
    mul a1, a1, t0

    add a0, a0, a1                  # get array[n]

    lh a0, (a0)                     
    ret
.global middle_value_char
# a0: int *array
# a1: int n
middle_value_char:
    li t0, 2
    div a1, a1, t0                  # divide by 2
    add a0, a0, a1                  # get array[n]

    lb a0, (a0)                     
    ret

.global value_matrix
# a0: int matrix[12][42]
# a1: int r
# a2: int c
value_matrix:
    li t1, 42                   
    mul t0, a1, t1
    add t0, t0, a2
    li t1, 4
    mul t0, t0, t1

    add a0, a0, t0
    lw a0, (a0)
    ret