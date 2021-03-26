
#include <xc.inc>

extrn	Clock_Setup, Clock
extrn	operation, Operation_Setup
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

int_hi:	org	0x0008	; high vector, no low vector
	goto	Clock
	
start:
	call	LCD_Setup
	call	Clock_Setup
	call	Operation_Setup
	call	Alarm_Setup
	call	ADC_Setup
	
	clrf	operation_check, A
	
settings_clock:
	call	Keypad	    ;check Keypad
	
	movlw	0x0f	    ;check if keypad = F
	CPFSEQ	keypad_val, A
	bra	settings_clock
	
	call	operation   ;
	
	goto	settings_clock	;branch back to settings_clock
    
	end	main
