		dc.l $FFFF00
		dc.l EntryPoint
		
EntryPoint:
		move	#$2700, sr
		
;		move.b	$A10001, d0	; get hardware version
;		andi.b	#$F,d0
;		beq.s	SkipSecurity
;		move.l	#'SEGA', $A14000
;
;SkipSecurity:
		
MainProgramme: 	
		lea		$C00004, a0							; Control port to a0.
		lea		VDPRegSetupData(pc), a1				; Data to a1
		moveq	#(((VDPRegSetupData_End-VDPRegSetupData)/2)-1), d0; Items to copy
		
@setUpVDP:
		move.w	(a1)+, (a0)
		dbf		d0, @setUpVDP									; Loop until all registers have been set.
		
		move.l	#$C01E0000, (a0)
		move.w	#$0EEE, -4(a0)
		
		lea		Text(pc), a1										; Text location
		move.l	#$460E0003, d5									; VDP location
		bsr.s	WriteASCIIToScreen								; Write to screen.
		
		lea		Font(pc), a0
		moveq	#32, d1
		bsr.s	Load_Tiles

		bra.s	*
		
VDPRegSetupData:
		dc.w	$8016								; HInt on
		dc.w	$8174								; Display on, DMA on, VBI on, 28 row, Genesis mode.
		dc.w	$8230								; Plane A address
		dc.w	$8407								; Plane B address
		dc.w	$8700								; Backdrop is first colour in palette 0
		dc.w	$8C81								; No interlace, 40 tiles wide.
		dc.w	$8F02								; Auto inc is 2
		dc.w	$9001								; Plane size is 64x32
VDPRegSetupData_End: 


Load_Tiles:
;Loads tiles, a0 = in
;d0 = destination in vram1
;d1 = amount of tiles
;Breaks d0, d1, d2, d3, a0, a1
		lea 	$C00000, a1
;		bsr.s 	CalcOffset
		move.l	#$40200000, 4(a1)
		
@LoadLoop:
		moveq	#7, d3

@loop2:
		move.l (a0)+, (a1)
		dbf		d3, @loop2
		dbf 	d1, @LoadLoop
		rts
		
WriteASCIIToScreen:	
_NewLine	equ	$0A									; Byte to indicate a newline. 
_Space		equ	$0D									; Byte to indicate a space.
_End		equ	$7D									; Byte to indicate end of text.
VRAM_ASCII	equ	$00									; The offset to add to the VDP tile
		
LoadASCII:
		lea		$C00000, a0
		move.l	d5, 4(a0)

LoadText_Loop:
		moveq	#0,d1
		move.b	(a1)+,d1
		move.b	d1,d2

		cmp.b	#_Space,d2
		beq		LoadASCII_AddSpace
		cmp.b	#_End,d2
		bne		LoadASCII_Print

		rts

LoadASCII_Print:
;		cmp.b	#_NewLine,d2
;		beq		LoadASCII_NewLine

		move.b	d2,d1
;		add.w	#VRAM_ASCII,d1
		subi.w	#$0040, d1
		move.w	d1, (a0)
		
LoadASCII_Fix:
		bra		LoadText_Loop

;LoadASCII_NewLine:
;		add.l	#$800000,d5
;		bra		LoadASCII
		
LoadASCII_AddSpace:
;		cmp.b	#_Tab,d2
;		beq		LoadASCII_Fix

		add.l	#$800000,d5
		bra		LoadASCII
	
;CalcOffset:
;Calculate VDP command shits from an adress in d0.... breaks.... nothing!
;Optimization time!!!
;		moveq 	#0, d2
;		moveq 	#0, d3
;		move.w 	#$4000, d2
;		move.w 	d0, d3
;		and.w 	#$3FFF, d3
;		add.w 	d3, d2
;		and.w 	#$C000, d0
;		lsr.w 	#8, d0
;		lsr.w 	#6, d0 
;		swap 	d2
;		or.l 	d0, d2
;		move.l 	d2, 4(a1)
;		rts
		
Font:
		incbin	"font.bin"

; Load to $40080003
Text:
		dc.b	"HELLO WORLD THIS IS A TEST", _End
		
		END
