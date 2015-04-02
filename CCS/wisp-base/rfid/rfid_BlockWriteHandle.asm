;/**@file		rfid_BlockWriteHandle.asm
;*	@brief
;* 	@details
;*
;*	@author		Aaron Parks, Justin Reina, UW Sensor Systems Lab
;*	@created
;*	@last rev
;*
;*	@notes		In a blockwrite, data is transmitted in the clear (not cover coded by RN16)
;*				BLOCKWRITE: {CMD [8], MEMBANK [2], WordPtr [6?], WordCount [8], Data [VAR], RN [16], CRC [16]}
;*
;*	@section
;*
;*	@todo		Show the blockwrite command bitfields here
;*  @todo		Add CRC check for R=>T command, even if it needs to be after-the-fact
;*  @todo		Figure out why using R12 doesn't work here...
;*/

   .cdecls C,LIST, "../globals.h"
   .cdecls C,LIST, "rfid.h"

R_bits      .set  R5
R_byteCount	.set  R12				;[0] Number of words in payload
R_scratch2	.set  R13
R_scratch1	.set  R14
R_scratch0	.set  R15

   	.ref cmd
	.def  handleBlockWrite
	.global RxClock, TxClock
	.sect ".text"

handleBlockWrite:

;Wait for first two bytes to come in. then memBank is in cmd[1].b7b6
waitOnBits_0:
	CMP     #16, R_bits             ;[2] Proceed when R_bits > 16
	JLO     waitOnBits_0            ;[2]

;Put Proper memBankPtr into WritePtr. Switch on Membank
calc_memBank:
	MOV.B	(cmd+1), R_scratch0     ;[3] load cmd byte 2 into R15. memBank is in b7b6 (0xC0)
	AND.B	#0xC0, R_scratch0       ;[2] mask of non-memBank bits, then switch on it to load corr memBankPtr
	RRA		R_scratch0              ;[1] move b7b6 down to b1b0
	RRA		R_scratch0              ;[1] move b7b6 down to b1b0
	RRA		R_scratch0              ;[1] move b7b6 down to b1b0
	RRA		R_scratch0              ;[1] move b7b6 down to b1b0
	RRA		R_scratch0              ;[1] move b7b6 down to b1b0
	RRA		R_scratch0              ;[1] move b7b6 down to b1b0

	MOV.B   R_scratch0, &(RWData.memBank) ;[] store the memBank


; Now wait until we have all bits to extract the WordPtr.
waitOnBits_1:
	CMP.W   #24, R_bits                   ;[2] while(bits<24)
	JLO     waitOnBits_1                  ;[2]

; Extract WordPtr.
calc_wordPtr:
	MOV.B 	(cmd+1), R_scratch0           ;[3] bring in top 6 bits into b5-b0 of R15 (wordCt.b7-b2)
	MOV.B 	(cmd+2), R_scratch1           ;[3] bring in bot 2 bits into b7b6  of R14 (wordCt.b1-b0)
	RLC.B	R_scratch1                    ;[1] pull out b7 from R14 (wordCt.b1)
	RLC.B	R_scratch0                    ;[1] shove it into R15 at bottom (wordCt.b1)
	RLC.B	R_scratch1                    ;[1] pull out b7 from R14 (wordCt.b0)
	RLC.B	R_scratch0                    ;[1] shove it into R15 at bottom (wordCt.b0)
	MOV.B	R_scratch0, R_scratch0        ;[1] mask wordPtr to just lower 8 bits
	MOV.B	R_scratch0, &(RWData.wordPtr) ;[] store the wordPtr


; Wait until we have all bits to extract WordCount.
waitOnBits_2:
	CMP.W   #32, R_bits                   ;[2] while(bits<32)
	JLO     waitOnBits_2                  ;[2]

calc_wordCnt:
	MOV.B 	(cmd+2), R_scratch0           ;[3] bring in top 6 bits into b5-b0 of R15 (wordCt.b7-b2)
	MOV.B 	(cmd+3), R_scratch1           ;[3] bring in bot 2 bits into b7b6  of R14 (wordCt.b1-b0)
	RLC.B	R_scratch1                    ;[1] pull out b7 from R14 (wordCt.b1)
	RLC.B	R_scratch0                    ;[1] shove it into R15 at bottom (wordCt.b1)
	RLC.B	R_scratch1                    ;[1] pull out b7 from R14 (wordCt.b0)
	RLC.B	R_scratch0                    ;[1] shove it into R15 at bottom (wordCt.b0)
	MOV.B	R_scratch0, R_scratch0        ;[1] mask wordPtr to just lower 8 bits
	MOV.B	R_scratch0, &(RWData.wordCnt) ;[] store the wordCnt

; Wait until we have the next byte of data to write.
waitOnBits_3:
	CMP.W   #64, R_bits                   ;[2]
	JLO     waitOnBits_3                  ;[2]

; TODO: Store wordCnt*Words instead of just one word.
store_Word:
	;Pull out Data and stuff into R14 (safe, R14 isn't used by RX_SM)
	MOV.B 	(cmd+3), R14			;[3] bring in top 6 bits into b5-b0 of R14 (data.b15-b10)
	MOV.B 	(cmd+4), R13			;[3] bring in mid 8 bits into b7-b0 of R13 (data.b9-b2)
	MOV.B 	(cmd+5), R12			;[3] bring in bot 2 bits into b7b6  of R12 (data.b1b0)

	RLC.B	R13						;[1]
	RLC.B	R14						;[1]
	RLC.B	R13						;[1]
	RLC.B	R14						;[1]
	RRC.B	R13						;[1]
	RRC.B	R13						;[1]

	RLC.B	R12						;[1]
	RLC.B	R13						;[1]
	RLC.B	R12						;[1]
	RLC.B	R13						;[1]

	SWPB	R14						;[1]
	BIS		R13, R14				;[] merge b15-b8(R14) and b7-b(R13) together into R14


;;;;;;;;;;;; OLD BLOCKWRITE SHIT
;waitOnBits_0:
;	CMP #32, R5; bit count is always in R5
;	JLO waitOnBits_0
;
;	;Now CMD[0]~CMD[3] should contain: {CMD_ID, (MEMBANK | WP), (WP | WC), (WC | DATA[0])}
;
;	;/------------------------------------------------------------------------/
;	; Extract word count and store in a CPU register
;	;/------------------------------------------------------------------------/
;
;	; Extract word count from CMD[2]~CMD[3]. Store as a byte count for convenience.
;	CLR.W R_scratch0
;	MOV.B &(cmd+3), R_scratch0;
;	CLR.W R_byteCount;
;	MOV.B &(cmd+2), R_byteCount;
;	RLC.B R_scratch0;
;	RLC.B R_byteCount;
;	RLC.B R_scratch0;
;	RLC.B R_byteCount; Now R_byteCount = wordCount
;	BIC #(0xFF00), R_byteCount; To make sure top byte is zeroed
;	RLA R_byteCount; Now R_byteCount = wordCount*2
;
;	;R_byteCount now contains (word count)*2
;	;Validate BC - set limit based on buffer size
;	MOV #CMDBUFF_SIZE, R_scratch0;
;	SUB #8, R_scratch0;
;	CMP R_byteCount, R_scratch0;
;	JGE skipByteCountCap; If R_scratch0 >= R_byteCount, we�ve got enough space and don�t have to adjust byteCount.
;	MOV R_scratch0, R_byteCount;


;skipByteCountCap:
;
;	;Todo: Should probably fail here if byteCount is too large to handle, instead of simply capping byteCount.
;
;	;/------------------------------------------------------------------------/
;	; Wait for byte number BC+8 (CMD[BC+7])
;	;/------------------------------------------------------------------------/
;
;	MOV R_byteCount, R_scratch0;
;	ADD #8, R_scratch0;
;	RLA R_scratch0; Multiply by 8
;	RLA R_scratch0;
;	RLA R_scratch0;
;
;waitOnBits_1:
;	CMP R_scratch0, R5;
;	JLO waitOnBits_1; while(R5<R_scratch0)
;
;	;Now CMD[BC+7] has arrived
;	;/------------------------------------------------------------------------/
;	; Future work: Check CRC over entire CMD buffer now, and include result of check in response to reader.
;	;/------------------------------------------------------------------------/
;
;	;/------------------------------------------------------------------------/
;	; Respond to reader
;	;/------------------------------------------------------------------------/
;
;	; Housekeeping: Save needed CPU registers in preparation for CRC16 call
;	PUSHM.A #1, R_byteCount;
;
;	;Load the Reply Buffer (rfidBuf)
;	;Load up function call, then transmit! bam!
;	MOV (rfid.handle), R_scratch0;[3] bring in the RN16
;	SWPB	R_scratch0 ;[1] swap bytes so we can shove full word out in one call (MSByte into dataBuf[0],...)
;	MOV R_scratch0, &(rfidBuf) ;[4] load the MSByte
;
;	;Calc CRC16! (careful, it will clobber R11-R15)
;	;uint16_t crc16_ccitt(uint16_t preload,uint8_t *dataPtr, uint16_t numBytes);
;	MOV #(rfidBuf), R13 ;[2] load &dataBuf[0] as dataPtr
;	MOV #(2), R14 ;[2] load num of bytes in ACK
;	MOV #ZERO_BIT_CRC, R12 ;[1]
;	CALLA	#crc16_ccitt ;[5+196]
;
;	;On return: R12 holds the CRC16 value.
;	;STORE CRC16
;	MOV.B	R12, &(rfidBuf+3) ;[4] store lower CRC byte first
;	SWPB	R12 ;[1] move upper byte into lower byte
;	MOV.B	R12, &(rfidBuf+2) ;[4] store upper CRC byte
;
;	CLRC
;	RRC.B	(rfidBuf)
;	RRC.B	(rfidBuf+1)
;	RRC.B	(rfidBuf+2)
;	RRC.B	(rfidBuf+3)
;	RRC.B	(rfidBuf+4)
;
;	;Set up to transmit reply
;haltRxSM_inWriteHandle:
;
;	;this should be the equivalent of the RxSM call in C Code. WARNING: if RxSM() ever changes, change it here too!!!!
;	DINT;[2]
;	NOP
;	CLR		&TA0CTL					;[4]
;
;	;Transmit timing delay
;	MOV #TX_TIMING_WRITE, R_scratch0 ;[1]
;	MOV #2000, R_scratch0;DEBUG!!!!!!!!!
;
;timing_delay_for_Write:
;	DEC R_scratch0; [1] while((X--)>0);
;	CMP #0XFFFF, R_scratch0 ;[1] 'when X underflows'
;	JNE timing_delay_for_Write ;[2]
;
;	;TRANSMIT (16pre,38tillTxinTxFM0 -> 54cycles)
;	MOV #rfidBuf, 	R12 ;[2] load the &rfidBuf[0]
;	MOV #(4), R13 ;[1] load into corr reg (numBytes)
;	MOV #1, R14	;[1] load numBits=1
;	MOV.B	#TREXT_ON,	R15 ;[3] load TRext (write always uses trext=1. wtf)
;
;	CALLA	#TxFM0 ;[5] call the routine
;
;	;TxFM0(volatile uint8_t *data,uint8_t numBytes,uint8_t numBits,uint8_t TRext);
;	;exit: state stays as Open!
;
;	;Housekeeping: Restore saved CPU registers from before CRC16 call
;	POPM.A #1, R_byteCount;
;
;	;/------------------------------------------------------------------------/
;	; Extract MEMBANK from middle of CMD[1] and store in register(?)
;	;/------------------------------------------------------------------------/
;
;	MOV.B &(cmd+1), R_scratch0;
;	RRC R_scratch0; ; R_scratch0 >>= 6;
;	RRC R_scratch0;
;	RRC R_scratch0;
;	RRC R_scratch0;
;	RRC R_scratch0;
;	RRC R_scratch0;
;	AND #0x0003, R_scratch0; Mask off extra bits
;	MOV.B R_scratch0, &(RWData.memBank);
;
;	;/------------------------------------------------------------------------/
;	; Shift majority of CMD buffer left by two bits to align data bytes
;	;/------------------------------------------------------------------------/
;
;	;Shift buffer between CMD[1] and CMD[BC+7]
;	MOV #2, R_scratch0; Iterate through the following loop twice
;outerShiftLoop:
;	MOV R_byteCount, R_scratch1 ;Compute last valid byte address
;	ADD #7, R_scratch1
;	MOV #0, R_scratch2 ; This scratch register will help shuttle the carry
;innerShiftLoop:
;	;BIT #1, R_scratch2; Move stored carry into actual carry
;	R;LC.B cmd(R_scratch1); Rotate left with carry
;	CL;R.W R_scratch2;
;	ADDC.B #0, R_scratch2; Store carry in R_scratch2
;	DEC R_scratch1;
;	JNZ innerShiftLoop; do...while(R_scratch1>0)
;	DEC R_scratch0;
;	JNZ outerShiftLoop; do...while(R_scratch0>0)
;
;	;Now CMD[1]~CMD[BC+6] contain:
;	;{WP, WC, DATA[0], �, DATA[N-1], RN16[MSB], RN16[LSB], CRC16[MSB], CRC16[LSB]}
;	;And note that CMD[BC+7] is now invalid/unused
;
;	;/------------------------------------------------------------------------/
;	; Check to see if handle matched
;	; TODO: This should be done before replying!
;	;/------------------------------------------------------------------------/
;
;	;First extract handle from CMD (spans two bytes)
;	MOV R_byteCount, R_scratch0
;	ADD #3, R_scratch0;
;	CLR.W R_scratch1;
;	MOV.B cmd(R_scratch0), R_scratch1;
;	SWPB R_scratch1;
;	INC R_scratch0;
;	MOV.B cmd(R_scratch0), R_scratch2;
;	BIS R_scratch2, R_scratch1;
;	;Now recovered handle is in R_scratch1. Leave if it�s not correct.
;	CMP R_scratch1, &(rfid.handle);
;	JNE exit_safely;
;
;	;/------------------------------------------------------------------------/
;	; Extract WP from CMD[1]
;	;/------------------------------------------------------------------------/
;
;	MOV &(cmd+1), &(RWData.wordPtr);
;
;	;/------------------------------------------------------------------------/
;	; Set up and call user callback function
;	;/------------------------------------------------------------------------/
;
;	MOV #(cmd+3), &(RWData.bwrBufPtr); Pointer to data buffer
;	MOV R_byteCount, &(RWData.bwrByteCount); Number of valid bytes in buffer
;
;	;Note: Membank and writePtr (a.k.a. wordPtr) were previously loaded into RWData.memBank.
;	;RWData struct now contains results of blockwrite decoding
;	TST &(RWData.bwrHook);
;	JZ skipHookCall;
;	MOV &(RWData.bwrHook), R_scratch0;
;	CALLA R_scratch0;
;skipHookCall:
;
;	;User callback has finished execution.
;
;	;/------------------------------------------------------------------------/
;	; This has been a successful BlockWrite. Signal appropriately
;	;/------------------------------------------------------------------------/
;
;	;Modify abort flag if necessary
;	BIT.B #(CMD_ID_BLOCKWRITE), &(rfid.abortOn); Should we abort on BlockWrite?
;	JZ skipAbort
;	BIS.B #1, &(rfid.abortFlag); By setting this bit we�ll abort correctly
;skipAbort:
;
;	;/------------------------------------------------------------------------/
;	; Prepare to leave BlockWriteHandle
;	;/------------------------------------------------------------------------/
;
exit_safely:
	; Tie up loose ends with timers and interrupts and such
	DINT;
	NOP;
	CLR &TA0CTL;
	RETA;

	; Switch back to RX clock mode

;	CALLA #RxClock	;Switch to Rx Clock




	.end
