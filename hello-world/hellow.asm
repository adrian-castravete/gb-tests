	.include "../common/gameboy.inc"

	.name "TEST"
	.ramsize 2
	.cartridgetype 2

	.asciitable
	map " " = 0
	map "a" to "z" = 1
	map "," = 27
	map "!" = 28
	map "." = 29
	.enda

	.memorymap
	slotsize $4000
	defaultslot 0
	slot 0 $0000
	slot 1 $4000
	.endme

	.rombanksize $4000
	.rombanks 2

	.bank 0 slot 0
	.org $100
	nop
	jr main
	.include "../common/nintendo.inc"
	.org $150
main:
	; Stop LCD
	xor $01
	ld (LCD_CONTROL), a

	ld de, backgroundPalette
	ld hl, BG_PALETTE_INDEX
	ld b, 8
	call setupPalettesGBC
	call copyFontToVideoRam

	ld de, message
	ld hl, SCREEN_RAM + $40
	call writeMessage

	ld a, $91
	ld (LCD_CONTROL), a

-	jr -

copyFontToVideoRam:
	push bc
	push de
	push hl

	ld bc, $1000
	ld de, fontData
	ld hl, VIDEO_RAM

-	ld a,(de)
	ldi (hl), a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, -

	pop hl
	pop de
	pop bc
	ret

writeMessage:
	push bc
	push de
	push hl

	ld bc, $20

-	ld a, (de)
	cp $fe
	jr nz, +
	call skipLine
	inc de
	jr -
+	cp $ff
	jr z, ++
	ldi (hl), a
	inc de
	jr -

++	pop hl
	pop de
	pop bc
	ret

skipLine:
	push af

-	inc hl
	ld a, l
	and $1f
	jr nz, -

	pop af
	ret

	.include "../common/common-gameboy.inc"

message:
	.asc "hello, world!"
	.db $fe
	.db $fe
	.asc "the quick brown fox"
	.db $fe
	.asc "jumps over the lazy"
	.db $fe
	.asc "dog."
	.db $ff

backgroundPalette:
	.dw $0000, $2800, $5540, $7eaa
	.dw $0000, $2800, $5540, $7eaa
	.dw $0000, $2800, $5540, $7eaa
	.dw $0000, $2800, $5540, $7eaa
	.dw $0000, $2800, $5540, $7eaa
	.dw $0000, $2800, $5540, $7eaa
	.dw $0000, $2800, $5540, $7eaa
	.dw $0000, $2800, $5540, $7eaa

	.bank 1 slot 1
	.org 0
fontData:
	.incbin "data/font.bin"

; vim:set noexpandtab shiftwidth=8 tabstop=8 nowrap filetype=asm:
