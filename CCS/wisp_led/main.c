#include <msp430.h>

int main(void) {
	// Stop watchdog timer.
	WDTCTL = WDTPW | WDTHOLD;

	// Turn on LED2.
	PJOUT |= (BIT6);

	// Loop forever.
	while (1) {}
}
