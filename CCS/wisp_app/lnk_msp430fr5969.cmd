MEMORY {
    SFR                     : origin = 0x0000, length = 0x0010
    PERIPHERALS_8BIT        : origin = 0x0010, length = 0x00F0
    PERIPHERALS_16BIT       : origin = 0x0100, length = 0x0100
    RAM                     : origin = 0x1C03, length = 0x07FD
    INFOA                   : origin = 0x1980, length = 0x0080
    INFOB                   : origin = 0x1900, length = 0x0080
    INFOC                   : origin = 0x1880, length = 0x0080
    INFOD                   : origin = 0x1800, length = 0x0080

	// Each APP section is 2000 hex bytes long.

    // APP1 (4400 - 57FF)
    FRAM_APP1               : origin = 0x4400, length = 0x2000

    // APP2 (5900 - 6DFF)
    FRAM_APP2               : origin = 0x6400, length = 0x2000

    // APP3 (6E00 - 82FF)
    FRAM_APP3               : origin = 0x8400, length = 0x2000

	// APP4 (8300 - 97FF)
	FRAM_APP4               : origin = 0xA400, length = 0x2000

	// The bootloader section is 1280 bytes long (500 hex).
	// BOOTLOADER/APP SELECTOR/DFU MODE (EB00 - EFFF)
	FRAM_BOOT               : origin = 0xEB00, length = 0x500

    // Unused FRAM section past main device's ISR table (10000-14000)
    FRAM2                   : origin = 0x10000,length = 0x4000

	// Only the relevant interrupt vector table for *this* project's application is defined here.
	// In this case, this is the interrupt vector table of: APP1
    SIGNATURE                : origin = 0xFE80, length = 0x0010
    INT00_1                  : origin = 0xFE90, length = 0x0002
    INT01_1                  : origin = 0xFE92, length = 0x0002
    INT02_1                  : origin = 0xFE94, length = 0x0002
    INT03_1                  : origin = 0xFE96, length = 0x0002
    INT04_1                  : origin = 0xFE98, length = 0x0002
    INT05_1                  : origin = 0xFE9A, length = 0x0002
    INT06_1                  : origin = 0xFE9C, length = 0x0002
    INT07_1                  : origin = 0xFE9E, length = 0x0002
    INT08_1                  : origin = 0xFEA0, length = 0x0002
    INT09_1                  : origin = 0xFEA2, length = 0x0002
    INT10_1                  : origin = 0xFEA4, length = 0x0002
    INT11_1                  : origin = 0xFEA6, length = 0x0002
    INT12_1                  : origin = 0xFEA8, length = 0x0002
    INT13_1                  : origin = 0xFEAA, length = 0x0002
    INT14_1                  : origin = 0xFEAC, length = 0x0002
    INT15_1                  : origin = 0xFEAE, length = 0x0002
    INT16_1                  : origin = 0xFEB0, length = 0x0002
    INT17_1                  : origin = 0xFEB2, length = 0x0002
    INT18_1                  : origin = 0xFEB4, length = 0x0002
    INT19_1                  : origin = 0xFEB6, length = 0x0002
    INT20_1                  : origin = 0xFEB8, length = 0x0002
    INT21_1                  : origin = 0xFEBA, length = 0x0002
    INT22_1                  : origin = 0xFEBC, length = 0x0002
    INT23_1                  : origin = 0xFEBE, length = 0x0002
    INT24_1                  : origin = 0xFEC0, length = 0x0002
    INT25_1                  : origin = 0xFEC2, length = 0x0002
    INT26_1                  : origin = 0xFEC4, length = 0x0002
    INT27_1                  : origin = 0xFEC6, length = 0x0002
    INT28_1                  : origin = 0xFEC8, length = 0x0002
    INT29_1                  : origin = 0xFECA, length = 0x0002
    INT30_1                  : origin = 0xFECC, length = 0x0002
    INT31_1                  : origin = 0xFECE, length = 0x0002
    INT32_1                  : origin = 0xFED0, length = 0x0002
    INT33_1                  : origin = 0xFED2, length = 0x0002
    INT34_1                  : origin = 0xFED4, length = 0x0002
    INT35_1                  : origin = 0xFED6, length = 0x0002
    INT36_1                  : origin = 0xFFD8, length = 0x0002
    INT37_1                  : origin = 0xFEDA, length = 0x0002
    INT38_1                  : origin = 0xFEDC, length = 0x0002
    INT39_1                  : origin = 0xFEDE, length = 0x0002
    INT40_1                  : origin = 0xFEE0, length = 0x0002
    INT41_1                  : origin = 0xFEE2, length = 0x0002
    INT42_1                  : origin = 0xFEE4, length = 0x0002
    INT43_1                  : origin = 0xFEE6, length = 0x0002
    INT44_1                  : origin = 0xFFE8, length = 0x0002
    INT45_1                  : origin = 0xFFEA, length = 0x0002
    INT46_1                  : origin = 0xFEEC, length = 0x0002
    INT47_1                  : origin = 0xFEEE, length = 0x0002
    INT48_1                  : origin = 0xFEF0, length = 0x0002
    INT49_1                  : origin = 0xFEF2, length = 0x0002
    INT50_1                  : origin = 0xFEF4, length = 0x0002
    INT51_1                  : origin = 0xFEF6, length = 0x0002
    INT52_1                  : origin = 0xFEF8, length = 0x0002
    INT53_1                  : origin = 0xFEFA, length = 0x0002
    INT54_1                  : origin = 0xFEFC, length = 0x0002
    RESET_1                  : origin = 0xFEFE, length = 0x0002
}

/****************************************************************************/
/* SPECIFY THE SECTIONS ALLOCATION INTO MEMORY                              */
/****************************************************************************/

SECTIONS
{
    GROUP(ALL_APP1)
    {
       GROUP(READ_WRITE_MEMORY): ALIGN(0x0200) RUN_START(fram_rw_start)
       {
          .cio        : {}                   /* C I/O BUFFER                      */
          .sysmem     : {}                   /* DYNAMIC MEMORY ALLOCATION AREA    */
       }

       GROUP(READ_ONLY_MEMORY): ALIGN(0x0200) RUN_START(fram_ro_start)
       {
          .cinit      : {}                   /* INITIALIZATION TABLES             */
          .pinit      : {}                   /* C++ CONSTRUCTOR TABLES            */
          .init_array : {}                   /* C++ CONSTRUCTOR TABLES            */
          .mspabi.exidx : {}                 /* C++ CONSTRUCTOR TABLES            */
          .mspabi.extab : {}                 /* C++ CONSTRUCTOR TABLES            */
          .const      : {}                   /* CONSTANT DATA                     */
       }

       GROUP(EXECUTABLE_MEMORY): ALIGN(0x0200) RUN_START(fram_rx_start)
       {
          .text       : {}                   /* CODE                              */
       }
    } > FRAM_APP1

    .bss        : {} > RAM                /* GLOBAL & STATIC VARS              */
    .data       : {} > RAM                /* GLOBAL & STATIC VARS              */
    .stack      : {} > RAM (HIGH)         /* SOFTWARE SYSTEM STACK             */

    .infoA     : {} > INFOA              /* MSP430 INFO FRAM  MEMORY SEGMENTS */
    .infoB     : {} > INFOB
    .infoC     : {} > INFOC
    .infoD     : {} > INFOD

    /* MSP430 INTERRUPT VECTORS          */
    .int00       : {}               > INT00_1
    .int01       : {}               > INT01_1
    .int02       : {}               > INT02_1
    .int03       : {}               > INT03_1
    .int04       : {}               > INT04_1
    .int05       : {}               > INT05_1
    .int06       : {}               > INT06_1
    .int07       : {}               > INT07_1
    .int08       : {}               > INT08_1
    .int09       : {}               > INT09_1
    .int10       : {}               > INT10_1
    .int11       : {}               > INT11_1
    .int12       : {}               > INT12_1
    .int13       : {}               > INT13_1
    .int14       : {}               > INT14_1
    .int15       : {}               > INT15_1
    .int16       : {}               > INT16_1
    .int17       : {}               > INT17_1
    .int18       : {}               > INT18_1
    .int19       : {}               > INT19_1
    .int20       : {}               > INT20_1
    .int21       : {}               > INT21_1
    .int22       : {}               > INT22_1
    .int23       : {}               > INT23_1
    .int24       : {}               > INT24_1
    .int25       : {}               > INT25_1
    .int26       : {}               > INT26_1
    .int27       : {}               > INT27_1
    .int28       : {}               > INT28_1
    .int29       : {}               > INT29_1
    AES256       : { * ( .int30 ) } > INT30_1 type = VECT_INIT
    RTC          : { * ( .int31 ) } > INT31_1 type = VECT_INIT
    PORT4        : { * ( .int32 ) } > INT32_1 type = VECT_INIT
    PORT3        : { * ( .int33 ) } > INT33_1 type = VECT_INIT
    TIMER3_A1    : { * ( .int34 ) } > INT34_1 type = VECT_INIT
    TIMER3_A0    : { * ( .int35 ) } > INT35_1 type = VECT_INIT
    PORT2        : { * ( .int36 ) } > INT36_1 type = VECT_INIT
    TIMER2_A1    : { * ( .int37 ) } > INT37_1 type = VECT_INIT
    TIMER2_A0    : { * ( .int38 ) } > INT38_1 type = VECT_INIT
    PORT1        : { * ( .int39 ) } > INT39_1 type = VECT_INIT
    TIMER1_A1    : { * ( .int40 ) } > INT40_1 type = VECT_INIT
    TIMER1_A0    : { * ( .int41 ) } > INT41_1 type = VECT_INIT
    DMA          : { * ( .int42 ) } > INT42_1 type = VECT_INIT
    USCI_A1      : { * ( .int43 ) } > INT43_1 type = VECT_INIT
    TIMER0_A1    : { * ( .int44 ) } > INT44_1 type = VECT_INIT
    TIMER0_A0    : { * ( .int45 ) } > INT45_1 type = VECT_INIT
    ADC12        : { * ( .int46 ) } > INT46_1 type = VECT_INIT
    USCI_B0      : { * ( .int47 ) } > INT47_1 type = VECT_INIT
    USCI_A0      : { * ( .int48 ) } > INT48_1 type = VECT_INIT
    WDT          : { * ( .int49 ) } > INT49_1 type = VECT_INIT
    TIMER0_B1    : { * ( .int50 ) } > INT50_1 type = VECT_INIT
    TIMER0_B0    : { * ( .int51 ) } > INT51_1 type = VECT_INIT
    COMP_E       : { * ( .int52 ) } > INT52_1 type = VECT_INIT
    UNMI         : { * ( .int53 ) } > INT53_1 type = VECT_INIT
    SYSNMI       : { * ( .int54 ) } > INT54_1 type = VECT_INIT

    .reset       : {}               > RESET_1  /* MSP430 RESET VECTOR         */ 
}

/****************************************************************************/
/* MPU SPECIFIC MEMORY SEGMENT DEFINITONS                                   */
/****************************************************************************/

/*
mpusb1 = (fram_ro_start + 0x4000 - 0xFFFF - 1) * 32 / 0x4000 - 1 + 1; // Increment by 1 for Memory Size of x.5
mpusb2 = (fram_rx_start + 0x4000 - 0xFFFF - 1) * 32 / 0x4000 - 1 + 1; // Increment by 1 for Memory Size of x.5
__mpuseg = (mpusb2 << 8) | mpusb1;
__mpusam = 0x7513;
*/


/****************************************************************************/
/* INCLUDE PERIPHERALS MEMORY MAP                                           */
/****************************************************************************/

-l msp430fr5969.cmd

