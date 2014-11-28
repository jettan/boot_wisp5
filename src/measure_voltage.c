/**
 * @file       usr.c
 * @brief      WISP application-specific code set
 * @details    The WISP application developer's implementation goes here.
 *
 * @author     Aaron Parks, UW Sensor Systems Lab
 *
 */

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
	asm(" NOP");
}

/** 
 * This function is called by WISP FW after a successful BlockWrite
 *  command decode

 */
void my_blockWriteCallback  (void) {
	asm(" NOP");
}

uint16_t measureVoltage(void) {
	uint16_t voltage;

	// Select reference voltage.
	REFCTL0 = REFVSEL_1 + REFON + REFTCOFF;

	// Wait for REF to stabilize.
	__delay_cycles(75*16);

	// Return registers to their reset conditions..
	ADC12CTL0  = 0;
	ADC12CTL1  = 0;
	ADC12CTL2  = 0;
	ADC12MCTL0 = 0;
	ADC12IER0  = 0;

	// Turn on ADC.
	ADC12CTL0 = ADC12ON;

	// Enable using sample and hold pulse mode and use clock as source.
	ADC12CTL1 |= ADC12SHP + ADC12SSEL1;

	// Set resolution to 12 bits. (see user guide 25.3.3)
	ADC12CTL2 |= ADC12RES_1;

	// Select VR+ = VREF and VR- = AVSS. (see user guide 25.3.6)
	ADC12MCTL0|= ADC12VRSEL_1;

	PJOUT |= PIN_MEAS_EN;

	__delay_cycles(75*16);


	// Select analog input channel.
	ADC12MCTL0|= ADC12INCH_9;


	// Select conversion sequence to single channel-single conversion. (see user guide 25.2.8)
	ADC12CTL1 |= ADC12CONSEQ_0;

	// Enable conversion and start.
	ADC12CTL0 |= ADC12SC + ADC12ENC;

	// Wait until conversion is done.
	while (ADC12CTL1 & ADC12BUSY);

	// Read voltage from memory register.
	voltage = ADC12MEM0;

	// Convert the 10 bit unsigned int to a 16 bit unisigned int.
	voltage = voltage << 6;

	// Turn off ADC.
	ADC12CTL0  = 0;
	ADC12CTL1  = 0;
	ADC12CTL2  = 0;
	ADC12MCTL0 = 0;
	ADC12IER0  = 0;

	// Turn off REF.
	REFCTL0    = 0;

	PJOUT &= ~PIN_MEAS_EN;

	return voltage;
}

/**
 * This implements the user application and should never return
 *
 * Must call WISP_init() in the first line of main()
 * Must call WISP_doRFID() at some point to start interacting with a reader
 */
void main(void) {

	WISP_init();

	BITSET(PLED1OUT, PIN_LED1);


	// Register callback functions with WISP comm routines
	WISP_registerCallback_ACK(&my_ackCallback);
	WISP_registerCallback_READ(&my_readCallback);
	WISP_registerCallback_WRITE(&my_writeCallback);
	WISP_registerCallback_BLOCKWRITE(&my_blockWriteCallback);

	// Get access to EPC, READ, and WRITE data buffers
	WISP_getDataBuffers(&wispData);

	// Set up operating parameters for WISP comm routines
	WISP_setMode( MODE_READ | MODE_WRITE | MODE_USES_SEL);
	WISP_setAbortConditions(CMD_ID_READ | CMD_ID_WRITE);

	// Set up EPC
	wispData.epcBuf[0] = 0x05; // WISP version
	wispData.epcBuf[1] = *((uint8_t*)INFO_WISP_TAGID+1); // WISP ID MSB
	wispData.epcBuf[2] = *((uint8_t*)INFO_WISP_TAGID); // WISP ID LSB
	wispData.epcBuf[3] = 0x33;
	wispData.epcBuf[4] = 0x44;
	wispData.epcBuf[5] = 0x55;
	wispData.epcBuf[6] = 0x66;
	wispData.epcBuf[7] = 0x77;
	wispData.epcBuf[8] = 0x88;
	wispData.epcBuf[9] = 0x99;
	wispData.epcBuf[10]= 0xAA;
	wispData.epcBuf[11]= 0xBB;


	// Talk to the RFID reader.
	while (FOREVER) {
		uint16_t voltage = measureVoltage();
		wispData.readBufPtr[0] = voltage;
		WISP_doRFID();
	}

}
