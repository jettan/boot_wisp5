;/**@file		Clocking.asm
;*	@brief		Sets the proper clocks for Tx and Rx
;*
;*	@author		Saman Naderiparizi, UW Sensor Systems Lab
;*	@created	3-10-14
;*
;*
;*	@section	Command Handles
;*				-#TxClock , RxClock
;*/

;/INCLUDES----------------------------------------------------------------------------------------------------------------------------
    .cdecls C,LIST, "../globals.h"
    .cdecls C,LIST, "rfid.h"
	.def  TxClock, RxClock

;;; Switch to TX frequency (10.5 MHz)
TxClock:
	MOV.B           #(0xA5), &CSCTL0_H                                            ;CSCTL0_H = 0xA5
	MOV.W           #(DCORSEL|DCOFSEL_6), &CSCTL1 ;
	MOV.W           #(SELA_0|SELM_3), &CSCTL2     ;
	BIS.W           #(SELS_3), &CSCTL2
	MOV.W           #(DIVA_0|DIVS_1|DIVM_1), &CSCTL3 ;
	BIS.W           #(MODCLKREQEN|SMCLKREQEN|MCLKREQEN|ACLKREQEN), &CSCTL6

	RETA


;;; Switch to RX frequency (16 MHz)
RxClock:
	MOV.B           #(0xA5), &CSCTL0_H                                            ;CSCTL0_H = 0xA5
	MOV.W           #(DCORSEL|DCOFSEL_4), &CSCTL1                                 ;CSCTL1 = DCORSEL + DCOFSEL_4
	MOV.W           #(SELA_0|SELM_3), &CSCTL2                                     ;CSCTL2 = SELA_0 + SELM_3
	BIS.W           #(SELS_3), &CSCTL2                                            ;CSCTL2 |= SELS_3
	MOV.W           #(DIVA_0|DIVS_0|DIVM_0), &CSCTL3                              ;CSCTL3 = DIVA_0 + DIVS_0 + DIVM_0
	BIS.W           #(MODCLKREQEN|SMCLKREQEN|MCLKREQEN|ACLKREQEN), &CSCTL6
	
	RETA

	.end
