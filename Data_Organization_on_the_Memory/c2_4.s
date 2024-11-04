.section .text
.align 2

.global node_op
# a0: Node *node
node_op:
    lw t1, 0(a0)

    lb t2, 4(a0)
    add t1, t1, t2

    lb t2, 5(a0)
    sub t1, t1, t2 

    lh t2, 6(a0)
    add t1, t1, t2

    mv a0, t1
    ret