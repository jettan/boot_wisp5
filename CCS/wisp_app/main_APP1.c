#include "wisp-base.h"


//#define SELECTED_APP     0x1900
#define SIZE_ADDR        0x1910
#define ADDRESS_ADDR_HI  0x1913
#define ADDRESS_ADDR_LO  0x1912
#define BSL_PASSWD       0x1920

WISP_dataStructInterface_t wispData;

/**
 * Called by WISP FW after a successful read command reception.
 */
void my_readCallback (void) {
	asm(" NOP");
}

/**
 * Control for bytes received by the write command.
 */
void my_writeCallback (void) {

	// Get data descriptor.
	uint8_t hi = (wispData.writeBufPtr[0] >> 8)  & 0xFF;
	uint8_t lo = (wispData.writeBufPtr[0])  & 0xFF;

	// If the BSL password in memory is correct, we can enter FRAM write mode.
	if ((* (uint16_t *) (BSL_PASSWD)) == 0xB105) {
		// Size of data.
		if (hi == 0xFD) {
			(* (uint8_t *) (SIZE_ADDR)) = lo;
		} else if (hi == 0xFE) {
			(* (uint8_t *) (ADDRESS_ADDR_HI)) = lo;
		} else if (hi == 0xFF) {
			(* (uint8_t *) (ADDRESS_ADDR_LO)) = lo;
			// End of line reached.
		} else if (hi < 0x20) {
			uint16_t address = (* (uint16_t *) (ADDRESS_ADDR_HI));
			(* (uint8_t *) (address + hi)) = lo;
		}

		// Acknowledge the message.
		wispData.epcBuf[0]  = (wispData.writeBufPtr[0] >> 8)  & 0xFF;
		wispData.epcBuf[1] = (wispData.writeBufPtr[0])  & 0xFF;

	} else {
		// Check whether we got a command to enter FRAM write mode.
		if (hi == 0xB1 && lo == 0x05) {
			// Write the BSL password.
			(* (uint16_t *) (BSL_PASSWD)) = 0xB105;

			// Acknowledge the message.
			wispData.epcBuf[0]  = (wispData.writeBufPtr[0] >> 8)  & 0xFF;
			wispData.epcBuf[1] = (wispData.writeBufPtr[0])  & 0xFF;

			// Otherwise, enter application directly.
		} else {
			wispData.epcBuf[0]   = 0XB0;
			wispData.epcBuf[1]  = 0X07;
		}
	}

	asm(" NOP");
}

/**
 * Here, we implement the protocol of the WISP side.
 * EPC buffer is used completely to echo sent data and control the protocol transmission.
 * [0] is used for packet_type
 */
void my_blockWriteCallback  (void) {
	wispData.epcBuf[0]  = (wispData.blockWriteBufPtr[0] >> 8)  & 0xFF;
	wispData.epcBuf[1]  = (wispData.blockWriteBufPtr[0])  & 0xFF;
	wispData.epcBuf[2]  = (wispData.blockWriteBufPtr[1] >> 8)  & 0xFF;
	wispData.epcBuf[3]  = (wispData.blockWriteBufPtr[1])  & 0xFF;

	// Change rest of EPC only if it's data packets.
	if (((wispData.blockWriteBufPtr[0] >> 8)  & 0xFF) == 0xDA) {
		wispData.epcBuf[4]  = (wispData.blockWriteBufPtr[2] >> 8)  & 0xFF;
		wispData.epcBuf[5]  = (wispData.blockWriteBufPtr[2])  & 0xFF;
		wispData.epcBuf[6]  = (wispData.blockWriteBufPtr[3] >> 8)  & 0xFF;
		wispData.epcBuf[7]  = (wispData.blockWriteBufPtr[3])  & 0xFF;
		wispData.epcBuf[8]  = (wispData.blockWriteBufPtr[4] >> 8)  & 0xFF;
		wispData.epcBuf[9]  = (wispData.blockWriteBufPtr[4])  & 0xFF;
		wispData.epcBuf[10] = (wispData.blockWriteBufPtr[5] >> 8)  & 0xFF;
		wispData.epcBuf[11] = (wispData.blockWriteBufPtr[5])  & 0xFF;

	// ISR vector entry data.
	} else if (((wispData.blockWriteBufPtr[0] >> 8)  & 0xFF) == 0xFE)  {
		wispData.epcBuf[4]  = (wispData.blockWriteBufPtr[2] >> 8)  & 0xFF;
		wispData.epcBuf[5]  = (wispData.blockWriteBufPtr[2])  & 0xFF;
		wispData.epcBuf[6] = 0x00;
		wispData.epcBuf[7] = 0x00;
		wispData.epcBuf[8] = 0x00;
		wispData.epcBuf[9] = 0x00;
		wispData.epcBuf[10]= 0x00;
		wispData.epcBuf[11]= 0x00;

	// size + address only.
	} else {
		wispData.epcBuf[4] = 0x00;
		wispData.epcBuf[5] = 0x00;
		wispData.epcBuf[6] = 0x00;
		wispData.epcBuf[7] = 0x00;
		wispData.epcBuf[8] = 0x00;
		wispData.epcBuf[9] = 0x00;
		wispData.epcBuf[10]= 0x00;
		wispData.epcBuf[11]= 0x00;
	}
}

void main(void) {
	WISP_init();

	// Register callback functions with WISP comm routines.
	WISP_registerCallback_READ(&my_readCallback);
	WISP_registerCallback_WRITE(&my_writeCallback);
	WISP_registerCallback_BLOCKWRITE(&my_blockWriteCallback);

	// Initialize BlockWrite buffer.
	uint16_t bwr_array[6] = {0};
	RWData.bwrBufPtr = bwr_array;

	// Get access to data buffers.
	WISP_getDataBuffers(&wispData);

	// Set up operating parameters for WISP comm routines
	WISP_setMode( MODE_READ | MODE_WRITE | MODE_USES_SEL);
	WISP_setAbortConditions(CMD_ID_READ | CMD_ID_WRITE);

	FRAM_init();

	// Since we entered this app with success, we set ourselves as the SELECTED_APP.
	//(* (uint16_t *) (SELECTED_APP)) = 0xFEFE;

	// Set up EPC
	wispData.epcBuf[0] = 0x00; // WISP version
	wispData.epcBuf[1] = 0x00;
	wispData.epcBuf[2] = 0x00;
	wispData.epcBuf[3] = 0x00;
	wispData.epcBuf[4] = 0x00;
	wispData.epcBuf[5] = 0x00;
	wispData.epcBuf[6] = 0x00;
	wispData.epcBuf[7] = 0x00;
	wispData.epcBuf[8] = 0x00;
	wispData.epcBuf[9] = 0x00; // RFID Status/Control
	wispData.epcBuf[10]= 0x00; // RFID Status/Control
	wispData.epcBuf[11]= 0x00;



	// Talk to the RFID reader.
	while (FOREVER) {

		// If command is given, jump to  next application.
		if (wispData.epcBuf[0] == 0xB0 && wispData.epcBuf[1] == 0x07) {
			(*((void (*)(void))(*(unsigned int *)0xFDFE)))();
		}

		// BlockWrite makes this function block!
		WISP_doRFID();
	}
}
