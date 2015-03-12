#include <msp430.h>

// Memory space containing address of RESET vector of whatever application is selected as active application.
#define SELECTED_APP     0x1900

void main_boot(void) {

	// Stop watchdog timer.
	WDTCTL = WDTPW | WDTHOLD;

	// Disable the GPIO power-on default high-impedance mode to activate previously configured port settings.
	PM5CTL0 &= ~LOCKLPM5;		// Lock LPM5.

	// Enable writing to FRAM.
	FRCTL0_H |= (FWPW) >> 8;
	__delay_cycles(3);

	// Read the RESET vector of whatever app is chosen.
	unsigned int address = (* (unsigned int *) (SELECTED_APP));

	// Do something to ensure the function returns.
	// TODO: Find out how to do this...

	// Otherwise, restore the value to APP1.
	(* (unsigned int *) (SELECTED_APP)) = 0xFEFE;

	// Jump to the selected application.
	(*((void (*)(void))(*(unsigned int *)(address))))();
}
