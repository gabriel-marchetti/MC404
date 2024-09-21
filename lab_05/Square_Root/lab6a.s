.section .data
input_address:  .skip 0x14
output_address: .skip 0x14

.section .bss
.align 2
answer1:        .skip 0x4
answer2:        .skip 0x4
answer3:        .skip 0x4
answer4:        .skip 0x4

.section .text
.globl _start
.align 2
_start:
  jal read
  la t6, input_address
  li a0, 0
  add a0, a0, t6
  jal load # t0 will have the value of first number
debug:
  addi a0, t0, 0 # a0 <- t0
  jal square_root # a0 will have the value of square_root
  SW a0, answer1, t5
  li a0, 5
  add a0, a0, t6
  jal load # t0 will have the value of second number
  addi a0, t0, 0 # a0 <- t0
  jal square_root # a0 will have the value of square_root
  SW a0, answer2, t5
  li a0, 10
  add a0, a0, t6
  jal load # t0 will have the value of third number
  addi a0, t0, 0 # a0 <- t0
  jal square_root # a0 will have the value of square_root
  SW a0, answer3, t5
  li a0, 15
  add a0, a0, t6
  jal load # t0 will have the value of fourth number
  addi a0, t0, 0 # a0 <- t0
  jal square_root # a0 will have the value of square_root
  SW a0, answer4, t5
  jal store_output_buffer
  jal write
  li a0, 0
  li a7, 93
  ecall
# all answers stored
store_output_buffer:
  li s0, 10
  # t0: current value
  # t1: remainder
  # Answer 1
  la t5, output_address
  LW t1, answer1
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 3(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t0 <- t1 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 2(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 1(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 0(t5)
  div t1, t1, s0 # t1 <- t1 / 10

  # Puts ' ' 
  li t0, ' '
  sb t0, 4(t5)

  #Answer 2
  LW t1, answer2
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 8(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 7(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 6(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 5(t5)
  div t1, t1, s0 # t1 <- t1 / 10

  # Puts ' ' 
  li t0, ' '
  sb t0, 9(t5)

  #Answer 3
  LW t1, answer3
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 13(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 12(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 11(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 10(t5)
  div t1, t1, s0 # t1 <- t1 / 10

  # Puts ' ' 
  li t0, ' '
  sb t0, 14(t5)

  #Answer 4
  LW t1, answer4
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 18(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 17(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 16(t5)
  div t1, t1, s0 # t1 <- t1 / 10
  rem t0, t1, s0 # t1 <- t0 % 10
  addi t0, t0, '0' # Adjust to ASCII
  sb t0, 15(t5)
  div t1, t1, s0 # t1 <- t1 / 10

  # Puts ' ' 
  li t0, '\n'
  sb t0, 19(t5)
  ret
read:
  li a0, 0              # file descriptor (STDIN_FD)
  la a1, input_address
  li a2, 20             # num bytes of "DDDD DDDD DDDD DDDD\n"
  li a7, 63             # syscall read (63)
  ecall
  ret
write:
  li a0, 1              # file descriptor (STDOUT_FD)
  la a1, output_address
  li a2, 20             # num bytes of "DDDD DDDD DDDD DDDD\n"
  li a7, 64             # syscall read (64)
  ecall
  ret
##################
# Inputs: 
#         a0: address
##################
load:
  li t0, 0              # accumulator
  li t3, 4              # iterations 
  li t2, 10
  1:
  mul t0, t0, t2
  lb t4, 0(a0)          # get value from buffer  
  addi t4, t4, -'0'     # correct ASCII value
  add t0, t0, t4 
  addi a0, a0, 1        # increase address
  addi t3, t3, -1       # subtract one in iterations
  bnez t3, 1b  
  ret

#################
# a0: value to compute the square root
#################
square_root:
  mv s0, a0 # s0 will save the initial value
  mv s11, ra
  srai a0, a0, 1 # initial guess
  jal iteration
  jal iteration
  jal iteration
  jal iteration
  jal iteration
  jal iteration
  jal iteration
  jal iteration
  jal iteration
  jal iteration
  mv ra, s11
  ret
# a0: value of k
iteration:
  mv t0, s0
  div t0, t0, a0
  add t0, t0, a0 
  srai a0, t0, 1
  ret