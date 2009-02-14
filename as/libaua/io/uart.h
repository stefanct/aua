#define SC_UART 0xff20
#define SC_UART_STATUS 0xff20
#define SC_UART_DATA 0xff21

-- Params: address, length (in word)
-- Returns: void (undefined)
uart_read:

	ldiw $20, SC_DIGITS
	ldiw $21, 0xf
	st $21, $20

	push $1
	push $2
	push $3
	push $4
	push $10 -- Adresse, wohin das Zeug soll
	push $11 -- Anzahl an words zu lesen

	ldiw $1, SC_UART_STATUS
	ldiw $4, SC_UART_DATA
  loop_read:
	ldi $3, 1 -- Konstante 1
	ld $2, $1 -- UART Status in $2
	and $3, $2 -- Bit 0 in Status sagt, ob was zu lesen da
	brezi $3, loop_read -- nichts zu lesen => warten

	ld $2, $4 -- Daten lesen
	st $2, $10 -- Daten speichern

	ldiw $5, SC_DIGITS
	st $2, $5

	addi $10, 2 -- Adresse zum Speicher +2
	addi $11, -1 -- wieder ein word weniger zu lesen

	brnezi $11, loop_read -- solang wir noch lesen müssen, tun wir das brav

	pop $11
	pop $10
	pop $4
	pop $3
	pop $2
	pop $1
	ret
