ldi $1, 1
not $1, $1
ldi $2, 15
stb $2, $1
ldb $3, $1

loop:
rjmpi loop

nop
nop
nop
ldb $3, $1
addi $3, 1
addi $3, 1
