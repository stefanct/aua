#include libaua/io/digit.h

ldiw $1, SEGS

ldiw $10, SC_DIGITS
ldiw $11, 0xa

ldiw $3, foo
rjmpi foo

lala:

	addi $10, 1
	st $11, $10

loop:
	rjmpi loop

foo:
	addi $11, -1
	st $11, $10
	brnezi $11, foo
	rjmpi lala
