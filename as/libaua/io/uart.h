#define SC_UART 0xff20
#define SC_UART_STATUS 0xff20
#define SC_UART_DATA 0xff21

uart_write:
	nop
	ret

-- Params: address, length (in word)
-- Returns: void (undefined)
uart_read:

	!ldiw $20, SC_DIGITS
	!ldiw $21, 0xf
	!st $21, $20

	push $1
	push $2
	push $3
	push $4
	push $5
	push $10 -- Adresse, wohin das Zeug soll
	push $11 -- Anzahl an words zu lesen

	ldiw $1, SC_UART_STATUS
	ldiw $4, SC_UART_DATA

  loop_read:
	ldi $3, 2 -- Konstante 2
	ld $2, $1 -- UART Status in $2
	and $3, $2 -- Bit 0 in Status sagt, ob was zu lesen da
	brezi $3, loop_read -- nichts zu lesen => warten

	ld $2, $4 -- Daten von UART lesen
	stb $2, $10 -- Daten in SRAM speichern

	addi $10, 1 -- Adresse zum Speicher +1

  loop_read2: -- voll fad nochmal das selbe wie oben, damit
	ldi $3, 2 -- Konstante 2
	ld $2, $1 -- UART Status in $2
	and $3, $2 -- Bit 0 in Status sagt, ob was zu lesen da
	brezi $3, loop_read2 -- nichts zu lesen => warten

	ld $2, $4 -- Daten von UART lesen
	stb $2, $10 -- Daten in SRAM speichern


	ldiw $5, SC_DIGITS
	addi $5, 4
	st $2, $5

	addi $10, 1 -- Adresse zum Speicher +1
	addi $11, -1 -- wieder ein word weniger zu lesen

	addi $5, -1
	nop

	ldiw $24, 0
	st $24, $5
	!st $11, $5

	brnezi $11, loop_read -- solang wir noch lesen müssen, tun wir das brav

	pop $11
	pop $10
	pop $5
	pop $4
	pop $3
	pop $2
	pop $1
	ret
