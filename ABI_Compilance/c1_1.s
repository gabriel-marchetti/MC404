.section .data
.align 2
.global my_var
my_var: .word 10

.section .text
.align 2
###############################################################################
#   Description: Increases the value of my_var by one.
#   Inputs:
#       None.
#   Outputs:
#       None.
###############################################################################
.global increment_my_var
increment_my_var:
    la t0, my_var               // t0 <- holds address of my_var.
    lw t1, (t0)                 // t1 <- value of my_var.
    addi t1, t1, 1              // adds one to my_var.

    sw t1, (t0)                 // stores increased value at my_var.
    ret