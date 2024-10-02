.section .data
path_file: .asciz "image.pgm"
image_buffer: .skip 0x40358 # 263_000 in decimal (it will be enough)
.align 2
starting_index_image: .word # Address at the buffer.
.align 1
image_width:  .skip 2      #since it will be less or equal than 512
image_height: .skip 2      #since it will be less or equal than 512
max_val:      .skip 1      #since it will be less or equal than 255

.section .text
.align 2
.global _start

_start:
    la a0, path_file
    jal open                    #open image file (a0 <- file descriptor for the file)
    mv s11, a0                  #save file-descriptor from file.
    la a1, image_buffer
    li a2, 0x40358 
    jal read                    #store image at buffer.

    la a0, image_buffer         #store address of image_buffer.
    jal find_non_whitespace     #checks for "whitespaces" 
    addi a0, a0, 2              #skips "P5"

    jal find_non_whitespace     #find width
    jal compute_decimal_from_buffer # a0 will hold the decimal value of width
                                    # s0 holds the first whitespace after width
    la t0, image_width              
    sh a0, 0(t0)                    # store image_width

    mv a0, s0                       # moves buffer, after moving address, to a0.
    jal find_non_whitespace
    jal compute_decimal_from_buffer # a0 will hold the decimal value of height
    la t0, image_height
    sh a0, 0(t0)                    # stores image_height.

    mv a0, s0                       # moves buffer, after moving address, to a0.
    jal find_non_whitespace
    jal compute_decimal_from_buffer

    la t0, max_val
    sb a0, 0(t0)

    mv a0, s0
    jal find_non_whitespace
    mv s0, a0

    la t6, image_width
    lhu a0, 0(t6)                   # stores image_width for setCanvasSize 

    la t6, image_height
    lhu a1, 0(t6)                   # store image_height for setCanvasSize

    jal set_canva_size

    mv a0, s0
    la t6, image_width
    lhu a1, 0(t6)
    la t6, image_height
    lhu a2, 0(t6) 
    jal set_image_on_canvas

    jal exit
###############################################################
# find_non_whitespace: find next occurence of a non-whitespace
# this means blanks, TABs, CRs, LFs.
#
# Inputs:
#       a0: Address of image buffer.
# Outputs:
#       a0: Adress of next occurence of non-blank information.
###############################################################
find_non_whitespace:
    li t1, ' '              # blanks
    li t2, '\t'             # TAB ascii code.
    li t3, '\r'             # CR ascii code.
    li t4, '\n'             # LF ascii code.
    1:
        lb t0, 0(a0)        # read byte from buffer.
        beq t0, t1, 2f      # detects blanks
        beq t0, t2, 2f      # detects TAB
        beq t0, t3, 2f      # detects CR
        beq t0, t4, 2f      # detects LF 
        ret
    2:    
        addi a0, a0, 1      # move buffer.
        j 1b                # repeat.
###############################################################
# compute_decimal_from_buffer: reads a decimal number stored at the buffer
# Inputs:
#       a0: Buffer Address.
# Outputs:
#       a0: value read from decimal.
# OBS:
#       s0: stores the buffer address.
###############################################################
compute_decimal_from_buffer:
    mv s0, a0               #store buffer address
    li t1, ' '              # blanks
    li t2, '\t'             # TAB ascii code.
    li t3, '\r'             # CR ascii code.
    li t4, '\n'             # LF ascii code.

    li a0, 0
    li t6, 10               #base-10 number.
    1:
        lb t0, 0(s0)        #reads byte from buffer.
        beq t0, t1, 1f
        beq t0, t2, 1f
        beq t0, t3, 1f
        beq t0, t4, 1f      #checks for whitespaces.
        mul a0, a0, t6      #multiply by 10.
        addi t0, t0, -'0'   #adjust ASCII value.
        add a0, a0, t0      #read decimal value.
        addi s0, s0, 1      #move buffer.
        j 1b
    1:
        ret
###############################################################
# Makes R = G = B and A = 255.
# inputs:
#       a0: "byte" from image.
# Outputs:
#       a0: adjusted color
###############################################################
adjust_color:
    mv t0, a0               # save byte value.
    li a0, 255              # set A = 255.
    slli t2, t0, 8          
    add a0, a0, t2          # set B = "byte"

    slli t2, t0, 16         
    add a0, a0, t2          # set G = "byte"
    
    slli t2, t0, 24         
    add a0, a0, t2          # set R = "byte" 

    ret
###############################################################
# "set_image_on_canvas"
# inputs:
#       a0: Address from buffer
#       a1: image width
#       a2: image height
###############################################################
set_image_on_canvas:
    mv s0, a0
    mv s1, a1       # s1 will hold the image width
    mv s2, a2       # s2 will hold the image height
    mv s11, ra      # saves return address. We will call another function.

    li s8, 0        # current column
    li s9, 0        # current line
    debug:
    1:
        bge s9, s2, 1f
        2:
            bge s8, s1, 2f
            lbu a0, 0(s0)       #reads from buffer.
            addi s0, s0, 1      #update buffer.
            jal adjust_color    #a0 will hold adjust color
            mv a2, a0           #store at a2 the adjusted color.
            mv a0, s8
            mv a1, s9 
            jal set_pixel
            addi s8, s8, 1 
            j 2b
        2: 
        addi s9, s9, 1
        li s8, 0
        j 1b
    1:
    jr s11

###############################################################
# "exit" routine: define succesfull operation
# inputs:
#       a0: succed operation.
#       a7: syscall indicator of exit.                                                              
###############################################################
exit:
    li a0, 0            #succed indicator
    li a7, 93           #syscall exit(93)
    ecall
###############################################################
# "read" routine: read input to buffer.
# Inputs:
#       a0: File Descriptor (can be either 0 for stdin or the file descriptor
#                            of a file).
#       a1: Buffer Address.
#       a2: Buffer Size.
#       a7: Syscall indicator to write.                                                              
###############################################################
read:
    li a7, 63           #syscall read (63)
    ecall
    ret
###############################################################
# "write" routine: write buffer to output.
# inputs:
#       a0: file descriptor
#       a1: buffer address.
#       a2: buffer size.
#       a7: syscall indicator to write.                                                              
###############################################################
write:
    li a0, 1            #file descriptor (stdout)
    li a7, 64           #syscall write(64)
    ecall
    ret
###############################################################
# "set_pixel" routine: set pixel on specific pixel at canva.
# inputs:
#       a0: x coordinate
#       a1: y coordinate
#       a2: pixel color
#       a7: syscall set_pixel (2200).
###############################################################
set_pixel:
    li a7, 2200
    ecall
    ret
###############################################################
# "set_canva_size" routine: 
# inputs:
#       a0: canva width
#       a1: canva height
#       a7: syscall set_pixel (2200).
###############################################################
set_canva_size:
    li a7, 2201
    ecall 
    ret
###############################################################
# "open" routine: open a specific file descriptor.
#        example: can open a file file-descriptor.
# inputs:
#       a0: address of path to file.
#       a1: permission to modify file target (here 0 for rdonly)
#       a2: mode
#       a7: syscall open (1024)
# outputs:
#       a0: file descriptor of the file.
###############################################################
open:
    li a1, 0        #permission to rdonly.
    li a2, 0        #mode
    li a7, 1024     #syscall open (1024)
    ecall
    ret
###############################################################
# "close" routine: close a specific file descriptor.
#         example: can open a file file-descriptor.
# inputs:
#       a0: file descriptor
#       a7: syscall open (1024)
###############################################################
close:
    li a7, 57       #syscall close (57)
    ecall
    ret