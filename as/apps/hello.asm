ldiw $20, SC_DIGITS
ldiw $21, 0xaa
st $21, $20


ldiw $1, SC_UART
mov $2, $1
addi $2, 1

#define MSG "Hello World"

ldiw $3, MSG

loop0:

ldiw $5, 0 -- Counter

loop:
	ld $10, $1
	ldi $11, 1
	and $10, $11
	brezi $10, loop

	mov $6, $3
	mov $7, $5
	ldi $8, 0xfe
	and $7, $8
	add $6, $7

	mov $7, $5
	ldi $8, 1
	and $7, $8
	ld $4, $6

	brezi $7, low_b

high_b:
	rjmpi foo

low_b:
	lsri $4, 8

foo:
	st $4, $2
	addi $5, 1

	ldi $8, 11 -- top value
	mov $6, $5
	sub $6, $8
	brezi $6, loop0

	rjmpi loop


#include libaua/io/digit.h
#include libaua/io/uart.h

