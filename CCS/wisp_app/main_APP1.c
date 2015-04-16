#include "wisp-base.h"


//#define SELECTED_APP     0x1900
#define SIZE_ADDR        0x1910
#define ADDRESS_ADDR     0x1912
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

/**
 * Here, we implement the protocol of the WISP side.
 * EPC buffer is used completely to echo sent data and control the protocol transmission.
 * [0] is used for packet_type
 */
void my_blockWriteCallback  (void) {
	uint8_t pckt_type = (wispData.blockWriteBufPtr[0] >> 8)  & 0xFF;
	uint8_t pckt_num  = 0;
	uint16_t address  = 0;
	uint8_t num_words = 0;

	switch (pckt_type) {
		// New line, no data packets.
		case 0xDA:
			// Save the size and address to info memory.
			(* (uint8_t *) (SIZE_ADDR)) = (wispData.blockWriteBufPtr[0])  & 0xFF;
			(* (uint16_t *) (ADDRESS_ADDR)) = (wispData.blockWriteBufPtr[1]);

			wispData.epcBuf[0]  = (wispData.blockWriteBufPtr[0] >> 8)  & 0xFF;
			wispData.epcBuf[1]  = (wispData.blockWriteBufPtr[0])  & 0xFF;
			wispData.epcBuf[2]  = (wispData.blockWriteBufPtr[1] >> 8)  & 0xFF;
			wispData.epcBuf[3]  = (wispData.blockWriteBufPtr[1])  & 0xFF;
			wispData.epcBuf[4]  = 0x00;
			wispData.epcBuf[5]  = 0x00;
			wispData.epcBuf[6]  = 0x00;
			wispData.epcBuf[7]  = 0x00;
			wispData.epcBuf[8]  = 0x00;
			wispData.epcBuf[9]  = 0x00;
			break;

		// New line with data packets.
		case 0xDB:
			// Get the size
			num_words = ((wispData.blockWriteBufPtr[0])  & 0xFF) >> 1;

			// Write data in FRAM.
			address = (wispData.blockWriteBufPtr[1]);

			(* (uint16_t *) (address)) = ((wispData.blockWriteBufPtr[2] & 0xff) << 8) | ((wispData.blockWriteBufPtr[2] & 0xff00) >> 8);

			if (num_words > 0x01) {
				(* (uint16_t *) (address + 2)) = ((wispData.blockWriteBufPtr[3] & 0xff) << 8) | ((wispData.blockWriteBufPtr[3] & 0xff00) >> 8);
			}

			if (num_words > 0x02) {
				(* (uint16_t *) (address + 4)) = ((wispData.blockWriteBufPtr[4] & 0xff) << 8) | ((wispData.blockWriteBufPtr[4] & 0xff00) >> 8);
			}

			wispData.epcBuf[0]  = (wispData.blockWriteBufPtr[0] >> 8)  & 0xFF;
			wispData.epcBuf[1]  = (wispData.blockWriteBufPtr[0])  & 0xFF;
			wispData.epcBuf[2]  = (wispData.blockWriteBufPtr[1] >> 8)  & 0xFF;
			wispData.epcBuf[3]  = (wispData.blockWriteBufPtr[1])  & 0xFF;
			wispData.epcBuf[4]  = (wispData.blockWriteBufPtr[2] >> 8)  & 0xFF;
			wispData.epcBuf[5]  = (wispData.blockWriteBufPtr[2])  & 0xFF;
			wispData.epcBuf[6]  = num_words > 0x01 ? (wispData.blockWriteBufPtr[3] >> 8)  & 0xFF : 0x00;
			wispData.epcBuf[7]  = num_words > 0x01 ? (wispData.blockWriteBufPtr[3])  & 0xFF : 0x00;
			wispData.epcBuf[8]  = num_words > 0x02 ? (wispData.blockWriteBufPtr[4] >> 8)  & 0xFF : 0x00;
			wispData.epcBuf[9]  = num_words > 0x02 ? (wispData.blockWriteBufPtr[4])  & 0xFF : 0x00;
			break;

		// Data packets with 1/2/3/4 words.
		case 0xDC:
		case 0xDD:
		case 0xDE:
		case 0xDF:
			// Find out at which address we need to write.
			address = (* (uint16_t *) (ADDRESS_ADDR));

			// Get the packet number from header and calculate offset.
			pckt_num = ((wispData.blockWriteBufPtr[0])  & 0xFF) << 3;

			(* (uint16_t *) (address + pckt_num + 0)) = ((wispData.blockWriteBufPtr[1] & 0xff) << 8) | ((wispData.blockWriteBufPtr[1] & 0xff00) >> 8);

			if (pckt_type > 0xDC) {
				(* (uint16_t *) (address + pckt_num + 2)) = ((wispData.blockWriteBufPtr[2] & 0xff) << 8) | ((wispData.blockWriteBufPtr[2] & 0xff00) >> 8);
			}

			if (pckt_type > 0xDD) {
				(* (uint16_t *) (address + pckt_num + 4)) = ((wispData.blockWriteBufPtr[3] & 0xff) << 8) | ((wispData.blockWriteBufPtr[3] & 0xff00) >> 8);
			}

			if (pckt_type > 0xDE) {
				(* (uint16_t *) (address + pckt_num + 6)) = ((wispData.blockWriteBufPtr[4] & 0xff) << 8) | ((wispData.blockWriteBufPtr[4] & 0xff00) >> 8);
			}

			wispData.epcBuf[0]  = (wispData.blockWriteBufPtr[0] >> 8)  & 0xFF;
			wispData.epcBuf[1]  = (wispData.blockWriteBufPtr[0])  & 0xFF;
			wispData.epcBuf[2]  = (wispData.blockWriteBufPtr[1] >> 8)  & 0xFF;
			wispData.epcBuf[3]  = (wispData.blockWriteBufPtr[1])  & 0xFF;
			wispData.epcBuf[4]  = pckt_type > 0xDC ? (wispData.blockWriteBufPtr[2] >> 8)  & 0xFF : 0x00;
			wispData.epcBuf[5]  = pckt_type > 0xDC ? (wispData.blockWriteBufPtr[2])  & 0xFF : 0x00;
			wispData.epcBuf[6]  = pckt_type > 0xDD ? (wispData.blockWriteBufPtr[3] >> 8)  & 0xFF : 0x00;
			wispData.epcBuf[7]  = pckt_type > 0xDD ? (wispData.blockWriteBufPtr[3])  & 0xFF : 0x00;
			wispData.epcBuf[8]  = pckt_type > 0xDE ? (wispData.blockWriteBufPtr[4] >> 8)  & 0xFF : 0x00;
			wispData.epcBuf[9]  = pckt_type > 0xDE ? (wispData.blockWriteBufPtr[4])  & 0xFF : 0x00;
			break;
		default:
			break;
	}
	wispData.epcBuf[10] = 0x00;
	wispData.epcBuf[11] = 0x00;
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
