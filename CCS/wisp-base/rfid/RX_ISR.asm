	.cdecls C, LIST, "../globals.h"
;/************************************************************************************************************************************
;* OLD DATA. TODO.                                     PORT 1 ISR (Starting a Command Receive)                                       *
;* Theory: RX ISR Will perform two different functions:                                                                              *
;*       - #1: RX ISR triggers on falling edge that indicates the beginning of a delimiter. It will then reset TA0R, set itself up to*
;*               trigger on rising edge for next interrupt (#2).                                                                     *
;*       - #2: RX ISR triggers on rising edge that indicates the end of a delimiter. It then sets up TA1 Capture for triggering the  *
;*               remaining data bits.																								 *
;*           Assumption: R5 != on entry. This is used for logic testing purposes.                                                    *
;*           Note: May trigger on power down from the reader                                                                         *
;*           Note: If incorrect delimiter is found, then the ISR sets itself up to look for another delimiter                        *
;* Timing Measurements: measurement is 4 less than actual value. rev0.3 board demos >99% of Delims(todo: verify this num with cRIO)  *
;*						within [11..15]us ->@12MHz->[132..186]+4.
;* 			-#1: startEntry: 		6+24+5 -> 35 -> 2.91us (ENTRY+PROC+EXIT)														 *
;* 			-#2: exitEntry:			6+36+5 -> 47 -> 3.92us (ENTRY+PROC+EXIT)														 *
;* 			-#X: incorrDelimEntry: 	6+32+5 -> 43 -> 3.58us (ENTRY+PROC+EXIT)														 *
;* Note: Only will exit LPM0/4 if a correct delimiter is found. Thus the main code doesn't execute until the delimiter is found.	 *
;* @todo	redocument the new Port1 ISR
;*************************************************************************************************************************************/

;Listed Timing is taken at the end of the cycles (i.e. it could be up to 4 cycles less!)
; would need a function generator to time this better to get sub instruction resolution.
	.retain
	.retainrefs

RX_ISR:
	;*********************************************************************************************************************************
	; TOO EARLY (DELIM <6us)
	;*********************************************************************************************************************************
	;;;;;;@Saman compatibility with other readers
	;; MCLK is 8MHz
	;; about 1us to enter the ISR
	;; For each of BIT.B 3 Cycles
	;; For each JNZ or JZ not taken 2 Cycles
	;; For JNZ or JZ taken 3 or 4 cycles
	;;
	;; jettan:
	;; Start this ISR at t = 0.75 us, MCLK is **16 MHz**!

	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 1.0625 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 1.375
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 1.6875 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 2 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 2.3125 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 2.625 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 2.9375 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 3.25 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 3.5625 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 3.875 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 4.1875 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 4.5 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 4.8125 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 5.125 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 5.4375 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 5.75 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 6.0625 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 6.375 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 6.6875 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 7 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 7.3125 us

	;;; Impinj R1000 Magic good delimiter time window.
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		goodDelim				;[2] t = 7.625 us

	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 7.9375 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 8.25 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 8.5625 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 8.875 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 9.1875 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 9.5 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 9.8125 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 10.125 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 10.4375 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 10.75 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 11.0625 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		badDelim				;[2] t = 11.375 us

	;;; Official allowed delimiter time window (EPC C1G2 spec states this should be +/- 5% of 12.5 us, which is 11.875 us - 13.125 us).
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		goodDelim				;[2] t = 11.6875 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		goodDelim				;[2] t = 12 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		goodDelim				;[2] t = 12.3125 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		goodDelim				;[2] t = 12.625 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		goodDelim				;[2] t = 12.9375 us
	BIT.B	#PIN_RX,	&PRXIN		;[3]
	JNZ		goodDelim				;[2] t = 13.25 us


	;*********************************************************************************************************************************
	; ELSE TOO LONG!! (anything past here was too long)
	;*********************************************************************************************************************************

badDelim:									; Go Back To Sleep.
	BIT.B	R15, R14
	BIC		#CCIFG, &TA0CCTL0				;[] clear the interrupt flag for Timer0A0 Compare (safety)
	CLR		&TA0R							;[] reset TAR value
	CLR		&(rfid.edge_capture_prev_ccr) 	;[] Clear previous value of CCR capture
	CLR.B	&PRXIFG							;[] clear the Port 1 flag.
	RETI

	;*********************************************************************************************************************************
	;Time To March Forward in the RX State Machine																					 *
	;*********************************************************************************************************************************
goodDelim:
;	BIS.W	#(CM_2+CCIE),&TA0CCTL0	;[5] Turn on Timer0A0 -> 4010h -> b14+b4 -> TA0CCTL0 |= CM1+CCIE (CM0-> CAPTURE ON FALLING EDGE,Inverted)
	; TODO The following shouldn't overwrite other bits in PRXSEL!?
	; Already interfered with the SPI A1 and MOV changed to BIS.B
	BIS.B		#PIN_RX,	 &PRXSEL0	;[4] Enable Timer0A0
	BIC.B		#PIN_RX,	 &PRXSEL1	;[4] Enable Timer0A0
	CLR.B		&PRXIE					;[4] Disable the Port 1 Interrupt
	BIC		#(SCG1), 0(SP)		    	;[] Enable the DCO to start counting.
	PUSHM.A #1,	R15
	MOV		#FORCE_SKIP_INTO_RTCAL, R15


delimDelay:
	DEC		R15
	JNZ		delimDelay
	POPM.A #1,	R15

	; Moved to here because the timer0A0 interrupt should not fire at falling edge of delay cycle which happen after Good Delimiter
	BIS.W	#(CM_2+CCIE),&TA0CCTL0
startupT0A0_ISR:
	BIC		#CCIFG, &TA0CCTL0		;[] clear the interrupt flag for Timer0A0 Compare
	CLR		&TA0R					;[] reset TAR value
	CLR		&(rfid.edge_capture_prev_ccr) ;[] Clear previous value of CCR capture
	CLR		&(rfid.edge_capture_prev_ccr) ;[] reset previous edge capture time
	CLR.B	&PRXIFG					;[5] clear the Port 1 flag.
	ADD 	#36, &TA0R				;The modified code seem to add some commands that increase the amount of waiting after finding the Good Delimiter.
	;We just need to wait for 1 Tari (7.14 us for R1000 and 6.25 us for R420!) which is equal to 50 cycles for R420 and 57-58 cycles for R1000 on 8MHz before counting the length of RTcal but instead in this code we wait for about
	;86 cycles and after that clear the TA0R. This is the reason we added #36 to TA0R.

	RETI

	;	//Now wait into data0 somewhere!

;*************************************************************************************************************************************
; DEFINE THE INTERRUPT VECTOR ASSIGNMENT																							 *
;*************************************************************************************************************************************
	;.sect ".int36"					; Port 1 Vector
	;.short  RX_ISR					; This sect/short pair sets int02 = RX_ISR addr.
	.end
