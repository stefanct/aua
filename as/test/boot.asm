ldiw $fp, STACK_TOP
ldiw $sp, STACK_TOP

ldiw $16, SC_DIGITS

-- Größe von Image in ersten beiden Bytes von UART
ldiw $10, 0 -- UART Zielpointer für Daten
ldiw $11, 2 -- Anzahl bytes zu lesen

ldiw $2, uart_read -- Adresse von Funktion uart_read

call $2

ldiw $5, SC_DIGITS
addi $5, 1
ldiw $6, 0
ld $7, $6
st $7, $5

ldiw $10, 0 -- UART Datenpointer wieder laden

ld $11, $10 -- jetzt lesen wir soviel, wie das Image lang ist
ldiw $11, 5 -- zum Testen ohne SRAM
st $11, $16

call $2


addi $5, 1
ldiw $6, 2
st $6, $5

loop:
	rjmpi loop

#include libaua/stdlib.h
#include libaua/io/uart.h
#include libaua/io/digit.h
#include libaua/io/switches.h
