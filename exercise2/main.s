	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_zicsr2p0_zifencei2p0"
	.file	"main.c"
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	li	a0, 0
	sw	a0, -20(s0)                     # 4-byte Folded Spill
	sw	a0, -12(s0)
	lui	a1, %hi(input_buffer)
	addi	a1, a1, %lo(input_buffer)
	li	a2, 10
	call	read
	mv	a1, a0
	lw	a0, -20(s0)                     # 4-byte Folded Reload
	sw	a1, -16(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
                                        # -- End function
	.type	input_buffer,@object            # @input_buffer
	.bss
	.globl	input_buffer
input_buffer:
	.zero	10
	.size	input_buffer, 10

	.ident	"clang version 18.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym read
	.addrsig_sym input_buffer
