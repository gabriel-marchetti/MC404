.section .bss
.align 4
isr_stack:
.skip 1024
isr_stack_end:

.section .data
.align 2
_system_time: .word 0
GPT_BASE_ADDRESS: .word 0xffff0100
MIDI_BASE_ADDRESS: .word 0xffff0300

.section .text
.align 2

.global _start
_start:
    # Save isr_stack at mscratch
    la t0, isr_stack_end
    csrw mscratch, t0

    # save main_isr address on interrupt vector table.
    la t0, main_isr
    csrw mtvec, t0

    # enable external interrupts
    csrr t0, mie
    ori t0, t0, 0x800
    csrw mie, t0

    # enable global interrupts
    csrr t0, mstatus
    ori t0, t0, 0x8
    csrw mstatus, t0

    # set GPT first cycle to interrupt.
    li t0, 100
    la t1, GPT_BASE_ADDRESS
    lw t1, (t1)
    sw t0, 8(t1)                 # GPT-time to 100ms.

    jal main
# General purpose interrupt handler.
main_isr:
    # Save context.
    csrw sp, mscratch, sp
    addi sp, sp, -64
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    # Handles Interrupt

    # increment _system_time
    la a0, _system_time
    lw a1, (a0)
    addi a1, a1, 100
    sw a1, (a0)

    # set GPT-timer
    la a0, GPT_BASE_ADDRESS
    lw a1, (a0)
    li a2, 100
    sw a2, 8(a1)

    # Restore the context
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 64
    csrw sp, mscratch, sp 
    mret