#include libaua/io/digit.h

ldiw $10, SC_DIGITS
ldiw $11, 0xaa

ldiw $3, foo
call $3

st $11, $10

loop:
	rjmpi loop

foo:
	addi $11, 1
	ret
