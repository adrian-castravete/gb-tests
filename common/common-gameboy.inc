;==============================================================================
; Wait for Vertical Blank
;==============================================================================
WaitVBI:
		push af
.loop:		ld a, [LCD_Y]
		cp $90
		jr nz, .loop
		pop af
		ret


;==============================================================================
; Setup all 8 palettes for either background or objects
;------------------------------------------------------------------------------
; Input:
;	HL - Register to change. Should be either BACKGROUND_PALETTE_INDEX or
;	     OBJECT_PALETTE_INDEX.
;	DE - Palette data location, which doesn't necessarily need to be
;	     first.
;	B  - Number of palette items to load.
; Output:
;	DE - Gets incremented by B * 4 * 2:
;	     • 4 - size in colours of palette item
;	     • 2 - size of colour
;==============================================================================
SetupPalettesGBC:
		push af
		push bc
		push hl

		ld [hl], $80			; Autoincrement palette counter starting at 0
		inc hl				; PALETTE_DATA is just one over PALETTE_INDEX

.loopPalette:	ld c, $08			; 8 means four colours of two bytes each
.loopColour:	ld a, [de]			; that autoincrement is Heaven sent
		ld [hl], a
		inc de
		dec c
		jr nz, .loopColour
		dec b
		jr nz, .loopPalette

		pop hl
		pop bc
		pop af
		ret


;==============================================================================
; Print the nibbles of A
;------------------------------------------------------------------------------
; Input:
;	A  - The value.
;	C  - Offset of the tile data.
;	HL - Location to be updated.
; Affects:
;	HL - Gets incremented twice.
;==============================================================================
PrintA:
		push bc

		ld b, a
		and $f0
		swap a
		adc c
		ldi [hl], a
		
		ld a, b
		and $0f
		adc c
		ldi [hl], a

		pop bc
		ret

; vim:set noexpandtab shiftwidth=8 tabstop=8 nowrap filetype=z80:
