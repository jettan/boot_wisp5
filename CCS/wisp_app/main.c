#include "wisp-base.h"

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
	wispData.epcBuf[11] = wispData.writeBufPtr[0];
}

/**
 * This function is called by WISP FW after a successful BlockWrite
 *  command decode

 */
void my_blockWriteCallback  (void) {
	asm(" NOP");
}

int main(void) {

	WISP_init();

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
		wispData.epcBuf[0] = 0x05; // WISP version
		wispData.epcBuf[1] = 0x85; // WISP UUID
		wispData.epcBuf[2] = 0x02; // WISP UUID
		wispData.epcBuf[3] = 0x30; // WISP UUID
		wispData.epcBuf[4] = 0x53; // WISP UUID
		wispData.epcBuf[5] = 0x74; // WISP UUID
		wispData.epcBuf[6] = 0x00; // RFID Status/Control
		wispData.epcBuf[7] = 0x00; // RFID Status/Control
		wispData.epcBuf[8] = 0x00; // RFID Status/Control
		wispData.epcBuf[9] = 0x00; // RFID Status/Control
		wispData.epcBuf[10]= 0x00; // RFID Status/Control
		wispData.epcBuf[11]= 0xFF; // RFID Status/Control

		BITSET(PLED2OUT, PIN_LED2);

		// Talk to the RFID reader.
		while (FOREVER) {

			// If application is valid, jump to application.
			if (wispData.epcBuf[11] == 0xBB) {
				((void (*)()) 0x905a) ();
			}

			WISP_doRFID();
		}
}
