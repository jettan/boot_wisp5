#include "wisp-base.h"

#define SIZE_ADDR     0x1900
#define ADDRESS_ADDR_HI  0x1902
#define ADDRESS_ADDR_LO  0x1904

WISP_dataStructInterface_t wispData;


/** 
 * This function is called by WISP FW after a successful ACK reply
 *
 */
void my_ackCallback (void) {
	asm(" NOP");
}

/**
 * This function is called by WISP FW after a successful read command
 *  reception
 *
 */
void my_readCallback (void) {
	asm(" NOP");
}

/**
 * This function is called by WISP FW after a successful write command
 *  reception
 *
 */
void my_writeCallback (void) {


	// Upper byte of written data.
	uint8_t hi = (wispData.writeBufPtr[0] >> 8)  & 0xFF;

	// Size of data received.
	if (hi == 0xFD) {
		(* (uint8_t *) (SIZE_ADDR)) = (wispData.writeBufPtr[0])  & 0xFF;
	} else if (hi == 0xFE) {
		(* (uint8_t *) (ADDRESS_ADDR_HI)) = (wispData.writeBufPtr[0])  & 0xFF;
	} else if (hi == 0xFF) {
		(* (uint8_t *) (ADDRESS_ADDR_LO)) = (wispData.writeBufPtr[0])  & 0xFF;
	// End of line reached.
	} else if (hi == 0xCC) {
		// Do nothing.
		asm("NOP");
	// Data with packet number.
	} else if (hi < 0x43) {
		uint16_t address = (* (uint16_t *) (ADDRESS_ADDR_HI));
		(* (uint8_t *) (address + hi)) = (wispData.writeBufPtr[0])  & 0xFF;
	}


	// Lower byte of written data.
	wispData.epcBuf[9]  = (wispData.writeBufPtr[0] >> 8)  & 0xFF;
	wispData.epcBuf[10] = (wispData.writeBufPtr[0])  & 0xFF;
}

/** 
 * This function is called by WISP FW after a successful BlockWrite
 *  command decode

 */
void my_blockWriteCallback  (void) {
	asm(" NOP");
}

/**
 * This implements the user application and should never return
 *
 * Must call WISP_init() in the first line of main()
 * Must call WISP_doRFID() at some point to start interacting with a reader
 */
void main_boot(void) {

	WISP_init();


	/*
	// Configure MPU.
	MPUCTL0  = MPUPW;				// Write PWD to access MPU registers.
	MPUSEGB1 = 0x0FF8;
	MPUSEGB2 = 0x1000;				// Borders are assigned to segments.

	// Segment 1 - R/W/X
	// Segment 2 - R/X
	// Segment 3 - R/W/X
	MPUSAM = (MPUSEG1RE | MPUSEG1WE | MPUSEG1XE | MPUSEG2RE | MPUSEG2XE | MPUSEG3RE | MPUSEG3WE | MPUSEG3XE);
	MPUCTL0 = MPUPW | MPUENA | MPUSEGIE;         // Enable MPU

	 */

	// Register callback functions with WISP comm routines
	WISP_registerCallback_ACK(&my_ackCallback);
	WISP_registerCallback_READ(&my_readCallback);
	WISP_registerCallback_WRITE(&my_writeCallback);
	WISP_registerCallback_BLOCKWRITE(&my_blockWriteCallback);

	// Get access to EPC, READ, and WRITE data buffers
	WISP_getDataBuffers(&wispData);

	// Set up operating parameters for WISP comm routines
	WISP_setMode( MODE_READ | MODE_WRITE | MODE_USES_SEL);
	WISP_setAbortConditions(CMD_ID_READ | CMD_ID_WRITE /*| CMD_ID_ACK*/);

	// Initialize FRAM.
	FRAM_init();


	// Set up EPC
	wispData.epcBuf[0] = 0x00; // WISP version
	wispData.epcBuf[1] = 0x00; // WISP UUID
	wispData.epcBuf[2] = 0x00; // WISP UUID
	wispData.epcBuf[3] = 0x00; // WISP UUID
	wispData.epcBuf[4] = 0x00; // WISP UUID
	wispData.epcBuf[5] = 0x00; // WISP UUID
	wispData.epcBuf[6] = 0x00; // RFID Status/Control
	wispData.epcBuf[7] = 0x00; // RFID Status/Control
	wispData.epcBuf[8] = 0x00; // RFID Status/Control
	wispData.epcBuf[9] = 0xde; // RFID Status/Control
	wispData.epcBuf[10]= 0xad; // RFID Status/Control
	wispData.epcBuf[11]= 0x00; // RFID Status/Control

	BITSET(PLED1OUT, PIN_LED1);

	// Talk to the RFID reader.
	while (FOREVER) {


		// If application is flashed, jump to application.
		if (wispData.epcBuf[9] == 0xBE && wispData.epcBuf[10] == 0xEF) {
			(*((void (*)(void))(*(unsigned int *)0xFEFE)))();
		}

		wispData.epcBuf[6] = (* (uint8_t *) (SIZE_ADDR));
		wispData.epcBuf[7] = (* (uint8_t *) (ADDRESS_ADDR_HI));
		wispData.epcBuf[8] = (* (uint8_t *) (ADDRESS_ADDR_LO));

		WISP_doRFID();
	}
}
