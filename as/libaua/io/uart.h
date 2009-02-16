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




!switch_loop:
!	ldiw $20, SC_SWITCHES
!	ld $21, $20
!	mov $22, $0
!	addi $22, 1
!	and $22, $21
!	brezi $22, switch_loop

!switch_loop2:
!	ld $21, $20
!	mov $22, $0
!	addi $22, 2
!	and $22, $21
!	brezi $22, switch_loop2

uart_loop:
	ldiw $20, SC_UART_STATUS
	ld $21, $20
	mov $22, $0
	addi $22, 2
	and $22, $21
	brezi $22, uart_loop

	ldiw $20, SC_UART_DATA
	ld $21, $20


	!stb $21, $10 -- Daten in SRAM speichern

	addi $10, 1 -- Adresse zum Speicher +1

	addi $11, -1 -- ein byte weniger zu lesen

	ldiw $25, SC_DIGITS
	addi $25, 3
	st $21, $25

	addi $25, 1
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
