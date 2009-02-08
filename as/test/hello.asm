#include libaua/io/uart.h

ldiw $1, SC_UART
mov $2, $1
addi $2, 1

#define MSG "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"

ldiw $3, MSG

loop:
	ld $10, $1
	ldi $11, 3
	and $10, $11
	brnezi $10, loop

	ld $4, $3
	st $4, $2
	addi $3, 1
	rjmpi loop
