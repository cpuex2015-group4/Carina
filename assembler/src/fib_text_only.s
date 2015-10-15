	subi    %t0, %t0, $1
	bne     %t0, %zero, beq_else.24
	move    %v0, %t0
	jr      %ra
	li      %t1, $1
	sub     %t1, %t0, %t1
	sw      %t0, 0(%sp)
	move    %t1, %t0
	subi    %sp, %sp, $1
	sw      %ra, 0(%sp)
	jal     fib.10
	lw      %ra, 0(%sp)
	addi    %sp, %sp, $-1
	move    %t0, %v0
	lw      %t1, 0(%sp)
	li      %t1, $2
	sub     %t1, %t1, %t1
	sw      %t0, 1(%sp)
	move    %t1, %t0
	subi    %sp, %sp, $2
	sw      %ra, 1(%sp)
	jal     fib.10
	lw      %ra, 1(%sp)
	addi    %sp, %sp, $-2
	move    %t0, %v0
	lw      %t1, 1(%sp)
	add     %v0, %t1, %t0
	jr      %ra
	li      %t0, $2
	jal     fib.10
	move    %t0, %v0
	hlt
