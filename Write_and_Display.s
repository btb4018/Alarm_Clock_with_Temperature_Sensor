#include <xc.inc>

extrn	LCD_Write_Character, LCD_Set_to_Line_1, LCD_Set_to_Line_2, LCD_Write_Low_Nibble, LCD_delay_ms
    
global  Write_ALARM, Write_Snooze, Write_Error, Write_zeros, Write_no_alarm, Write_Set_Time
global	Write_New, Write_colon, Write_space, Write_Time, Write_Temp, Write_Alarm
global	Write_Settings
global	delay
    
psect	Write_and_Display_code, class=CODE 


Write_ALARM:		;Write 'Alarm  A-Snooze' to 2nd line of LCD
	;call delay
	call	LCD_Set_to_Line_2
	movlw	'A'
	call	LCD_Write_Character	;write 'A'
	movlw	'L'
	call	LCD_Write_Character	;write 'L'
	movlw	'A'
	call	LCD_Write_Character	;write 'A'
	movlw	'R'
	call	LCD_Write_Character	;write 'R'
	movlw   'M'
	call    LCD_Write_Character	;write 'M'

	call	Write_space
	call	Write_space
	
	movlw	'A'
	call	LCD_Write_Character	;write 'A'
	movlw	'-'
	call	LCD_Write_Character	;write '-'
	movlw	'S'
	call	LCD_Write_Character	;write 'S'
	movlw	'n'
	call	LCD_Write_Character	;write 'n'
	movlw   'o'
	call    LCD_Write_Character	;write 'o'
	movlw   'o'
	call    LCD_Write_Character	;write 'o'
	movlw   'z'
	call    LCD_Write_Character	;write 'z'
	movlw   'e'
	call    LCD_Write_Character	;write 'e'

	return	
	
 Write_Snooze:		;Write 'Snooze' to 2nd line of LCD
	call	LCD_Set_to_Line_2
	movlw	'S'
	call	LCD_Write_Character	;write 'S'
	movlw	'n'
	call	LCD_Write_Character	;write 'n'
	movlw	'o'
	call	LCD_Write_Character	;write 'o'
	movlw	'o'
	call	LCD_Write_Character	;write 'o'
	movlw   'z'
	call    LCD_Write_Character	;write 'z'
	movlw   'e'
	call    LCD_Write_Character	;write 'e'
	
	call	Write_space
	call	Write_space
	call	Write_space
	call	Write_space
	call	Write_space
	
	call	delay	
	call	delay
	return	   
	
Write_Error:	     ;Write 'Error' to LCD
	
	movlw	'E'
	call	LCD_Write_Character	;write 'E'
	movlw	'r'
	call	LCD_Write_Character	;write 'r'
	movlw	'r'
	call	LCD_Write_Character	;write 'r'
	movlw	'o'
	call	LCD_Write_Character	;write 'o'
	movlw	'r'
	call	LCD_Write_Character	;write 'r'  
	call delay
	return
	
Write_Time:	     ;Write 'Time:' to LCD
	
	movlw	'T'
	call	LCD_Write_Character	;write 'T'
	movlw	'i'
	call	LCD_Write_Character	;write 'i'
	movlw	'm'
	call	LCD_Write_Character	;write 'm'
	movlw	'e'
	call	LCD_Write_Character	;write 'e'
	    
	call	Write_colon		;write ':'
	
	return
	
Write_Set_Time:	     ;Write 'Set Time' to LCD
	movlw	'S'
	call	LCD_Write_Character	;write 'S'
	movlw	'e'
	call	LCD_Write_Character	;write 'e'
	movlw	't'
	call	LCD_Write_Character	;write 't'
	    
	call	Write_space
	
	movlw	'T'
	call	LCD_Write_Character	;write 'T'
	movlw	'i'
	call	LCD_Write_Character	;write 'i'
	movlw	'm'
	call	LCD_Write_Character	;write 'm'
	movlw	'e'
	call	LCD_Write_Character	;write 'e'
	
	return
	
Write_Settings:		;Write 'Settings' to 1st line and 'A-Alarm  T-Time' to 2nd line of LCD
	call	LCD_Set_to_Line_1
	movlw	'S'
	call	LCD_Write_Character	;write 'S'
	movlw	'e'
	call	LCD_Write_Character	;write 'e'
	movlw	't'
	call	LCD_Write_Character	;write 't'
	movlw	't'
	call	LCD_Write_Character	;write 't'
	movlw	'i'
	call	LCD_Write_Character	;write 'i'
	movlw	'n'
	call	LCD_Write_Character	;write 'n'
	movlw	'g'
	call	LCD_Write_Character	;write 'g'
	movlw	's'
	call	LCD_Write_Character	;write 's'
	
	call	LCD_Set_to_Line_2
	movlw	'A'
	call	LCD_Write_Character	;write 'A'
	movlw	'-'
	call	LCD_Write_Character	;write '-'
	movlw	'A'
	call	LCD_Write_Character	;write 'A'
	movlw	'l'
	call	LCD_Write_Character	;write 'l'
	movlw	'a'
	call	LCD_Write_Character	;write 'a'
	movlw	'r'
	call	LCD_Write_Character	;write 'r'
	movlw	'm'
	call	LCD_Write_Character	;write 'm'
	
	call	Write_space
	call	Write_space
	
	movlw	'T'
	call	LCD_Write_Character	;write 'T'
	movlw	'-'
	call	LCD_Write_Character	;write '-'
	movlw	'T'
	call	LCD_Write_Character	;write 'T'
	movlw	'i'
	call	LCD_Write_Character	;write 'i'
	movlw	'm'
	call	LCD_Write_Character	;write 'm'
	movlw	'e'
	call	LCD_Write_Character	;write 'e'
	
	return
	
Write_Temp:	    ; ;Write 'Temp:' to LCD
	movlw	'T'
	call	LCD_Write_Character	;write 'T'
	movlw	'e'
	call	LCD_Write_Character	;write 'e'
	movlw	'm'
	call	LCD_Write_Character	;write 'm'
	movlw	'p'
	call	LCD_Write_Character	;write 'p'
	    
	call	Write_colon		;write ':'
	
	return
	
Write_Alarm:	     ;Write 'Alarm' to LCD
	movlw	'A'
	call	LCD_Write_Character	;write 'A'
	movlw	'l'
	call	LCD_Write_Character	;write 'l'
	movlw	'a'
	call	LCD_Write_Character	;write 'a'
	movlw	'r'
	call	LCD_Write_Character	;write 'r'
	movlw   'm'
	call    LCD_Write_Character	;write 'm'
	
	call	Write_colon		;write ':'
	
	return
	
Write_zeros:	     ;Write '00:00:00' to LCD
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x0
	call	LCD_Write_Low_Nibble
	call	Write_colon 
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x0
	call	LCD_Write_Low_Nibble
	call	Write_colon
	movlw	0x0
	call	LCD_Write_Low_Nibble
	movlw	0x0
	call	LCD_Write_Low_Nibble
	return
	
Write_no_alarm:	    ;Write 'No Alarm' to LCD
	movlw   'N'
	call    LCD_Write_Character	;write 'N'
	movlw   'o'
	call    LCD_Write_Character	;write 'o'
	call	Write_space
	movlw	'A'
	call	LCD_Write_Character	;write 'A'
	movlw	'l'
	call	LCD_Write_Character	;write 'l'
	movlw	'a'
	call	LCD_Write_Character	;write 'a'
	movlw	'r'
	call	LCD_Write_Character	;write 'r'
	movlw   'm'
	call    LCD_Write_Character	;write 'm'
	call	Write_space
	return	

Write_New:	    ;Write 'New: ' to LCD
	movlw	'N'		    ;character 'N'
	call	LCD_Write_Character
	movlw	'e'		    ;character 'e'
	call	LCD_Write_Character
	movlw	'w'		    ;character 'w'
	call	LCD_Write_Character
	call	Write_colon
	call	Write_space
	return

Write_colon:	    ; Write ':' to LCD
	movlw	':'		    ;character ':'
	call	LCD_Write_Character
	return
	
Write_space:	    ; Write ' ' space to LCD
	movlw   ' '
	call    LCD_Write_Character	;write ' '
	return

	
delay:		    ;400ms delay
	movlw	0x64
	call	LCD_delay_ms
	movlw	0x64
	call	LCD_delay_ms
	movlw	0x64
	call	LCD_delay_ms
	movlw	0x64
	call	LCD_delay_ms
	return

	
	

