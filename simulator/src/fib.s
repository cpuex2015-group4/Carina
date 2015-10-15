fib.10:
	slti    $at, $1, $t0
	bne     $at, $zero, beq_else.24
	move    $v0, $t0
	lw      $ra, 1($sp)
	addi    $sp, $sp, $1
	jr      $ra
beq_else.24:
	li      $t1, $1
	sub     $t1, $t0, $t1
	sw      $t0, 0($sp)
	move    $t1, $t0
	sw      $ra, 4($sp)
	addi    $sp, $sp, $5
	jal     fib.10
	addi    $sp, $sp, $-5
	lw      $ra, 4($sp)
	move    $t0, $v0
	lw      $t1, 0($sp)
	li      $t1, $2
	sub     $t1, $t1, $t1
	sw      $t0, 1($sp)
	move    $t1, $t0
	sw      $ra, 5($sp)
	addi    $sp, $sp, $6
	jal     fib.10
	addi    $sp, $sp, $-6
	lw      $ra, 5($sp)
	move    $t0, $v0
	lw      $t1, 1($sp)
	add     $v0, $t1, $t0
	lw      $ra, 1($sp)
	addi    $sp, $sp, $1
	jr      $ra
_min_caml_start:
	sw      $ra, -1($sp)
	sw      $fp, 0($sp)
	li      $t0, $5
	sw      $ra, -1($sp)
	addi    $sp, $sp, $0
	jal     fib.10
	addi    $sp, $sp, $0
	lw      $ra, -1($sp)
	move    $t0, $v0
	sw      $ra, -1($sp)
	addi    $sp, $sp, $0
	jal     min_caml_print_int
	addi    $sp, $sp, $0
	lw      $ra, -1($sp)
	lw      $fp, 0($sp)
	lw      $ra, -1($sp)
	addi    $sp, $sp, $2
	hlt

