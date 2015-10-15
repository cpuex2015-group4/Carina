.data
.text
	.globl  _min_caml_start
fib.10:
	slti    %at, %t0, $2
	beq     %at, %zero, beq_else.24
	move    %v0, %t0
	jr      %ra
beq_else.24:
	subi    %t1, %t0, $1
	sw      %t0, -1(%sp)
	move    %t0, %t1
	subi    %sp, %sp, $2
	sw      %ra, (%sp)
	jal     fib.10
	lw      %ra, (%sp)
	addi    %sp, %sp, $2
	move    %t0, %v0
	lw      %t1, -1(%sp)
	subi    %t1, %t1, $2
	sw      %t0, -2(%sp)
	move    %t0, %t1
	subi    %sp, %sp, $3
	sw      %ra, (%sp)
	jal     fib.10
	lw      %ra, (%sp)
	addi    %sp, %sp, $3
	move    %t0, %v0
	lw      %t1, -2(%sp)
	add     %v0, %t1, %t0
	jr      %ra
_min_caml_start: # main entry point
	subi    %sp, %sp, $2
	sw      %ra, 1(%sp)
	sw      %fp, 0(%sp)
	move    %fp, %sp
	# main program start
	li      %t0, $30
	subi    %sp, %sp, $1
	sw      %ra, (%sp)
	jal     fib.10
	lw      %ra, (%sp)
	addi    %sp, %sp, $1
	move    %t0, %v0
	subi    %sp, %sp, $1
	sw      %ra, (%sp)
	jal     min_caml_print_int
	lw      %ra, (%sp)
	addi    %sp, %sp, $1
	# main program end
	move    %sp, %fp
	lw      %fp, 0(%sp)
	lw      %ra, -1(%sp)
	addi    %sp, %sp, $2
	hlt
