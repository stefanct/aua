#include libaua/io/digit.h

ldiw $1, SC_DIGITS

ldiw $2, SEGS
mov $6, $2

ldi $4, 10 -- Top value

count_0:
	ldi $3, 0 -- Counter

count:
	mov $5, $4 -- counter schon bei top? Dann wieder auf 0 setzen
	sub $5, $3
	brezi $5, count_0

	nop
	nop
	mov $6, $2 -- Digit aus Array suchen
	add $6, $3
	nop
	nop

	st $3, $1 -- Wert auf Digit schreiben

	addi $3, 1 -- Counter erhöhen

rjmpi count


ldiw $10, 0xffff
wait:
	addi $10, -1
	brezi $10, wait

loop:
	rjmpi loop -- damit wir nicht _irgendwas_ machen
