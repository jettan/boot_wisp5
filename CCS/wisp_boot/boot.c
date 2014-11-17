#include <stdlib.h>

extern void main_boot(void);
extern void __interrupt _c_int00();


void              (*_cleanup_ptr)(void);
void _DATA_ACCESS (*_dtors_ptr)(int);

/*---------------------------------------------------------------------------*/
/* Allocate the memory for the system stack.  This section will be sized     */
/* by the linker.                                                            */
/*---------------------------------------------------------------------------*/
__asm("\t.global __STACK_END");
#pragma DATA_SECTION (_stack, ".stack");
#if defined(__LARGE_DATA_MODEL__)
long _stack;
#else
int _stack;
#endif

/*---------------------------------------------------------------------------*/
/*  Initialize reset vector to point at _c_int00                             */
/*  _c_int00 must always be located in low-memory on MSP430X devices.        */
/*---------------------------------------------------------------------------*/
#if defined(__LARGE_CODE_MODEL__)
_Pragma("CODE_SECTION(_c_int00, \".text:_isr\")")
#endif

__asm("\t.global _reset_vector");
__asm("\t.sect   \".reset\"");
__asm("\t.align  2");
__asm("_reset_vector:\n\t.field _c_int00, 16");

/*---------------------------------------------------------------------------*/
/* Macro to initialize stack pointer.  Stack grows towards lower memory.     */
/*---------------------------------------------------------------------------*/
#if defined(__LARGE_DATA_MODEL__)
#define STACK_INIT() __asm("\t   MOVX.A\t   #__STACK_END,SP")
#else
#define STACK_INIT() __asm("\t   MOV.W\t    #__STACK_END,SP")
#endif

/*---------------------------------------------------------------------------*/
/* Macros to initialize required global variables.                           */
/*---------------------------------------------------------------------------*/
#if defined(__TI_EABI__)
#define INIT_EXIT_PTRS() do { } while(0)
#define INIT_LOCKS()     do { } while(0)
#else
#define INIT_EXIT_PTRS() do { _cleanup_ptr = NULL; _dtors_ptr = NULL; } while(0)
#define INIT_LOCKS()     do { _lock = _nop; _unlock = _nop; } while(0)
#endif

/*****************************************************************************/
/* C_INT00() - C ENVIRONMENT ENTRY POINT                                     */
/*****************************************************************************/
#pragma CLINK(_c_int00)
extern void __interrupt _c_int00() {
	STACK_INIT();

	//  INIT_EXIT_PTRS();
	// INIT_LOCKS();

	/*------------------------------------------------------------------------*/
	/* Allow for any application-specific low level initialization prior to   */
	/* initializing the C/C++ environment (global variable initialization,    */
	/* constructers).  If _system_pre_init() returns 0, then bypass C/C++     */
	/* initialization.  NOTE: BYPASSING THE CALL TO THE C/C++ INITIALIZATION  */
	/* ROUTINE MAY RESULT IN PROGRAM FAILURE.                                 */
	/*------------------------------------------------------------------------*/
	//   if(_system_pre_init() != 0)  _auto_init();

	/*------------------------------------------------------------------------*/
	/* Handle any argc/argv arguments if supported by an MSP430 loader.       */
	/*------------------------------------------------------------------------*/
	main_boot();

}
