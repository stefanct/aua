ldi $0, 23
mov $1, $0
mov $3, $0
mov $2, $0
nop
nop
nop
ldi $1, 23
mov $1, $1
mov $3, $1
mov $2, $1

loop:
	addi $1, 3
	addi $1, 3
	addi $1, 3
	addi $1, 3
	addi $1, 3
	rjmpi loop
