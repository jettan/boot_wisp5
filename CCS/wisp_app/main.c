#include <msp430.h> 
#include <stdio.h>
#include <stdint.h>
#include "pin-assign.h"

#define BITSET(port,pin)    port |= (pin)
#define BITCLR(port,pin)    port &= ~(pin)

int main(void) {

	/// Start WISP init.
	WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

	setupDflt_IO();

	// Disable the GPIO power-on default high-impedance mode to activate previously configured port settings.
	PM5CTL0 &= ~LOCKLPM5;
	PRXEOUT |= PIN_RX_EN;

	// Clock init.
	CSCTL0_H = 0xA5;
	CSCTL1 = DCOFSEL0 + DCOFSEL1; //4MHz
	CSCTL2 = SELA_0 + SELS_3 + SELM_3;
	CSCTL3 = DIVA_0 + DIVS_0 + DIVM_0;

	/// End WISP init.

	int j = 1;

	// Turn on LED!
	BITSET(PLED2OUT,PIN_LED2);

	__delay_cycles(3000000);
	BITCLR(PLED2OUT,PIN_LED2);



	while(1) {
		if (j > 10) {
			((void (*)()) 0x905a) ();
		}
		j++;
	}

}
