	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_f2p0_d2p0"
	.file	"file1.c"
	.globl	main
	.p2align	2
	.type	main,@function
main:
	addi	sp, sp, -32
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	addi	s0, sp, 32
	li	a0, 0
	sw	a0, -32(s0)
	sw	a0, -12(s0)
	li	a0, 10
	sh	a0, -16(s0)
	lui	a0, 136775
	addi	a0, a0, -910
	sw	a0, -20(s0)
	lui	a0, 456050
	addi	a0, a0, 111
	sw	a0, -24(s0)
	lui	a0, 444102
	addi	a0, a0, 1352
	sw	a0, -28(s0)
	li	a0, 1
	addi	a1, s0, -28
	li	a2, 13
	call	write
	lw	a0, -32(s0)
	lw	ra, 28(sp)
	lw	s0, 24(sp)
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	main, .Lfunc_end0-main

	.type	.L__const.main.str,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__const.main.str:
	.asciz	"Hello World!\n"
	.size	.L__const.main.str, 14

	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym write
