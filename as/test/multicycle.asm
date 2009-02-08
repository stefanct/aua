#include libaua/io/digit.h

ldiw $1, 0xfffe
ldi $2, 2
st $2, $1

ldiw $1, 0xffff
ldi $2, 0xaa
st $2, $1

nop
nop
nop
nop

ld $5, $1

ldiw $10, SC_DIGITS
st $5, $10

loop:
	rjmpi loop
