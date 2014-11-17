README
==========

WARNING: This software is still in development - use at own risk!

Instructions:
To run the application, first compile wisp-base as a library using Code Composer Studio (CCS) 6.
After this is done, compile both wisp_app and wisp_boot.

When flashing to your wisp5, flash the bootloader (wisp_boot) first (erasing all memory before flash) and AFTER that wisp_app (without erasing the memory).

To change memory mapping of the bootloader and the application, change the linker command files in BOTH projects (lnk_msp430fr5969.cmd).
