/**
 *
 * Hardware CRC implementation using MSP430 DMA for expedited transfer, 
 *  targets MSP430FR5969.
 *
 * @author 	Xingyi Shi, Aaron Parks
 *
 */

#include <msp430.h>
#include <stdint.h>
#include "dma_crc.h"

/**
 * Computes a 16-bit CCITT standard CRC16 given a seed value (uses polynomial 0x1021)
 *
 * @return CRC16 result over specified number of elements of buffer
 * @pre CRC16 module and DMA0 are unoccupied
 */
uint16_t hw_crc16_incremental(uint16_t* buf, uint16_t size, uint16_t seed)
{
  // Load initial seed value into CRC16 module
  CRCINIRES = seed; 

  //// Configure DMA channel 0 to feed input buffer to CRC16 module

  // Source block address  
  __data16_write_addr((unsigned short) &DMA0SA,(unsigned long) &buf);
  // Destination single address
  __data16_write_addr((unsigned short) &DMA0DA,(unsigned long) &CRCDIRB);

  DMA0SZ = size; // Block size
  DMA0CTL = DMADT_5 | DMASRCINCR_3 | DMADSTINCR_0; // Repeat block, inc
  DMA0CTL &= ~DMAIFG; // Clear interrupt flag
  DMA0CTL |= DMAIE; // Enable DMA interrupt

  // Start copying data into CRC16 module
  DMA0CTL |= DMAEN; 
  DMA0CTL |= DMAREQ;

  // CPU sleeps now; wake on CRC computation finished.
  __bis_SR_register(GIE | LPM0_bits); 
  __no_operation();

  // Result is in CRCINIRES
  return CRCINIRES;
}


/**
 * Computes a 16-bit CCITT standard CRC16 (polynomial 0x1021, seed 0xFFFF)
 *
 * @return CRC16 result over specified number of elements of buffer
 * @pre CRC16 module and DMA0 are unoccupied
 */
uint16_t hw_crc16(uint16_t* buf, uint16_t size) {
  return hw_crc16_incremental(buf, size, CRC_CCITT_INIT_SEED);
}



#pragma vector=DMA_VECTOR
__interrupt void DMA_ISR(void)
{
  volatile unsigned int a = DMAIV; // clear DMA interrupt flag by read instruction
  __bic_SR_register_on_exit(LPM4_bits); // Wake on ISR exit
}
