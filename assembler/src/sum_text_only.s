	slti    %at, %t0, $0
	beq     %at, %zero, beq_else.17
	li      %v0, $0
	jr      %ra
	li      %t1, $1
	sub     %t1, %t0, %t1
	sw      %t0, 0(%sp)
	move    %t0, %t1
	subi    %sp, %sp, $1
	sw      %ra, 0(%sp)
	jal     sum.7
	lw      %ra, 0(%sp)
	addi    %sp, %sp, $-1
	move    %t0, %v0
	lw      %t1, 0(%sp)
	add     %v0, %t0, %t1
	jr      %ra
	subi    %sp, %sp, $2
	sw      %ra, 1(%sp)
	sw      %fp, 0(%sp)
	move    %fp, %sp
	li      %t0, $10000
	subi    %sp, %sp, $0
	sw      %ra, -1(%sp)
	jal     sum.7
	lw      %ra, -1(%sp)
	addi    %sp, %sp, $0
	move    %t0, %v0
	subi    %sp, %sp, $0
	sw      %ra, -1(%sp)
	lw      %ra, -1(%sp)
	addi    %sp, %sp, $0
	move    %sp, %fp
	lw      %fp, 0(%sp)
	lw      %ra, -1(%sp)
	addi    %sp, %sp, $2
	hlt
