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

	!push $1
	!push $2
	!push $3
	!push $4
	!push $5
	!push $10 -- Adresse, wohin das Zeug soll
	!push $11 -- Anzahl an words zu lesen

	!ldiw $21, SC_UART_STATUS
	!ldiw $24, SC_UART_DATA

  loop_read:
	ldi $23, 2 -- Konstante 2
	!ld $22, $21 -- UART Status in $2
	ldiw $22, 2 -- nochmal 2, zum Debuggen ohne UART
	and $23, $22 -- Bit 0 in Status sagt, ob was zu lesen da
	brezi $23, loop_read -- nichts zu lesen => warten

	!ld $22, $24 -- Daten von UART lesen
	ldiw $22, 7 -- fix ohne UART
	stb $22, $10 -- Daten in SRAM speichern

	addi $10, 1 -- Adresse zum Speicher +1

	addi $11, -1 -- ein byte weniger zu lesen

	ldiw $25, SC_DIGITS
	addi $25, 4
	st $22, $25

	addi $25, -1
	st $11, $25

	brnezi $11, loop_read -- solang wir noch lesen müssen, tun wir das brav

	!pop $11
	!pop $10
	!pop $5
	!pop $4
	!pop $3
	!pop $2
	!pop $1
	ret
