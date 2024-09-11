.section .data
input_address   .skip 20
output_address  .skip 20
stdin_fd:       .byte 0
stdout_fd:      .byte 1

.section .bss
.align 2
answer1:        .skip 4
answer2:        .skip 4
answer3:        .skip 4
answer4:        .skip 4

.section .text
.align 2
_start:
  call read
    

read:
  LB a0, stdin_fd       # file descriptor (STDIN_FD)
  la a1, input_address
  li a2, 20             # num bytes of "DDDD DDDD DDDD DDDD\n"
  li a7, 63             # syscall read (63)
  ecall
  ret

write:
  LB a0, stdout_fd      # file descriptor (STDOUT_FD)
  la a1, output_address
  li a2, 20             # num bytes of "DDDD DDDD DDDD DDDD\n"
  li a7, 64             # syscall read (63)
  ecall
  ret

##################
# Inputs: 
#         a0: address
##################
load:
  li t0, zero           # accumulator
  li t3, 4              # iterations 
  call 1f

##################
# Inputs: 
#         t0: accumulator
##################
1:
  li t2, 10
  mul t0, t0, t2
  lb t4, 0(a0)          # get value from buffer  
  addi t4, t4, -'0'     # correct ASCII value
  add t0, t0, t4 
  addi a0, a0, 1        # increase address
  addi t3, t3, -1       # subtract one in iterations
  bnez t3, 1b           # repeat if iterations is not zero

