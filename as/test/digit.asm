-- Simpcon Adresse für Digits: 0xff10
-- ! markiert Soll-Ergebnisse zum Vergleichen
ldi $3, 0xff ! 0x1fe1
lsli $3, 8 ! 0xc101
addi $3, 0x10 ! 0x6201

ldi $4, 0x66 -- 7-Segment 4: 01100110
stb $3, $4

ldi $4, 0x4f -- 3: 01001111
addi $3, 1 -- nächstes Digit adressieren
stb $3, $4

ldi $4, 0x5b -- 2: 01011011
addi $3, 1
stb $3, $4

ldi $4, 0x06 -- 1:  00000110
addi $3, 1
xxx:
stb $3, $4

loop:
	rjmpi loop -- damit wir nicht _irgendwas_ machen
