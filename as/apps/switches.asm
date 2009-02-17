#include libaua/io/switches.h

ldiw $1, SC_SWITCHES

loop:
	ld $2, $1
	not $2, $2
	st $2, $1
	rjmpi loop
