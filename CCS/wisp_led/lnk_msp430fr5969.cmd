__BOOT_PASSWD    = 0x001C00;
__STAT_CTRL      = 0x001C02;

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
    FRAM_APP2				: origin = 0x6400, length = 0x2000

    // APP3 (6E00 - 82FF)
    FRAM_APP3				: origin = 0x8400, length = 0x2000

	// APP4 (8300 - 97FF)
	FRAM_APP4				: origin = 0xA400, length = 0x2000

	// The bootloader section is 1280 bytes long (500 hex).
	// BOOTLOADER/APP SELECTOR/DFU MODE (EA00 - EFFF)
	FRAM_BOOT				: origin = 0xEA00, length = 0x600

    // Unused FRAM section past main device's ISR table (10000-14000)
    FRAM2                   : origin = 0x10000,length = 0x4000

    /*
    INT00                   : origin = 0xFE90, length = 0x0002
    INT01                   : origin = 0xFE92, length = 0x0002
    INT02                   : origin = 0xFE94, length = 0x0002
    INT03                   : origin = 0xFE96, length = 0x0002
    INT04                   : origin = 0xFE98, length = 0x0002
    INT05                   : origin = 0xFE9A, length = 0x0002
    INT06                   : origin = 0xFE9C, length = 0x0002
    INT07                   : origin = 0xFE9E, length = 0x0002
    INT08                   : origin = 0xFEA0, length = 0x0002
    INT09                   : origin = 0xFEA2, length = 0x0002
    INT10                   : origin = 0xFEA4, length = 0x0002
    INT11                   : origin = 0xFEA6, length = 0x0002
    INT12                   : origin = 0xFEA8, length = 0x0002
    INT13                   : origin = 0xFEAA, length = 0x0002
    INT14                   : origin = 0xFEAC, length = 0x0002
    INT15                   : origin = 0xFEAE, length = 0x0002
    INT16                   : origin = 0xFEB0, length = 0x0002
    INT17                   : origin = 0xFEB2, length = 0x0002
    INT18                   : origin = 0xFEB4, length = 0x0002
    INT19                   : origin = 0xFEB6, length = 0x0002
    INT20                   : origin = 0xFEB8, length = 0x0002
    INT21                   : origin = 0xFEBA, length = 0x0002
    INT22                   : origin = 0xFEBC, length = 0x0002
    INT23                   : origin = 0xFEBE, length = 0x0002
    INT24                   : origin = 0xFEC0, length = 0x0002
    INT25                   : origin = 0xFEC2, length = 0x0002
    INT26                   : origin = 0xFEC4, length = 0x0002
    INT27                   : origin = 0xFEC6, length = 0x0002
    INT28                   : origin = 0xFEC8, length = 0x0002
    INT29                   : origin = 0xFECA, length = 0x0002
    INT30                   : origin = 0xFECC, length = 0x0002
    INT31                   : origin = 0xFECE, length = 0x0002
    INT32                   : origin = 0xFED0, length = 0x0002
    INT33                   : origin = 0xFED2, length = 0x0002
    INT34                   : origin = 0xFED4, length = 0x0002
    INT35                   : origin = 0xFED6, length = 0x0002
    INT36                   : origin = 0xFED8, length = 0x0002
    INT37                   : origin = 0xFEDA, length = 0x0002
    INT38                   : origin = 0xFEDC, length = 0x0002
    INT39                   : origin = 0xFEDE, length = 0x0002
    INT40                   : origin = 0xFEE0, length = 0x0002
    INT41                   : origin = 0xFEE2, length = 0x0002
    INT42                   : origin = 0xFEE4, length = 0x0002
    INT43                   : origin = 0xFEE6, length = 0x0002
    INT44                   : origin = 0xFEE8, length = 0x0002
    INT45                   : origin = 0xFEEA, length = 0x0002
    INT46                   : origin = 0xFEEC, length = 0x0002
    INT47                   : origin = 0xFEEE, length = 0x0002
    INT48                   : origin = 0xFEF0, length = 0x0002
    INT49                   : origin = 0xFEF2, length = 0x0002
    INT50                   : origin = 0xFEF4, length = 0x0002
    INT51                   : origin = 0xFEF6, length = 0x0002
    INT52                   : origin = 0xFEF8, length = 0x0002
    INT53                   : origin = 0xFEFA, length = 0x0002
    INT54                   : origin = 0xFEFC, length = 0x0002
    */
    RESET                   : origin = 0xFDFE, length = 0x0002
}

/****************************************************************************/
/* SPECIFY THE SECTIONS ALLOCATION INTO MEMORY                              */
/****************************************************************************/

SECTIONS
{
    GROUP(ALL_APP2)
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
    } > FRAM_APP2

    .bss        : {} > RAM                /* GLOBAL & STATIC VARS              */
    .data       : {} > RAM                /* GLOBAL & STATIC VARS              */
    .stack      : {} > RAM (HIGH)         /* SOFTWARE SYSTEM STACK             */

    .infoA     : {} > INFOA              /* MSP430 INFO FRAM  MEMORY SEGMENTS */
    .infoB     : {} > INFOB
    .infoC     : {} > INFOC
    .infoD     : {} > INFOD

    /* MSP430 INTERRUPT VECTORS          */
    /*
    .int00       : {}               > INT00
    .int01       : {}               > INT01
    .int02       : {}               > INT02
    .int03       : {}               > INT03
    .int04       : {}               > INT04
    .int05       : {}               > INT05
    .int06       : {}               > INT06
    .int07       : {}               > INT07
    .int08       : {}               > INT08
    .int09       : {}               > INT09
    .int10       : {}               > INT10
    .int11       : {}               > INT11
    .int12       : {}               > INT12
    .int13       : {}               > INT13
    .int14       : {}               > INT14
    .int15       : {}               > INT15
    .int16       : {}               > INT16
    .int17       : {}               > INT17
    .int18       : {}               > INT18
    .int19       : {}               > INT19
    .int20       : {}               > INT20
    .int21       : {}               > INT21
    .int22       : {}               > INT22
    .int23       : {}               > INT23
    .int24       : {}               > INT24
    .int25       : {}               > INT25
    .int26       : {}               > INT26
    .int27       : {}               > INT27
    .int28       : {}               > INT28
    .int29       : {}               > INT29
    AES256       : { * ( .int30 ) } > INT30 type = VECT_INIT
    RTC          : { * ( .int31 ) } > INT31 type = VECT_INIT
    PORT4        : { * ( .int32 ) } > INT32 type = VECT_INIT
    PORT3        : { * ( .int33 ) } > INT33 type = VECT_INIT
    TIMER3_A1    : { * ( .int34 ) } > INT34 type = VECT_INIT
    TIMER3_A0    : { * ( .int35 ) } > INT35 type = VECT_INIT
    PORT2        : { * ( .int36 ) } > INT36 type = VECT_INIT
    TIMER2_A1    : { * ( .int37 ) } > INT37 type = VECT_INIT
    TIMER2_A0    : { * ( .int38 ) } > INT38 type = VECT_INIT
    PORT1        : { * ( .int39 ) } > INT39 type = VECT_INIT
    TIMER1_A1    : { * ( .int40 ) } > INT40 type = VECT_INIT
    TIMER1_A0    : { * ( .int41 ) } > INT41 type = VECT_INIT
    DMA          : { * ( .int42 ) } > INT42 type = VECT_INIT
    USCI_A1      : { * ( .int43 ) } > INT43 type = VECT_INIT
    TIMER0_A1    : { * ( .int44 ) } > INT44 type = VECT_INIT
    TIMER0_A0    : { * ( .int45 ) } > INT45 type = VECT_INIT
    ADC12        : { * ( .int46 ) } > INT46 type = VECT_INIT
    USCI_B0      : { * ( .int47 ) } > INT47 type = VECT_INIT
    USCI_A0      : { * ( .int48 ) } > INT48 type = VECT_INIT
    WDT          : { * ( .int49 ) } > INT49 type = VECT_INIT
    TIMER0_B1    : { * ( .int50 ) } > INT50 type = VECT_INIT
    TIMER0_B0    : { * ( .int51 ) } > INT51 type = VECT_INIT
    COMP_E       : { * ( .int52 ) } > INT52 type = VECT_INIT
    UNMI         : { * ( .int53 ) } > INT53 type = VECT_INIT
    SYSNMI       : { * ( .int54 ) } > INT54 type = VECT_INIT
*/
    .reset       : {}               > RESET  /* MSP430 RESET VECTOR         */ 
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

