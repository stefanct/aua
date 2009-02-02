not $1, $0
ldi $2, 123
stb $2, $1
addi $2, 1
addi $2, 1
nop
nop
nop
ldb $3, $1
loop:
	addi $3, 1
	addi $3, 1
--	rjmpi loop
