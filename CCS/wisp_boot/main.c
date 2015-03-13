#include <msp430.h>
#include <stdint.h>

// Memory space containing address of RESET vector of whatever application is selected as active application.
#define SELECTED_APP     0x1900
#define FALLBACK_APP     0xFEFE

void main_boot(void) {

	// Stop watchdog timer.
	WDTCTL = WDTPW | WDTHOLD;

	// Disable the GPIO power-on default high-impedance mode to activate previously configured port settings.
	PM5CTL0 &= ~LOCKLPM5;		// Lock LPM5.

	// Enable writing to FRAM.
	FRCTL0_H |= (FWPW) >> 8;
	__delay_cycles(3);

	// Read the RESET vector of whatever app is chosen.
	uint16_t address = (* (uint16_t *) (SELECTED_APP));

	// If RESET vector of selected app is outside F000 - FFFF, boot the default app instead.
	if (address < 0xF000 || address > 0xFFFF) {
		address = FALLBACK_APP;
	}

	// Jump to the selected application.
	(*((void (*)(void))(*(uint16_t *)(0xFEFE))))();
}
