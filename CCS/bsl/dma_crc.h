/**
 *
 * Public interface for HW CRC16
 */

#ifndef DMA_CRC_H_
#define DMA_CRC_H_

#define CRC_CCITT_INIT_SEED (0xFFFF)

uint16_t hw_crc16_incremental(uint16_t* buf, uint16_t size, uint16_t seed);
uint16_t hw_crc16(uint16_t* buf, uint16_t size);

#endif // DMA_CRC_H_
