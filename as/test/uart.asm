#include libaua/io/digit.h
#include libaua/io/switches.h
#include libaua/io/uart.h

ldiw $1, SC_UART

ldiw $2, SC_DIGITS

ldiw $20, SC_SWITCHES

mov $3, $1
addi $3, 1 -- SC_UART + 1


ldi $4, 0x41
st $4, $3


loop:
	ld $10, $1
	st $10, $2

	ldi $12, 3
	and $10, $12
	brnezi $10, foo

	ld $11, $20
	st $11, $3

	rjmpi loop


foo:
	ldiw $15, SC_DIGITS
	addi $15, 1
	ldiw $16, 0xaa
	st $16, $15

rjmpi loop


EOF


	ld $5, $1
	st $5, $2
	st $4, $3
	rjmpi loop
