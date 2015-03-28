;/************************************************************************************************************************************
;*                                           PORT 1 ISR (Starting a Command Receive)
;*   Here starts the hard real time stuff.
;*   MCLK is 16 MHz (See Clocking.asm) -> 0.0625 us per cycle
;*   Entering ISR takes 6 cycles (4.5.1.5.1)
;*   Each BIT.B takes 5-1 cycles (4.5.1.5.4)
;*   Each JNZ or JZ takes 2 cycles regardless whether it is taken or not (4.5.1.5.3)
;*   Start this ISR at t = 0.375 us + wake up time (~4 us?) TODO: Find out  this exact wakeup time or why we have this gap.
;*   Listed instruction cycles are taken from MSP430FR5969 User Guide (SLAU367F).
;*
;*   Purpose:
;*   This ISR kicks in on a falling edge and tries to find the rising edge marking the end of the delimiter of a PREAMBLE/FRAME-SYNC.
;*   After that, we disable PORT1 interrupts and setup Timer0A0.
;*   During this preparation, some shenanigans happen, because we are already in data-0.
;*   Since we don't actually need to read data-0 for anything, we just wait a bit until we are past data-0.
;*   Unfortunately, preparation + delay takes too long and we are already inside RTCAL, which we DO need to measure the length of.
;*   So we reset the timer and add X clock cycles to make it look like the clock started at the start of RTCAL.
;*   After all that, we go back to sleep and wait for Timer0A0 to wake us up on a falling edge.
;*   An ASCII drawing of the situation can be found below:
;*
;*   |   data-0  |           RTCAL             |
;*   /-----\_____/------------------------\____/   - Wave form
;*
;*   ------------|--X--|---S                       - Instructions being executed.
;*               ^     ^
;*               ^     This is where we reset the timer.
;*               This point is where RTCAL should actually start.
;*
;*   TODO: Can we do this without going into RTCAL?
;*         Modify RX state machine so we get into Timer0A0_ISR during the PW of data-0 and get rid of RTCAL_OFFS in globals.h
;*         This will also get rid of the delimDelay and the need of resetting the clock.
;*         We might just have enough time to do that on 16 MHz (worst case with R420, we have 0.475*6.25 us = 47 clock cycles).
;*************************************************************************************************************************************

	.cdecls C, LIST, "../globals.h"
	.retain
	.retainrefs

RX_ISR:
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     badDelim                                    ;[2]
	
	;; ~11.5 us in
	
	; Official allowed delimiter range (EPCGlobal Gen2 spec states this should be +/- 5% of 12.5 us, which is 11.875 us - 13.125 us).
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     goodDelim                                   ;[2] t = ~11.875 us
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     goodDelim                                   ;[2] t = ~12.25 us (Impinj R1000)
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     goodDelim                                   ;[2] t = ~12.625 us
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     goodDelim                                   ;[2] t = ~13 us
	BIT.B   #PIN_RX, &PRXIN                             ;[4]
	JNZ     goodDelim                                   ;[2] t = ~13.375 us

; Delim is too short so go back to sleep.
badDelim:
	BIT.B   R15, R14                                    ;[]
	BIC     #CCIFG, &TA0CCTL0                           ;[] Clear the interrupt flag for Timer0A0 Compare (safety).
	CLR     &TA0R                                       ;[] Reset TAR value
	CLR     &(rfid.edge_capture_prev_ccr)               ;[] Clear previous value of CCR capture.
	CLR.B   &PRXIFG                                     ;[] Clear the Port 1 flag.
	RETI

; We found a delim ~12.5 us, now turn off PORT1 and prepare Timer0A0.
goodDelim:                                              ;[23]
	BIS.B   #PIN_RX, &PRXSEL0                           ;[5] Enable Timer0A0
	BIC.B   #PIN_RX, &PRXSEL1                           ;[5] Enable Timer0A0
	CLR.B   &PRXIE                                      ;[4] Disable the Port 1 Interrupt
	BIC     #(SCG1), 0(SP)                              ;[5] Enable the DCO to start counting
	PUSHM.A #1, R15                                     ;[2] Backup data of R15.
	MOV     #FORCE_SKIP_INTO_RTCAL, R15                 ;[2] Set R15 to 24.

delimDelay:                                             ;[103]
	DEC     R15                                         ;[2] Executed 24 times.
	JNZ     delimDelay                                  ;[2] Executed 24 times.
	POPM.A  #1, R15                                     ;[2] Restore data of R15.
	BIS.W   #(CM_2+CCIE), &TA0CCTL0                     ;[5] We don't want T0A0 to trigger on the falling edge of data-0, this is why we have a delimDelay.

startupT0A0_ISR:
	BIC     #CCIFG, &TA0CCTL0                           ;[5] Clear the interrupt flag for Timer0A0 Compare
	CLR     &TA0R                                       ;[4] ***Reset clock!***
	CLR     &(rfid.edge_capture_prev_ccr)               ;[4] Clear previous value of CCR capture
	CLR     &(rfid.edge_capture_prev_ccr)               ;[4] Reset previous edge capture time TODO: Is this needed since it's already been done in the line above?
	CLR.B   &PRXIFG                                     ;[4] Clear the Port 1 flag.
	
	ADD     #36, &TA0R                                  ;[5] Add number of cycles that have past between the real start of RTCAL and the TA0 reset. (should be 21 for R1000 and 35 for R420)
	RETI                                                ;[5] Return from interrupt.

;*************************************************************************************************************************************
; DEFINE THE INTERRUPT VECTOR ASSIGNMENT
;*************************************************************************************************************************************
	;.sect ".int36"                                     ; Port 1 Vector
	;.short  RX_ISR                                     ; This sect/short pair sets int02 = RX_ISR addr.
	.end
