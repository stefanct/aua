--ldiw $1, bla
--stb $2, $1

ldiw $1, addr
ld $2, $1
nop
ldi $3, 0xff
not $3, $3
and $2, $3
nop
ldb $2, $1
loop:
	rjmpi loop

#define bla {0x1234}
#define addr 0x802C
