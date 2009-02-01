-- Simpcon Adresse für Digits: 0xff10
-- ! markiert Soll-Ergebnisse zum Vergleichen

#include libaua/io/digit.h

ldiw $1, SC_DIGITS

ldiw $2, SEGS

ld $3, $2

st $3, $1

loop:
	rjmpi loop -- damit wir nicht _irgendwas_ machen
