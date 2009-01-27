-- Simpcon Adresse für Digits: 0xff10
-- ! markiert Soll-Ergebnisse zum Vergleichen
addi $3, 0x3f
nop
nop
lsli $3, 2
nop
nop
addi $3, 3
nop
nop
lsli $3, 8
nop
nop
addi $3, 0x10

addi $4, 0x6 -- 7-Segment 4: 01100110
nop
nop
lsli $4, 4
nop
nop
addi $4, 0x6
stb $3, $4

addi $4, 0x4 -- 3: 01001111
nop
nop
lsli $4, 4
nop
nop
addi $4, 0xf
addi $3, 1 -- nächstes Digit adressieren
nop
nop
stb $3, $4

addi $4, 0x5 -- 2: 01011011
nop
nop
lsli $4, 4
nop
nop
addi $4, 0xb
nop
nop
addi $3, 1
nop
nop
stb $3, $4

addi $4, 0x06 -- 1:  00000110
addi $3, 1
xxx:
nop
nop
stb $3, $4
sb $4, 1
sb $2, 3
cb $6, 2
cb $1, 7
nop

loop:
	rjmpi loop -- damit wir nicht _irgendwas_ machen
