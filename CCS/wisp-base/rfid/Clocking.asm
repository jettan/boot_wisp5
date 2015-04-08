;/**@file		Clocking.asm
;*	@brief		Sets the proper clocks for Tx and Rx
;*
;*	@author		Saman Naderiparizi, UW Sensor Systems Lab
;*	@created	3-10-14
;*
;*	@section	Command Handles
;*				-#TxClock , RxClock
;*/

;/INCLUDES----------------------------------------------------------------------------------------------------------------------------
    .cdecls C,LIST, "../globals.h"
    .cdecls C,LIST, "rfid.h"
	.def  TxClock, RxClock

; TX clock frequency: 12 MHz.
TxClock:
	MOV.B           #(0xA5), &CSCTL0_H                                            ; Write CSKEY password.
	MOV.W           #(DCORSEL|DCOFSEL_6), &CSCTL1                                 ; Set clocks to 24 MHz.
	MOV.W           #(SELA_0|SELM_3), &CSCTL2                                     ; Select  LFXTCTL as ACLK source and DCOCLK as MCLK source.
	BIS.W           #(SELS_3), &CSCTL2                                            ; Select DCOCLK as SMCLK source.
	MOV.W           #(DIVA_0|DIVS_1|DIVM_1), &CSCTL3                              ; Don't divide ACLK. Divide MCLK and SMCLK by 2 (12 MHz).
	BIS.W           #(MODCLKREQEN|SMCLKREQEN|MCLKREQEN|ACLKREQEN), &CSCTL6        ; Enable clock requests.

	RETA

; RX clock frequency: 16 MHz.
RxClock:
	MOV.B           #(0xA5), &CSCTL0_H                                            ;[] Write CSKEY password.
	MOV.W           #(DCORSEL|DCOFSEL_4), &CSCTL1                                 ;[] Set clocks to 16 MHz.
	MOV.W           #(SELA_0|SELM_3), &CSCTL2                                     ;[] Select  LFXTCTL as ACLK source and DCOCLK as MCLK source.
	BIS.W           #(SELS_3), &CSCTL2                                            ;[] Select DCOCLK as SMCLK source.
	MOV.W           #(DIVA_0|DIVS_0|DIVM_0), &CSCTL3                              ;[] Don't divide clock.
	BIS.W           #(MODCLKREQEN|SMCLKREQEN|MCLKREQEN|ACLKREQEN), &CSCTL6        ;[] Enable clock requests.
	
	RETA                                                                          ;[5]

	.end
