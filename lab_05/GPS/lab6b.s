.section .data
input_address: .skip 0x20
output_address: .skip 0xc

.section .bss
.align 2
Xc: .skip 0x4
Yb: .skip 0x4
Ta: .skip 0x4
Tb: .skip 0x4
Tc: .skip 0x4
Tr: .skip 0x4
Da: .skip 0x4
Db: .skip 0x4
Dc: .skip 0x4
x: .skip 0x4
y: .skip 0x4
x1: .skip 0x4
x2: .skip 0x4

.section .text
.align 2
.globl _start

_start:
    jal read # store input to buffer
    la a0, input_address
    jal store_from_buffer #s1 will store Yb
    la t6, Yb
    sw s1, 0(t6)
    jal store_from_buffer #s1 will store Xc
    la t6, Xc
    sw s1, 0(t6)
    jal store_from_buffer #s1 will have Ta
    la t6, Ta
    sw s1, 0(t6) 
    jal store_from_buffer #s1 will have Tb
    la t6, Tb
    sw s1, 0(t6)
    jal store_from_buffer #s1 will have Tc
    la t6, Tc
    sw s1, 0(t6)
    jal store_from_buffer #s1 will have Tr
    la t6, Tr
    sw s1, 0(t6)
    
    la a0, Tr # will be needed to compute Da, Db, Dc
    # Compute Da
    la a1, Ta
    jal compute_distance # s0 will store Da
    sw s0, 0(a1)
    # Compute Db
    la a1, Tb
    jal compute_distance # s0 will store Db
    sw s0, 0(a1)
    # Compute Dc
    la a1, Tc
    jal compute_distance # s0 will store Dc
    sw s0, 0(a1)

    # Compute y
    li s0, 0
    LW t0, Da
    LW t1, Yb
    LW t2, Db
    mul t0, t0, t0 # t0 <- Da * Da
    mul t1, t1, t1 # t1 <- Yb * Yb
    mul t2, t2, t2 # t2 <- Db * Db
    li s1, -1
    mul t2, t2, s1 # t2 <- -(Db * Db)
    add s0, s0, t0
    add s0, s0, t1
    add s0, s0, t2 # s0 <- Da^2 + Yb^2 - Db^2
    LW t1, Yb
    li s1, 2
    mul t1, t1, s1 # t1 <- 2 * Yb 
    div s0, s0, t1 # s0 <- (Da^2 + Yb^2 - Db^2) / (2 * Yb)
    la s5, y
    sw s0, 0(s5)
    # Compute x1
    LW t0, Da
    LW t1, y
    li a0, 0 # will store s1
    li s1, -1
    mul t0, t0, t0 # t0 <- da^2
    mul t1, t1, t1
    mul t1, t1, s1 # t1 <- - y^2
    add a0, t0, t1
    jal square_root
    la s5, x1
    sw a1, 0(s5)
    # Compute x2
    mul x1, x1, s1
    la s5, x2
    sw a1, 0(s5)

    # Choose best X
    LW a0, x1
    mv a1, a0
    LW a0, x2 
    mv a2, a0
    blt a1, a2, 1f    
    return_point_condition:
    la s5, x
    sw a0, 0(s5)
    LW a0, x
    LW a1, y
    jal store_to_buffer
    jal write
    li a0, 0
    li a7, 93
    ecall
1:
    LW a0, x1
    j return_point_condition

# Inputs--------------------
# a0 : address of first char
# OBS: will change a0 but will save it at next position next to ' ' char.
# Outputs-------------------
# s1 : will store the value in decimal base.
store_from_buffer:
    li t0, 1     #detects sign
    li t1, '+'   #detects sign
    lb t2, 0(a0) #reads first char
    bne t1, t2, 1f
    store_from_buffer_continue:
    addi a0, a0, 1 #next char

    li s1, 0 #will store decimal value
    li t4, 10 #base-10 number
    li t1, ' ' #detects space char
    li t5, '\n'#detects endline char
    2:
    beq t1, t2, 2f 
    beq t2, t5, 2f
    mul s1, s1, t4 #shift base-10 number to left
    lb t2, 0(a0)
    addi t2, t2, -'0'
    add s1, s1, t2
    j 2b
1:
    li t0, -1
    j store_from_buffer_continue 
2:
    addi a0, a0, 1
    mul s1, s1, t0
    ret
# Inputs------------------
# a0 : value of x
# a1 : value of y
store_to_buffer:
    la t0, output_address
    li t1, '+'
    lb t1, 0(t0)
    blt a0, zero, 1f 
    continue_after_checking_signal_x:
    LW s1, x
    li t2, 10
    rem t1, s1, t2 # t1 will have the unit
    div s1, s1, t2 # divide x by 10
    addi t1, t1, '0' # Adjust to ASCII
    lb t1, 4(t0)

    rem t1, s1, t2 # t1 will have the dezena
    div s1, s1, t2 # divide x by 10
    addi t1, t1, '0'
    lb t1, 3(t0)

    rem t1, s1, t2 # t1 will have the centena
    div s1, s1, t2 # divide x by 10
    addi t1, t1, '0'
    lb t1, 2(t0)


    rem t1, s1, t2 # t1 will have the milhar
    div s1, s1, t2 # divide x by 10
    addi t1, t1, '0'
    lb t1, 1(t0)

    li t1, ' '
    lb t1, 5(t0)

    # store y
    li t1, '+'
    lb t1, 6(t0)
    blt a1, zero, 2f 
    continue_after_checking_signal_y:
    LW s1, y
    li t2, 10
    rem t1, s1, t2 # t1 will have the unit
    div s1, s1, t2 # divide y by 10
    addi t1, t1, '0' # Adjust to ASCII
    lb t1, 10(t0)

    rem t1, s1, t2 # t1 will have the dezena
    div s1, s1, t2 # divide y by 10
    addi t1, t1, '0'
    lb t1, 9(t0)

    rem t1, s1, t2 # t1 will have the centena
    div s1, s1, t2 # divide y by 10
    addi t1, t1, '0'
    lb t1, 8(t0)


    rem t1, s1, t2 # t1 will have the milhar
    div s1, s1, t2 # divide y by 10
    addi t1, t1, '0'
    lb t1, 7(t0)

    li t1, '\n'
    lb t1, 11(t0)
    ret
1:
    li t1, '-'
    lb t1, 0(t0)
    j continue_after_checking_signal_x
2:
    li t1, '-'
    lb t1, 6(t0)
    j continue_after_checking_signal_y

# Inputs------------------
# a0 : address of reference time (Tr)
# a1 : address of timestamp (Ta || Tb || Tc)
# Outputs-----------------
# s0 : value of distance (Da || Db || Dc)
compute_distance:
    lw s0, 0(a0) # s0 has Tr
    lw t1, 0(a1) # t1 has Ta
    sub s0, s0, t1 # s0 <- Tr - Ta
    li t1, 3 # since we no longer need Ta
    mul s0, s0, t1 # s0 <- (Tr - Ta) * 3
    li t1, 10
    div s0, s0, t1 # t0 <- ((Tr - Ta) * 3) / 10
    ret
read:
    li a0, 0
    la a1, input_address
    li a2, 0x20
    li a7, 63
    ecall
    ret
write:
    li a0, 1
    la a1, output_address
    li a2, 0xc
    li a7, 64
    ecall
    ret
# Inputs-------------
# a0: value to take square_root
# Outputs------------
# a1: final value
square_root:
    li t0, 25 # number of iterations
    li t1, 2
    li a1, 0
    add a1, a1, a0
    div a1, a1, t1 # initial_guess
    1:
    div t2, a0, a1
    add t2, t2, a1
    div t2, t2, t1 # divide by 2
    mv a1, t2
    add t0, t0, -1
    bnez t0, 1b
    ret
# Inputs-----------
# a0: value of x1 || x2 
# Outputs----------
# a0: value of condition of better x
compute_condition:
    li s1, -1
    LW t0, Xc
    mul t0, t0, s1 # t0 <- -Xc
    add a0, a0, t0 # a0 <- (a0 - Xc)
    mul a0, a0, a0 # a0 <- (a0 - Xc)^2
    LW t0, y
    mul t0, t0, t0 # t0 <- y^2
    add a0, a0, t0 # a0 <- (a0 - Xc)^2 + y^2
    LW t0, Dc
    mul t0, t0, t0 # t0 <- Dc^2
    mul t0, t0, s1 # t0 <- -Dc^2
    add a0, a0, t0
    ret
    
