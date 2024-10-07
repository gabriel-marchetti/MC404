.section .data
path_file: .asciz "image.pgm"
image_buffer: .skip 0x40358 # 263_000 in decimal (it will be enough)
.align 2
starting_index_image: .skip 4 # Address at the buffer.
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
    mv s0, a0                       # basically will store first index of buffer.
    la t6, starting_index_image     # to store buffer-address
    sw s0, 0(t6)

    la t6, image_width
    lhu a0, 0(t6)                   # stores image_width for setCanvasSize 
    la t6, image_height
    lhu a1, 0(t6)                   # store image_height for setCanvasSize
    jal set_canva_size
    
    la t6, image_height
    lhu a0, 0(t6)                   # load number of lines of the image
    la t6, image_width          
    lhu a1, 0(t6)                   # load number of columns of the image
    jal set_outer_pixels 

    # loading values for set_inner_pixels.
    la t6, starting_index_image
    lw a0, 0(t6)
    la t6, image_width
    lhu a1, 0(t6)
    la t6, image_height
    lhu a2, 0(t6) 
    jal set_inner_pixels

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
# "set_inner_pixels."
# inputs:
#       a0: Address from buffer
#       a1: image width (x)
#       a2: image height (y)
###############################################################
set_inner_pixels:
    mv s0, a0       # s0 will hold buffer address
    mv s1, a1       # s1 will hold the image width
    mv s2, a2       # s2 will hold the image height (more convenient location)
    mv s11, ra      # saves return address. We will call another function.

    li s4, 1        # line iterator
    li s5, 1        # col iterator
    mv s6, a2       
    addi s6, s6, -0x1 # get bound of for (y)
    mv s7, a1
    addi s7, s7, -0x1 # get bound of for (x)
    
    debug:
    1:
    bge s4, s6, 1f
        2:
        bge s5, s7, 2f
            mv a0, s0       # address of buffer.
            mv a1, s4       # current line.
            mv a2, s5       # current column.
            mv a3, s1       # number of columns.
            jal dot_product_matrix # a0 will hold the byte of color.
            jal adjust_color       # a0 will hold the necessary register value.
            mv a2, a0              # color for set_pixel
            mv a0, s5       
            mv a1, s4
            jal set_pixel
            addi s5, s5, 0x1
            j 2b
        2:
        addi s4, s4, 0x1
        li s5, 1
        j 1b
    1:

    jr s11
###############################################################
# "dot_product_matrix":
# inputs:
#       a0: buffer address.
#       a1: current line. (y)
#       a2: current column. (x)
#       a3: number of columns at matrix.
# outputs:
#       a0: value of the pixel in pgm. (0 <= a0 <= 255).
# Obs:
#       we are using the filter (outline filter)
#       -1  -1  -1
#       -1   8  -1
#       -1  -1  -1
###############################################################
dot_product_matrix:
    add t0, a1, zero        # get content of a1.
    mul t0, t0, a3          # get offset to get to (x, y)
    add t0, t0, a2          # get offset in cols to get to (x, y)
    add t0, t0, a0          # get the address of byte (x,y). it will be useful
    
    li  t5, 0               # will store final value.
    lbu t5, 0(t0)           # get content from (x, y)
    li  t2, 0x8             
    mul t5, t5, t2          # t5 <- t5 * 8

    li t2, -0x1             # for multiplication.
    # get value of byte (x-1, y)
    addi t1, t0, -0x1       # address of byte (x-1, y)
    lbu t6, 0(t1)
    mul t6, t6, t2          # t6 <- -t6
    add t5, t5, t6          # t5 <- (t5*8) + (-1*t6)
    # get value of byte (x+1, y)
    addi t1, t0, 0x1        # address of byte (x+1, y)
    lbu t6, 0(t1)
    mul t6, t6, t2          # t6 <- -t6
    add t5, t5, t6          

    # get value from (x, y-1), (x-1, y-1), (x+1, y-1)
    mul a3, a3, t2          # a3 <- -a3
    add t0, t0, a3          # address of (x, y-1)

    # value from (x, y-1)
    lbu t6, 0(t0)
    mul t6, t6, t2          # t6 <- -t6
    add t5, t5, t6          

    # value from (x-1, y-1)
    addi t1, t0, -0x1       # address of (x-1, y-1)
    lbu t6, 0(t1)           # value from (x-1, y-1)
    mul t6, t6, t2          # change sign
    add t5, t5, t6

    # value from (x+1, y-1)
    addi t1, t0, 0x1       # address of (x+1, y-1)
    lbu t6, 0(t1)           # value from (x+1, y-1)
    mul t6, t6, t2          # change sign
    add t5, t5, t6
    
    # get values form (x, y+1), (x-1, y+1), (x+1, y+1)
    mul a3, a3, t2         # since a3 was negative
    li  t2, 0x2
    mul a3, a3, t2         # get offset lines since we are at line y-1
    li  t2, -0x1           # store negative one.

    add t0, t0, a3         # get value from (x, y+1)

    # add value of (x, y+1)
    lbu t6, 0(t0) 
    mul t6, t6, t2
    add t5, t5, t6 

    # value from (x-1, y+1)
    addi t1, t0, -0x1       # address of (x-1, y+1)
    lbu t6, 0(t1)           # value from (x-1, y+1)
    mul t6, t6, t2          # change sign
    add t5, t5, t6

    # value from (x+1, y+1)
    addi t1, t0, 0x1        # address of (x+1, y+1)
    lbu t6, 0(t1)           # value from (x+1, y+1)
    mul t6, t6, t2          # change sign
    add t5, t5, t6

    # check boundaries
    bge t5, zero, 1f    # 0
        mv t5, zero
    1:
    li t2, 256          # 255
    blt t5, t2, 1f
        li t2, 255
        mv t5, t2
    1:
    mv a0, t5
    ret
###############################################################
# "set_outer_pixels" routine: set edge pixels of the filtered image
# to black.
# inputs:
#       a0: Number of lines at the image.
#       a1: Number of columns.
###############################################################
set_outer_pixels:
    mv s0, a0           # store the values into more conventional register.
    mv s1, a1           # store the values into more conventional register.
    mv s2, ra           # store return address.

    li t0, 0            # line iterator
    li t1, 0            # column

    # Set top pixels to black.
    1:
    bge t1, s1, 1f
        mv a0, t1       # get x-coordinate.
        mv a1, t0       # get y-coordinate.
        li a2, 255      # set black pixel.
        jal set_pixel
        addi t1, t1, 1
        j 1b
    1:
    # Set left and right pixels to black lines 1 <----> (lines - 1)
    li t2, 0            # index of left most pixel.
    mv t3, s1
    addi t3, t3, -1     # index of right most pixel.

    li t0, 1            # line index
    1:
    bge t0, s0, 1f
        mv a0, t2       # get line
        mv a1, t0       # get left most pixel
        li a2, 255      # black pixel
        jal set_pixel
        mv a0, t3       # get line
        mv a1, t0       # get right most pixel
        li a2, 255
        jal set_pixel   
        addi t0, t0, 1
        j 1b
    1:
    # Set bottom pixels to black.
    mv t0, s0
    addi t0, t0, -1     # index of last line.
    li t1, 0            # col iterator.
    1:
    bge t1, s1, 1f
        mv a0, t1       # get x-coordinate.
        mv a1, t0       # get y-coordinate.
        li a2, 255      # set black pixel.
        jal set_pixel
        addi t1, t1, 1
        j 1b
    1:
    jr s2
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