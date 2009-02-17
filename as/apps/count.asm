#include libaua/io/digit.h

ldiw $1, SC_DIGITS

ldiw $2, SEGS

ldi $4, 10 -- Top value

count_0:
	ldi $3, 0 -- Counter
	ldiw $20, 10 -- runterzählen wegen brezi-Bug

count:
	mov $5, $4 -- counter schon bei top? Dann wieder auf 0 setzen
	muli $5, 2 -- wollte den mal testen :)
	sub $5, $3
	nop -- das wirklich so notwendig?
	brezi $5, count_0

	mov $6, $2 -- Digit aus Array suchen
	add $6, $3
	ld $7, $6

	st $7, $1 -- Wert auf Digit schreiben

	addi $3, 2 -- Counter erhöhen


	ldiw $10, 0x5

wait:


!rjmpi count

	ldiw $11, 0xffff
wait_0:
	addi $11, -1

	ldiw $12, 0xf
wait_1:
	addi $12, -1
	brnezi $12, wait_1

	brnezi $11, wait_0

	addi $10, -1
	brnezi $10, wait

rjmpi count

loop:
	rjmpi loop -- damit wir nicht _irgendwas_ machen
