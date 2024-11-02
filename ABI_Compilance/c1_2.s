.section .text
.align 2

###############################################################################
#   DESCRIPTION: Does the process specified by the exercise.
#   Inputs:
#       a0 - 32-bit signed integer
#       a1 - 32-bit signed integer
#       a2 - 32-bit signed integer 
#   Outputs:
#       a0 - 32-bit signed integer.
###############################################################################
.global my_function
my_function:
    addi sp, sp, -32                    // increase-size of stack
    sw ra, 28(sp)                       
    sw fp, 24(sp)

    sw a0,  8(sp)                       // 8(sp) = a
    sw a1,  4(sp)                       // 4(sp) = b
    sw a2,  0(sp)                       // 0(sp) = c

    add a0, a0, a1                      // a0 <- a + b
    lw a1, 8(sp)                        // a1 <- a
    jal mystery_function                // a0 <- holds result of this call.

    li t6, -1
    mul a0, a0, t6                      // a0 <- - mystery_func(a+b, a)
    
    lw t0, 4(sp)                        // t0 <- b
    add t0, t0, a0                      // t0 <- b - mystery_func(a+b, a)
    lw t1, 0(sp)                        // t1 <- c
    add t0, t0, t1                      // t0 <- b - mystery_func(a+b, a) + c

    sw t0, 12(sp)                       // 12(sp) <- b - mystery_func(a+b, a) + c

    mv a0, t0
    lw a1, 4(sp)
    jal mystery_function

    lw t0, 0(sp)                        // t0 <- c
    
    li t6, -1
    mul a0, a0, t6                      // a0 <- - mystery_func(a+b, a)
    add t0, t0, a0                      // t0 <- c - mystery_func(aux, b)
    lw t1, 12(sp)                       // t1 <- mystery_func(a+b, a)
    add t0, t0, t1                      // t0 <- c - mystery_func(aux, b) + aux

    mv a0, t0

    lw ra, 28(sp)
    lw fp, 24(sp)
    addi sp, sp, 32
    ret
