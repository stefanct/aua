_start:

	jmp $9		-- brez 0, $9
	ldi $2, 5	-- 0x00a2
	jmpl $5		-- 0x34a0
	brez $4, $7	-- 0x38e4

begin:
	ldi $3, begin	-- 0x00c3

--loop:
--	dec $6
--	nop
--	brnezi $6, loop
!	call loop
!	jmp loop
--	nop

