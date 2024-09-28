.section .bss
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
    jal open            #open image file (a0 <- file descriptor for the file)
    mv s0, a0           #save file-descriptor from file.
    la a1, image_buffer
    li a2, 0x40358 
    jal read            #store image at buffer.
     

    jal exit

###############################################################
# "exit" routine: define succesfull operation
# Inputs:
#       a0: Succed operation.
#       a7: Syscall indicator of exit.                                                              
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