.section .data
str: .string "Verifique se qui tem um crctere"

.section .text
.align 2
.global _start
_start:
    la s0, str                      # will be used for iterating through str.
    li s1, 'a'                      # character that need to be find.
    li t0, 0                        # offset shift.
    li a0, 0
    1:
    add t1, s0, t0                  # current index of buffer.
    lb  t2, 0(t1)                   # get content from index.
    beqz t2, 1f                     # if found null char, then skip.
        bne t2, s1, 2f
            mv a0, t1
            j 1f
        2:
        addi t0, t0, 1              # add to shift index.
        j 1b
    1:
    debug:
    jal exit
exit:
    li a0, 0                        # succeed operation
    li a7, 93                       # exit syscall
    ecall