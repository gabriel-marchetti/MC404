.section .text
.align 

.global operation
operation:
    mv t0, sp               # store old stack in t0.
    addi sp, sp, -64        # allocate space stack.
    sw ra, 60(sp)           # save ra.
    sw fp, 56(sp)           # save fp.

    sw a0, 52(sp)           # save caller-saved
    sw a1, 48(sp)           # save caller-saved
    sw a2, 44(sp)           # save caller-saved
    sw a3, 40(sp)           # save caller-saved
    sw a4, 36(sp)           # save caller-saved
    sw a5, 32(sp)           # save caller-saved
    sw a6, 28(sp)           # save caller-saved
    sw a7, 24(sp)           # save caller-saved

    sw a5, 0(sp)            # store "f" at 0(sp)
    sw a4, 4(sp)            # store "e" at 4(sp)
    sw a3, 8(sp)            # store "d" at 8(sp)
    sw a2, 12(sp)           # store "c" at 12(sp)
    sw a1, 16(sp)           # store "b" at 16(sp)
    sw a0, 20(sp)           # store "a" at 20(sp)

    lw a0, 20(t0)           # store "n" at a0
    lw a1, 16(t0)           # store "m" at a1
    lw a2, 12(t0)           # store "l" at a2
    lw a3, 8(t0)            # store "k" at a3
    lw a4, 4(t0)            # store "j" at a4
    lw a5, 0(t0)            # store "i" at a5
    
    # a6 holds "g" and a7 holds "h".
    # to change values between a6 and a7.
    add a6, a6, a7 
    sub a7, a6, a7
    sub a6, a6, a7

    jal mystery_function

    lw ra, 60(sp)           # restore ra
    lw fp, 56(sp)           # restore fp

    lw a0, 52(sp)           # restore caller-saved
    lw a1, 48(sp)           # restore caller-saved
    lw a2, 44(sp)           # restore caller-saved
    lw a3, 40(sp)           # restore caller-saved
    lw a4, 36(sp)           # restore caller-saved
    lw a5, 32(sp)           # restore caller-saved
    lw a6, 28(sp)           # restore caller-saved
    lw a7, 24(sp)           # restore caller-saved

    addi sp, sp, 64         # restore stack.
    ret