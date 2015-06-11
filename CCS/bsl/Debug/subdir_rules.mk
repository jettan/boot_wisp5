################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
catchall.obj: ../catchall.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: MSP430 Compiler'
	"/home/dutiir/ti/ccsv6/tools/compiler/msp430_4.3.3/bin/cl430" -vmspx --abi=eabi --data_model=restricted --include_path="/home/dutiir/ti/ccsv6/ccs_base/msp430/include" --include_path="/home/dutiir/workspace/boot_wisp5/CCS/wisp-base" --include_path="/home/dutiir/ti/ccsv6/tools/compiler/msp430_4.3.3/include" --advice:power="all" --advice:hw_config=1 -g --define=__MSP430FR5969__ --diag_warning=225 --display_error_number --diag_wrap=off --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --printf_support=full --preproc_with_compile --preproc_dependency="catchall.pp" $(GEN_OPTS__FLAG) "$(shell echo $<)"
	@echo 'Finished building: $<'
	@echo ' '

isr-link.obj: ../isr-link.asm $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: MSP430 Compiler'
	"/home/dutiir/ti/ccsv6/tools/compiler/msp430_4.3.3/bin/cl430" -vmspx --abi=eabi --data_model=restricted --include_path="/home/dutiir/ti/ccsv6/ccs_base/msp430/include" --include_path="/home/dutiir/workspace/boot_wisp5/CCS/wisp-base" --include_path="/home/dutiir/ti/ccsv6/tools/compiler/msp430_4.3.3/include" --advice:power="all" --advice:hw_config=1 -g --define=__MSP430FR5969__ --diag_warning=225 --display_error_number --diag_wrap=off --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --printf_support=full --preproc_with_compile --preproc_dependency="isr-link.pp" $(GEN_OPTS__FLAG) "$(shell echo $<)"
	@echo 'Finished building: $<'
	@echo ' '

main.obj: ../main.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: MSP430 Compiler'
	"/home/dutiir/ti/ccsv6/tools/compiler/msp430_4.3.3/bin/cl430" -vmspx --abi=eabi --data_model=restricted --include_path="/home/dutiir/ti/ccsv6/ccs_base/msp430/include" --include_path="/home/dutiir/workspace/boot_wisp5/CCS/wisp-base" --include_path="/home/dutiir/ti/ccsv6/tools/compiler/msp430_4.3.3/include" --advice:power="all" --advice:hw_config=1 -g --define=__MSP430FR5969__ --diag_warning=225 --display_error_number --diag_wrap=off --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --printf_support=full --preproc_with_compile --preproc_dependency="main.pp" $(GEN_OPTS__FLAG) "$(shell echo $<)"
	@echo 'Finished building: $<'
	@echo ' '


