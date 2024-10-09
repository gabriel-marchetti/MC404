.section .text
.align 2 
.global _start
_start:
    li s0, 5                # simulate some input.
    li t0, 10
    li t3, 10
    blt s0, t3, else
        li s2, 32           # do something
        j cont
    else:
        li s2, 48           # do something
    cont:

    jal exit
exit:
    li a0, 0
    li a7, 93
    ecall