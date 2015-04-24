#include <msp430.h>

int main(void) {
	// Stop watchdog timer.
	WDTCTL = WDTPW | WDTHOLD;

	// Turn on LED2.
	//PJOUT |= (BIT6);

	// Turn on LED1.
	P4OUT |= (BIT0);

	// Loop forever.
	while (1) {}
}
