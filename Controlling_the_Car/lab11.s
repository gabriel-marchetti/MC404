.section .text
.align 2
.set SELF_DRIVING_CAR_SLOT, 0xFFFF0100
_start:
    li t0, SELF_DRIVING_CAR_SLOT
    li t1, -15                          # magical number of steering.
    sb t1, 32(t0)                       # set steering wheel direction.
    li t1, 1                            # forward movement number.
    sb t1, 33(t0)                       # set forward movement.
    1:
        jal compute_square_dist_end
        li t5, 225                      # 15²
        blt a0, t5, 1f
        j 1b  
    1:
    li t0, SELF_DRIVING_CAR_SLOT
    li t1, 0                            # neutral steering whell.
    sb t1, 32(t0)                       # set steering wheel direction.
    li t1, 0                            # off number.
    sb t1, 33(t0)                       # turn-off engine.
    li t1, 1                            # flag hand-break.
    sb t1, 34(t0)                       # hand-break on.
    jal exit
##############################################################################
# Description: Gets current position of the car and compute its distance from
#              the end. Since distance needs to be 15 meters, we can use the
#              squared distance and see if it's value is less than 15².
# Inputs:
#           a0: Car-X position.
#           a1: Car-Y position.
# Outputs:
#           a0: squared distance from finish point.
##############################################################################
compute_square_dist_end:
    li t0, SELF_DRIVING_CAR_SLOT                # Get base address of the car.
    li t6, 1                                    # Flag to start GPS.
    sb t6, 0(t0)                                # start GPS.

    1:
    lb t6, 0(t0)
    bnez t6, 1b

    ####### Compute distance ######
    lw t1, 16(t0)                               # offset 16 contains X-car.
    lw t2, 24(t0)                               # offset 24 contains Z-car.

    li t3, -73                                  # -(X-end).
    add t1, t1, t3                              # t1 <- X_car - X_end
    mul t1, t1, t1                              # t1 <- (X_car - X_end)^2
    li t3, 19                                   # -(Z_end).
    add t2, t2, t3                              # t3 <- Z_car - Z_end
    mul t2, t2, t2                              # t3 <- (Z_car - Z_end)^2

    add a0, t1, t2                              # a0 <- squared distance
    ret
##############################################################################
# Description: Gets exit code status and throws it do OS.
# Inputs:
#           a0: Status Code.
#           a7: Syscall exit.
##############################################################################
exit:
    li a7, 93
    ecall
