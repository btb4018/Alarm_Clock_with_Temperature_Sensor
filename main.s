
#include <xc.inc>

extrn	Clock_Setup, Clock
extrn	Operation, Operation_Setup
extrn	LCD_Setup, LCD_Clear
extrn	Keypad, keypad_val
extrn	Alarm_Setup
extrn	ADC_Setup    
global	operation_check
    
psect	udata_acs
operation_check:	ds  1	;reserving byte   
    
psect	code, abs
	
main:	org	0x0	; reset vector
	goto	start
	;org	0x100

int_hi:	org	0x0008	;set timer0 interrupt as high priority
	goto	Clock
	
start:
    
setup:	;call setup subroutines for different peripherals
	call	LCD_Setup   
	call	Clock_Setup
	call	Operation_Setup
	call	Alarm_Setup
	call	ADC_Setup
	
	clrf	operation_check, A
	
Settings_Clock:
	call	Keypad	    ;check Keypad
	
	movlw	0x0f	    ;check if keypad = F
	CPFSEQ	keypad_val, A
	bra	Settings_Clock	;if not branch back to Settings_Clock
	
	call	Operation   ;is =F branch to Operation
	
	goto	Settings_Clock	;branch back to settings_clock
    
	end	main
	
