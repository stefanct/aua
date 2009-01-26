-- Simpcon Adresse für Digits: 0xff10
-- ! markiert Soll-Ergebnisse zum Vergleichen
addi $3, 0x3f
nop
lsli $3, 2
nop
addi $3, 3
lsli $3, 6
addi $3, 0x10

addi $4, 0x6 -- 7-Segment 4: 01100110
lsli $4, 4
addi $4, 0x6
stb $3, $4

addi $4, 0x4 -- 3: 01001111
lsli $4, 4
addi $4, 0xf
addi $3, 1 -- nächstes Digit adressieren
stb $3, $4

addi $4, 0x5 -- 2: 01011011
lsli $4, 4
addi $4, 0xb
addi $3, 1
stb $3, $4

addi $4, 0x06 -- 1:  00000110
addi $3, 1
xxx:
stb $3, $4
sb $4, 1
sb $2, 3
cb $6, 2
cb $1, 7
nop

loop:
	rjmpi loop -- damit wir nicht _irgendwas_ machen
