SECTION "Beginning", ROM0

INCLUDE "../common/gameboy.inc"

WORK_RAM	EQU $C000
MAZE_DATA	EQU $C000

SECTION "Boot", ROM0[$100]
		nop
		jp main

INCLUDE "../common/nintendo.inc"

SECTION "Main", ROM0[$150]
main:
		; Stop LCD
		xor a
		ld [LCD_CONTROL], a

		ld de, palettes
		ld b, 8
		ld hl, BG_PALETTE_INDEX
		call SetupPalettesGBC
		ld hl, OBJ_PALETTE_INDEX
		call SetupPalettesGBC
		call CopyTiles

		; ld a, 48
		; ld [LCD_SCROLL_X], a
		; ld a, 56
		; ld [LCD_SCROLL_Y], a

		call GenerateMaze

		; Start LCD
		ld a, $91
		ld [LCD_CONTROL], a

.loop:		jr .loop


GenerateMaze:
		call .initializeRam

		ld b, 42
		ld c, 42

		; Check nearby blocks for advancement possibilities
		ld hl, 0

		; Check to see if left block is empty
		ld a, b
		cp 0
		jr z, .edgeLeft
		dec b
		call .gmFree
		jr nz, .blockedLeft
		; Hurray, empty left
		ld a, h
		or 1
		ld h, a
		; otherwise
.blockedLeft:	inc b
.edgeLeft:

		; Check to see if upper block is empty
		ld a, c
		cp 0
		jr z, .edgeUp
		dec c
		call .gmFree
		jr nz, .blockedUp
		; Hurray, empty up
		ld a, h
		or 2
		ld h, a
		; otherwise
.blockedUp:	inc c
.edgeUp:

		; Check to see if right block is empty
		ld a, b
		cp 84
		jr z, .edgeRight
		inc b
		call .gmFree
		jr nz, .blockedRight
		; Hurray, empty right
		ld a, h
		or 4
		ld h, a
		; otherwise
.blockedRight:	dec b
.edgeRight:

		; Check to see if lower block is empty
		ld a, c
		cp 84
		jr z, .edgeDown
		inc c
		call .gmFree
		jr nz, .blockedDown
		; Hurray, empty down
		ld a, h
		or 8
		ld h, a
		; otherwise
.blockedDown:	dec c
.edgeDown:

		ld a, h
		push hl
		ld hl, SCREEN_RAM
		ld c, 16
		call PrintA
		pop hl

		; WIP

		ret

.initializeRam:
		ld hl, WORK_RAM
		ld bc, 85 * 85

.loop:		xor a
		ldi [hl], a
		dec bc
		ld a, b
		or c
		jr nz, .loop

		ret

.gmPosition:
		push bc

		ld de, 0
		ld a, c
		or 0
		jr z, .lbl1
		xor a
.lbl2:		add 85
		jr nc, .lbl3
		inc d
.lbl3:		dec c
		jr nz, .lbl2
.lbl1:		add b
		jr nc, .lbl4
		inc d
.lbl4:		ld e, a

		pop bc
		ret

.gmFree:
		call .gmPosition
		ld a, [de]
		and $0f
		ret


CopyTiles:
		ld bc, $1000
		ld de, tileData
		ld hl, VIDEO_RAM

.loop:		ld a,[de]
		ldi [hl], a
		inc de
		dec bc
		ld a, b
		or c
		jr nz, .loop
		ret

Random:
		ld a, [randomSeed]
		ld b, a

		rrca
		rrca
		rrca
		xor $1f

		add b
		sbc 255

		ld [randomSeed], a
		ret

randomSeed:
		DB 42

INCLUDE "../common/common-gameboy.inc"

SECTION "Data", ROM0[$4000]
palettes:
INCBIN "data/tiles.pal"

tileData:
INCBIN "data/tiles.bin"

; vim:set noexpandtab shiftwidth=8 tabstop=8 nowrap filetype=z80:
