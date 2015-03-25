	.cdecls C, LIST, "../globals.h"
;/************************************************************************************************************************************
;* TODO.                                     PORT 1 ISR (Starting a Command Receive)                                                 *
;* @todo	Redocument this whole ISR.
;*************************************************************************************************************************************/

; Listed timing is taken from MSP430FR5969 User Guide (SLAU367E).
	.retain
	.retainrefs

RX_ISR:
	;; MCLK is 16 MHz (See Clocking.asm) -> 0.0625 us per cycle
	;; Entering ISR takes 6 cycles (4.5.1.5.1)
	;; Each BIT.B takes 5-1 cycles (4.5.1.5.4)
	;; Each JNZ or JZ takes 2 cycles regardless whether it is taken or not (4.5.1.5.3)
	;; Start this ISR at t = 0.375 us + wake up time (~4 us?) TODO: Find out exact wakeup time.

	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		badDelim				;[2] t =

	;; ~11.5 us in

	;; Official allowed delimiter time window (EPC C1G2 spec states this should be +/- 5% of 12.5 us, which is 11.875 us - 13.125 us).
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		goodDelim				;[2] t = ~11.875 us
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		goodDelim				;[2] t = ~12.25 us (Impinj R1000)
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		goodDelim				;[2] t = ~12.625 us
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		goodDelim				;[2] t = ~13 us
	BIT.B	#PIN_RX,	&PRXIN		;[4]
	JNZ		goodDelim				;[2] t = ~13.375 us

badDelim:									; Go Back To Sleep.
	BIT.B	R15, R14                        ;[]
	BIC		#CCIFG, &TA0CCTL0				;[] Clear the interrupt flag for Timer0A0 Compare (safety).
	CLR		&TA0R							;[] Reset TAR value
	CLR		&(rfid.edge_capture_prev_ccr) 	;[] Clear previous value of CCR capture.
	CLR.B	&PRXIFG							;[] Clear the Port 1 flag.
	RETI

	;*********************************************************************************************************************************
	;Time To March Forward in the RX State Machine																					 *
	;*********************************************************************************************************************************
goodDelim:                                ;[23]
	; TODO The following shouldn't overwrite other bits in PRXSEL!?
	BIS.B   #PIN_RX, &PRXSEL0             ;[5] Enable Timer0A0
	BIC.B   #PIN_RX, &PRXSEL1             ;[5] Enable Timer0A0
	CLR.B   &PRXIE                        ;[4] Disable the Port 1 Interrupt
	BIC     #(SCG1), 0(SP)                ;[5] Enable the DCO to start counting
	PUSHM.A #1, R15                       ;[2] Backup data of R15.
	MOV     #FORCE_SKIP_INTO_RTCAL, R15   ;[2] Set R15 to 24.

delimDelay:                               ;[103]
	DEC		R15                           ;[2] Executed 24 times.
	JNZ		delimDelay                    ;[2] Executed 24 times.
	POPM.A #1,	R15                       ;[2] Restore data of R15.

	; Moved to here because the timer0A0 interrupt should not fire at falling edge of delay cycle which happen after Good Delimiter
	BIS.W	#(CM_2+CCIE),&TA0CCTL0        ;[5]

startupT0A0_ISR:                          ;[21] cycles = 1.3125 us
	BIC		#CCIFG, &TA0CCTL0		      ;[5] Clear the interrupt flag for Timer0A0 Compare
	CLR		&TA0R					      ;[4] ***Reset clock!***
	CLR		&(rfid.edge_capture_prev_ccr) ;[4] Clear previous value of CCR capture
	CLR		&(rfid.edge_capture_prev_ccr) ;[4] Reset previous edge capture time TODO: Is this needed since it's already been done in the line above?
	CLR.B	&PRXIFG					      ;[4] Clear the Port 1 flag.


	ADD 	#36, &TA0R				      ;[5] The modified code seem to add some commands that increase the amount of waiting after finding the Good Delimiter.
	;;We just need to wait for 1 Tari (7.14 us for R1000 and 6.25 us for R420!) which is equal to 100 cycles for R420 and 114-115 cycles for R1000 on 8MHz before counting the length of RTcal but instead in this code we wait for about
	;;86 cycles (?) and after that clear the TA0R. This is the reason we added #36 to TA0R.

	RETI                                  ;[5]

	;; We are 153 cycles (9.5625 us) past delimiter.
	;	//Now wait into data0 somewhere!

;*************************************************************************************************************************************
; DEFINE THE INTERRUPT VECTOR ASSIGNMENT																							 *
;*************************************************************************************************************************************
	;.sect ".int36"					; Port 1 Vector
	;.short  RX_ISR					; This sect/short pair sets int02 = RX_ISR addr.
	.end
