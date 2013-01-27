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
		
		moveq	#0, d1											; Clear d1.
		
@infLoop:
		bsr.s	@delayForALongTime								; Cause a ton of delay.

		add.w	#$2, d1											; Increase squelcher.
		move.l	#$C0000000, (a0)
		move.w	d1, -4(a0)

		bra.s	@infLoop
		
@delayForALongTime:
		move.l	#$1FFFFFF, d0

@delayLoop:
		nop
		dbf		d0, @delayLoop									; Keep looping.

		rts
		
VDPRegSetupData:
		dc.w	$8016								; HInt on
		dc.w	$8134								; Display on, DMA on, VBI on, 28 row, Genesis mode.
		dc.w	$8230								; Plane A address
		dc.w	$8407								; Plane B address
		dc.w	$8700								; Backdrop is first colour in palette 0
		dc.w	$8C81								; No interlace, 40 tiles wide.
		dc.w	$8F02								; Auto inc is 2
		dc.w	$9001								; Plane size is 64x32
VDPRegSetupData_End: 
		
		END
