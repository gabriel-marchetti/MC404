.section .text
.align 2

.global operation
operation:
    mv t0, a1                   // t0 <- b
    add t0, t0, a2              // t0 <- b + c

    sub t0, t0, a5              // t0 <- b + c - f
    add t0, t0, a7              // t0 <- b + c - f + h

    lh t1, 8(sp)                
    add t0, t0, t1              // t0 <- b + c - f + h + k

    lw t1, 16(sp)               
    sub t0, t0, t1              // t0 <- b + c - f + h + k - m
    
    mv a0, t0 
    ret