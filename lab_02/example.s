.globl _start

_start:
  li x11, 21
  li x12, 21
  add x10, x11, x12

  li a7, 93
  ecall
