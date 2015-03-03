#include "wisp-base.h"

#define SIZE_ADDR        0x1900
#define ADDRESS_ADDR_HI  0x1903
#define ADDRESS_ADDR_LO  0x1902

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
	wispData.epcBuf[5]++;

	// Indication whether we are still alive during communication.
	BITSET(PLED1OUT, PIN_LED1); // TODO: Remove this when everything is stable?

	// Get data descriptor.
	uint8_t hi = (wispData.writeBufPtr[0] >> 8)  & 0xFF;

	// Size of data.
	if (hi == 0xFD) {
		(* (uint8_t *) (SIZE_ADDR)) = (wispData.writeBufPtr[0])  & 0xFF;
	} else if (hi == 0xFE) {
		(* (uint8_t *) (ADDRESS_ADDR_HI)) = (wispData.writeBufPtr[0])  & 0xFF;
	} else if (hi == 0xFF) {
		(* (uint8_t *) (ADDRESS_ADDR_LO)) = (wispData.writeBufPtr[0])  & 0xFF;
	// End of line reached.
	} else if (hi < 0x20) {
		uint16_t address = (* (uint16_t *) (ADDRESS_ADDR_HI));
		(* (uint8_t *) (address + hi)) = (wispData.writeBufPtr[0])  & 0xFF;
	}

	wispData.epcBuf[9]  = (wispData.writeBufPtr[0] >> 8)  & 0xFF;
	wispData.epcBuf[10] = (wispData.writeBufPtr[0])  & 0xFF;
}

void main_boot(void) {
	WISP_init();

	// Register callback functions with WISP comm routines.
	WISP_registerCallback_READ(&my_readCallback);
	WISP_registerCallback_WRITE(&my_writeCallback);

	// Get access to data buffers.
	WISP_getDataBuffers(&wispData);

	// Set up operating parameters for WISP comm routines
	WISP_setMode( MODE_READ | MODE_WRITE | MODE_USES_SEL);
	WISP_setAbortConditions(CMD_ID_READ | CMD_ID_WRITE);

	FRAM_init();

	// Set up EPC
	wispData.epcBuf[5] = 0x00; // Alive for this many rounds of writeCallbacks
	wispData.epcBuf[9] = 0xde; // RFID Status/Control
	wispData.epcBuf[10]= 0xad; // RFID Status/Control

	// Talk to the RFID reader.
	while (FOREVER) {

		// If command is given, jump to application.
		if (wispData.epcBuf[9] == 0xBE && wispData.epcBuf[10] == 0xEF) {
			(*((void (*)(void))(*(unsigned int *)0xFEFE)))();
		}

		wispData.epcBuf[6] = (* (uint8_t *) (SIZE_ADDR));
		wispData.epcBuf[7] = (* (uint8_t *) (ADDRESS_ADDR_HI));
		wispData.epcBuf[8] = (* (uint8_t *) (ADDRESS_ADDR_LO));

		WISP_doRFID();
	}
}
