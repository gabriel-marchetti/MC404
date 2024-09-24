.section .bss
.align 2
input_address:      .skip 0xd 
output_address:     .skip 0xf
bitmask_encode:     .skip 0x4   #will store a int
bitmask_encoded:    .skip 0x4   #will store a int
bitmask_decode:     .skip 0x4   #will store a int
bitmask_decoded:    .skip 0x4   #will store a int
flag_error:         .skip 0x1   #will store a flag

.section .text
.global _start
.align 2
_start:
    jal read
    #reads bitmask_encode from buffer.
    la a0, input_address
    la a1, bitmask_encode
    jal read_from_buffer
    #reads bitmask_decode from buffer.
    la a1, bitmask_decode
    jal read_from_buffer

    #encode
    la a0, bitmask_encode
    la a1, bitmask_encoded
    jal encode_hamming_code

    #decode
    la a0, bitmask_decode
    la a1, bitmask_decoded 
    jal decode_hamming_code
    la t0, flag_error
    sb a0, 0(t0)

    debug:

    jal exit
########################################
# inputs:
#   a0: pointer to buffer.
#   a1: address of label that will store the value.
read_from_buffer:
    li t5, '\n'             #will be used for checking the pointed char
    li t0, 0                #t0 will store the mask.
    1:
        lb t1, 0(a0)        #will read char pointed by a0. 
        beq t1, t5, 1f      #break loop if find '\n' char.
        addi t1, t1, -'0'   #adjust to ASCII.
        slli t0, t0, 1      #multiply t0 by two.
        add t0, t0, t1      #add char.
        addi a0, a0, 1      #points to next char.
        j 1b
    1:
    addi a0, a0, 1          #skips the '\n' char.
    sw t0, 0(a1)
    ret

########################################
# inputs:
#   a0: address mask of encoded number
#   a1: address mask of decoded number
#   a2: address flag
#   a3: address of output_buffer.
store_to_buffer:
    lw t0, 0(a0)            #t0 will load encoded mask
    li t2, 2                #base of binary number.
    1:
       beqz t0, 1f
       rem t1, t0, t2 
    1:

########################################
# inputs:
#   a0: mask that will be used to encode the number
#   a1: address of storing new mask.
encode_hamming_code:
    li a2, 0                #will store the encoded mask.
    li t0, 0                #will hold number of ones
    lw t1, 0(a0)            #read the mask

    li t2, 0x8              #will be used to extract d1
    and t2, t2, t1          #will extract d1
    snez t3, t2
    mv s5, t3               #save d1
    add t0, t0, t3          #count number of ones
    slli t3, t3, 4          #will sum to encoded mask.
    add a2, a2, t3          #add d1 to encoded mask.

    li t2, 0x1              #will be used to extract d4.
    and t2, t2, t1          #will extract d4.
    snez t3, t2             
    add t0, t0, t3          #count number of ones 
    add a2, a2, t3          #add d4 to encoded mask.

    li t2, 0x4              #will be used to extract d2.
    and t2, t2, t1          #will extract d2.
    snez t3, t2
    mv s1, t3               #save the bit t3
    add t0, t0, t3          #count number of ones
    slli t3, t3, 2          #will sum to encoded mask.
    add a2, a2, t3          #add d2 to encoded mask.

    # Check parity of t0 (holds the number of ones).
    li t4, 2
    rem t3, t0, t4          #t3 hold the bit p1
    slli t3, t3, 6          #mask
    add a2, a2, t3          #add to mask

    #Since we didn't change t0, we can subtract bit d2
    li s2, -1
    mul s2, s1, s2          #change sign of s1
    add t0, t0, s2          #subtract one if d2 is one.

    li t2, 0x2              #will be used to extract d3.
    and t2, t2, t1          #extract d3.
    snez t3, t2
    mv s1, t3               #save the value from t3
    add t0, t0, t3
    slli t3, t3, 1          #will sum to encoded mask
    add a2, a2, t3          #add d3 to encoded mask

    #Check parity of t0 (holds the number of ones of d1 d3 d4)
    li t4, 2
    rem t3, t0, t4          #t3 hold the bit p2
    slli t3, t3, 5          #mask
    add a2, a2, t3          #add to mask.

    #Since s1 holds d2 and s5 holds d1
    li s2, -1
    mul s2, s2, s5          #change the sign of s5
    add t0, t0, s2          #subtract parity of d1
    add t0, t0, s1          #add parity of d2

    rem t3, t0, t4
    slli t3, t3, 3          #mask
    add a2, a2, t3          #add to mask. 
    sw a2, 0(a1)
    ret
########################################
# inputs:
#   a0: address of mask that will be used to decode the number
#   a1: address of storing new mask.
# Outputs:
#   a0: return the flag.
decode_hamming_code:
    li t0, 0                #will save the value from new mask.
    lw a0, 0(a0)            #will extract the mask.
    
    #Extract the d1 from a0
    li t1, 0x10
    and t1, t1, a0
    srli t1, t1, 1          #adjust to 4 bits
    snez s1, t1             #s1 will store d1 in LSB
    add t0, t0, t1

    #Extract the d2 from a0
    li t1, 0x4
    and t1, t1, a0
    snez s2, t1             #s2 will store d2 in LSB
    add t0, t0, t1

    #Extract the d3 from a0
    li t1, 0x2
    and t1, t1, a0
    snez s3, t1             #s3 will store d3 in LSB
    add t0, t0, t1

    #Extract the d4 from a0
    li t1, 0x1
    and t1, t1, a0
    snez s4, t1             #s4 will store d4 in LSB
    add t0, t0, t1

    sw t0, 0(a1)            #save the mask d1d2d3d4

    #Extract p1 from a0
    li t1, 0x40             #mask to extract p1
    and t1, a0, t1              
    snez s5, t1             #s5 will store d5 in LSB     

    #Extract p2 from a0
    li t1, 0x20             #mask to extract p2
    and t1, a0, t1 
    snez s6, t1             #s6 will store d6 in LSB

    #Extract p3 from a0
    li t1, 0x8              #mask to extract p3
    and t1, a0, t1
    snez s7, t1             #s7 will store d6 in LSB

    li a0, 0                #Suppose that is right.

    # s1 <- d1
    # s2 <- d2
    # s3 <- d3
    # s4 <- d4
    # s5 <- p1
    # s6 <- p2
    # s7 <- p3
    # p1 xor d1 xor d2 xor d4
    xor t0, s5, s1
    xor t0, t0, s2
    xor t0, t0, s4
    beqz t0, 1f
        li a0, 1
        ret
    1:

    # p2 xor d1 xor d3 xor d4
    xor t0, s6, s1
    xor t0, t0, s3
    xor t0, t0, s4
    beqz t0, 1f
        li a0, 1
        ret
    1:

    # p3 xor d2 xor x3 xor d4
    xor t0, s7, s2
    xor t0, t0, s3
    xor t0, t0, s4
    beqz t0, 1f
        li a0, 1
        ret
    1:

    ret
read:
    li a0, 0                #file descriptor (stdin)
    la a1, input_address    #buffer that receives the data
    li a2, 0xd              #size of input data 
    li a7, 63               #syscall read (63)
    ecall
    ret
write:
    li a0, 1                #file descriptor (stdout)
    la a1, output_address   #buffer that prints the data
    li a2, 0xf              #size of output data 
    li a7, 64               #syscall write (64)
    ecall
    ret
exit:
    li a0, 0                #succed.
    li a7, 93               #syscall exit (93)
    ecall