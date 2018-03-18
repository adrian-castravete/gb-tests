SECTION "Beginning", ROM0

INCLUDE "../common/gameboy.inc"

FRAMES_TO_SKIP	EQU $10

SECTION "High Ram", HRAM
		RSSET $FF80
beers		RB 1
controlByte	RB 1
skipByte	RB 1
scrollStep	RB 1

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
		ld [hl], %00011011

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

		; Start LCD
		ld a, $91
		ldh [LCD_CONTROL], a

		; Initialize RAM
		ld a, 99
		ldh [beers], a

		ld a, FRAMES_TO_SKIP
		ldh [skipByte], a

		ld a, 8
		ldh [scrollStep], a

		ld a, 112
		ldh [LCD_SCROLL_Y], a

		xor a
		ldh [controlByte], a

		inc a
		; Enable the Song timer
		ld [$ffff], a
		ei

		call WaitVBI

		ld bc, 0
		xor a

Song:		halt
		push af
		ld hl, skipByte
		dec [hl]
		ld a, [hl]
		cp 0
		jr z, .doSong
		pop af
		jp Song

.doSong:	pop af
		ld a, FRAMES_TO_SKIP
		ldh [skipByte], a

		ldh a, [LCD_SCROLL_Y]
		inc a
		ldh [LCD_SCROLL_Y], a
		ldh a, [scrollStep]
		dec a
		cp 0
		jr z, .lyrics
		ldh [scrollStep], a
		jp Song

.lyrics:	ld a, 8
		ldh [scrollStep], a

		ld hl, controlByte
		ld e, [hl]
		ld a, e
		cp 0
		jr nz, .skipFirst
		call FirstLine
.skipFirst:	dec e
		jr nz, .skipSecond
		call SecondLine
.skipSecond:	dec e
		jr nz, .skipThird
		call ThirdLine
		call TakeOneDown
.skipThird:	dec e
		jr nz, .skipFourth
		call FourthLine
.skipFourth:	dec e
		jr nz, .skipNewLine
		call NewLine
.skipNewLine:	ld hl, controlByte
		ld a, [hl]
		inc a
		cp 5
		jr nz, .resetCByte
		ld a, 0
.resetCByte:	ld [hl], a
		jp Song

PrintTile:
		ld hl, SCREEN_RAM
		add hl, bc
		ld [hl], a
		inc bc
		ret

PrintTiles:
.loopPrint:	call PrintTile
		inc a
		dec d
		jr nz, .loopPrint
		ret

PrintMsg:
.loopMessage:	ldi a, [hl]
		cp 0
		jr z, .endMessage
		push hl
		call PrintTile
		pop hl
		jr .loopMessage
.endMessage:	ret

ClearLine:
		push bc
.loopClear:	xor a
		call PrintTile
		ld a, c
		and $1f
		jr nz, .loopClear
		pop bc
		ret

NewLine:
		ld a, c
		and $e0
		adc $20
		jr nc, .noIncB
		inc b
.noIncB:	ld c, a

		ld a, b
		cp 4
		jr nz, .noResetB
		ld b, 0
.noResetB:	call ClearLine
		ret

PrintBeers:
		ldh a, [beers]
		or $80
		call PrintTile
		ret

StartLine:
		call PrintBeers
		ld a, 1
		ld d, 3
		call PrintTiles
		ld d, a
		ldh a, [beers]
		cp 1
		jr nz, .beerPlural
		ld a, d
		inc a
		call PrintTile
		jr .endPlural
.beerPlural:	ld a, d
		call PrintTile
		inc a
.endPlural:	inc a
		ld d, 4
		call PrintTiles
		ret

OnTheWall:
		ld hl, msgOnTheWall
		call PrintMsg
		ret

FirstLine:
		call StartLine
		call OnTheWall
		ld a, $0e
		call PrintTile
		call NewLine
		ret

SecondLine:
		call StartLine
		ld a, $0e
		call PrintTile
		call NewLine
		ret

ThirdLine:
		ldh a, [beers]
		cp 0
		jr z, .beersZero
		ld hl, msgTakeOneDown
		jr .endBeers
.beersZero:	ld hl, msgGoToTheStore
.endBeers:	call PrintMsg
		call NewLine
		ret

FourthLine:
		call StartLine
		call OnTheWall
		ld a, $1d
		call PrintTile
		call NewLine
		ret

TakeOneDown:
		ld hl, beers
		ld a, [hl]
		cp 0
		jr nz, .noResetBeers
		ld a, 100
.noResetBeers:	dec a
		ld [hl], a
		ret

INCLUDE "../common/common-gameboy.inc"

SECTION "Data", ROM0[$4000]
palettes:
incbin "data/99bottles.pal"

tileData:
incbin "data/99bottles.bin"

msgOnTheWall:
		DB $06, $0a, $0b, $05, $0c, $0d, $00

msgTakeOneDown:
		DB $0f, $10, $06, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $00

msgGoToTheStore:
		DB $1e, $1f, $20, $0b, $05, $21, $22, $05, $23, $24, $25, $26, $27, $28, $29, $22, $2a, $00

; vim:set noexpandtab shiftwidth=8 tabstop=8 nowrap filetype=z80:
