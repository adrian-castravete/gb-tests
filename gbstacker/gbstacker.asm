SECTION "Beginning", ROM0

INCLUDE "../common/gameboy.inc"

START_SPEED	EQU 100

SECTION "High Ram", HRAM
		RSSET $FF80
state		RB 1
speed		RB 1
stackTop	RB 1

score		RW 1
height		RW 1
targetHeight	RW 1
stack		RW 10

SECTION "VBlank Interrupt", ROM0[$40]
		nop
		reti

SECTION "START", ROM0[$100]
		nop
		jp main
INCLUDE "../common/nintendo.inc"

SECTION "Code", ROM0[$150]
main:
		; Stop LCD
		ld hl, LCD_CONTROL
		ld [hl], 0

		cp $11
		jr nz, .monoPalette
		ld de, palettes
		ld b, 8
		ld hl, BG_PALETTE_INDEX
		call SetupPalettesGBC
		ld hl, OBJ_PALETTE_INDEX
		call SetupPalettesGBC
		jr .eoPalette
.monoPalette:	ld hl, MGB_PALETTE_DATA
		ld a, %11100100
		ld c, 3
.loopmpal	ld [hli], a
		dec c
		jr nz, .loopmpal
.eoPalette:	ld bc, $2000
		ld de, VIDEO_RAM
		ld hl, tileData
.videoRamLoop:	ldi a, [hl]
		ld [de], a
		inc de
		dec bc
		ld a, b
		or c
		jr nz, .videoRamLoop

		; Initiaize memory
		call ResetInitial

		; Start LCD, BG, OBJ and set 16 height OBJ
		; also set BG Char Data at $8000
		ld a, $97
		ldh [LCD_CONTROL], a

		ld a, 1
		; Enable the frame timer
		ld [$ffff], a
		ei

MainLoop:	halt
		nop
		ld hl, .jpTable
		ld a, [state]
		add a, a
		adc l
		ld l, a
		sub l
		add h
		ld h, a
		jp hl

.jpTable:
		DW PlayingState
		DW GameOverState

PlayingState:
		jp MainLoop

GameOverState:
		jp MainLoop

ResetInitial:
		xor a
		ldh [state], a
		ld c, 16
		ld hl, score
.loop:		ld [hli], a
		dec c
		jr nz, .loop
		ldh [LCD_SCROLL_Y], a

		ld a, START_SPEED
		ldh [speed], a
		ret

INCLUDE "../common/common-gameboy.inc"

SECTION "Data", ROM0[$4000]
tileData:
incbin "data/gbstacker.bin"

palettes:
incbin "data/gbstacker.pal"

; vim:set noexpandtab shiftwidth=8 tabstop=8 nowrap filetype=z80:
