#include <xc.inc>
	
extrn	Write_Decimal_to_LCD
extrn	LCD_Clear, operation_check
extrn	LCD_Write_Low_Nibble, delay
    
extrn	Keypad, keypad_val

extrn	Rewrite_Clock
extrn	clock_sec, clock_min, clock_hrs  
    
extrn	alarm_hrs, alarm_min, alarm_sec
extrn	alarm_on    
extrn	Write_Error, Write_no_alarm, Write_zeros, Write_Time, Write_Temp, Write_Alarm, Write_New
extrn	Write_Set_Time, Write_Settings
extrn	Write_colon, Write_space, LCD_cursor_on, LCD_cursor_off, LCD_Set_to_Line_1, LCD_Set_to_Line_2

global	temporary_hrs, temporary_min, temporary_sec
global	Clock, Clock_Setup, operation, Operation_Setup, skip_byte, check_60, check_24
global	hex_A, hex_C
    
    
psect	udata_acs
set_time_hrs1: ds 1 ;reserving bytes to store keypad inputs when setting time
set_time_hrs2: ds 1  
set_time_min1: ds 1
set_time_min2: ds 1
set_time_sec1: ds 1
set_time_sec2: ds 1
    
temporary_hrs: ds 1 ;reserving bytes to store temporary hex times
temporary_min: ds 1
temporary_sec: ds 1
    
timer_start_value_1: ds 1   ;reserving bytes to store timer 0 starting times
timer_start_value_2: ds 1
    
skip_byte:	ds 1	;reserving byte used to skip a line

hex_A:	ds 1	;reserving bytes to store hex value for comparison
hex_B:	ds 1
hex_C:	ds 1
hex_D:	ds 1
hex_E:	ds 1
hex_F:	ds 1
hex_null:   	ds  1
   
alarm: ds 1	;reserving byte to indicate whether alarm or time being set
    
psect	Operations_code, class=CODE

Operation_Setup:
	bcf	alarm, 0, A
	bcf	skip_byte,  0, A	    ;set skip byte to zero to be used to skip lines later
	
	movlw	0x0A		;storing keypad character hex values
	movwf	hex_A, A
	movlw	0x0B
	movwf	hex_B, A
	movlw	0x0C
	movwf	hex_C, A
	movlw	0x0D
	movwf	hex_D, A
	movlw	0x0E
	movwf	hex_E, A
	movlw	0x0F
	movwf	hex_F, A
	movlw	0xff
	movwf	hex_null, A
	return

operation:
	bsf	operation_check, 0, A	;set operation_check bit to signal start of operatio 
	call	LCD_Clear   
	call	Write_Settings		;Write 'Settings' to LCD
check_keypad:
	call	Keypad			;read keypad
	movf	keypad_val, W, A	;move keypad_val to W
	CPFSEQ	hex_null, A		;compare with null
	bra	check_alarm		;if not null check A for alarm	
	bra	check_keypad		;if null read keypad again
check_alarm:	
	CPFSEQ	hex_A, A		;compare with A
	bra	check_set_time		;if not A check B for set time 
	bra	set_alarm		;if A branch to set alarm
check_set_time:
	CPFSEQ	hex_B, A		;compare with B
	bra	check_cancel		;if not B check C for cancel
	bra	Set_Time		;if B branch to set time
check_cancel:
	CPFSEQ	hex_C, A		;compare with C 
	bra	check_keypad		;if not C read keypad again
	bra	Cancel			;if C branch to canncel
	return

set_alarm:	;Display Set Alarm screen
	call	LCD_Clear	    ;clear LCD
	call	LCD_cursor_on	    ;turn blinking and cursor on

	call	Display_Set_Alarm   ;display Alarm setup screen
	
	call	LCD_Set_to_Line_2   ;set cursor to line 2
	call	Write_New	    ;write 'New: ' to LCD
	
	bsf	alarm, 0, A	    ;set alarm bit to 1 to shown alarm setting selected
	
	bra	Set_Time_Clear	    
	
Set_Time:	;Display Set Time screen
	call	LCD_Clear	    ;clear LCD
	call	LCD_cursor_on	    ;turn blinking and cursor on
    
	call	LCD_Set_to_Line_1   ;set LCD cursor to line 1
	call	Write_Set_Time
	
	call	LCD_Set_to_Line_2   ;set LCD cursor to line 2
	call	Display_Set_Time    ;display  'Time: 00:00:00' on LCD
	
	call	LCD_Set_to_Line_2   ;set LCD cursor to line 2
	call	Write_Time	    ;write 'Time: ' to LCD
	
	bcf	alarm, 0, A	    ;clear alarm bit to shown time setting selected
	
Set_Time_Clear:	;clear bytes into which times inputted
	clrf	set_time_hrs1, A
	clrf	set_time_hrs2, A
	clrf	set_time_min1, A
	clrf	set_time_min2, A
	clrf	set_time_sec1, A
	clrf	set_time_sec2, A
	
	clrf	temporary_hrs, A
	clrf	temporary_min, A
	clrf	temporary_sec, A
	
	
Set_Time1:	;check for input of 1st digit of hour
	call Input_Check    ;check keypad and output keypad_val if is number or C, D, E
	
	CPFSEQ	hex_C, A    ;compare keypad_val to C
	btfsc	skip_byte, 0, A
	bra	Cancel	    ;if C pressed branch to Cancel 
	CPFSEQ	hex_D, A    ;compare keypad_val to D
	btfsc	skip_byte, 0, A
	bra	Delete	    ;if D pressed branch to Delete
	CPFSEQ	hex_E, A    ;compare keypad_val to E
	btfsc	skip_byte, 0, A
	bra	Enter_Time  ;if E pressed branch to Enter_Time
	
	movff	keypad_val, set_time_hrs1   ;number moved to set_time_hrs1
	
	call	Write_keypad_val    ;display inputted number on LCD
	call	delay		    ;delay before checking keypad again
Set_Time2:	;check for input of 2nd digit of hour
	call	Input_Check	  

	CPFSEQ	hex_C, A
	btfsc	skip_byte, 0, A
	bra	Cancel
	CPFSEQ	hex_D, A
	btfsc	skip_byte, 0, A
	bra	Delete
	CPFSEQ	hex_E, A
	btfsc	skip_byte, 0, A
	bra	Enter_Time
	
	movff	keypad_val, set_time_hrs2
	
	call	Write_keypad_val
	call	Write_colon	    ;write ':' to LCD
	call	delay
Set_Time3:	;check for input of 1st digit of minutes
	call	Input_Check	  
	
	CPFSEQ	hex_C, A
	btfsc	skip_byte, 0, A
	bra	Cancel
	CPFSEQ	hex_D, A
	btfsc	skip_byte, 0, A
	bra	Delete
	CPFSEQ	hex_E, A
	btfsc	skip_byte, 0, A
	bra	Enter_Time
	
	movff	keypad_val, set_time_min1
	
	call	Write_keypad_val
	call	delay
Set_Time4:	;check for input of 2nd digit of minutes
	call	Input_Check	  
	
	CPFSEQ	hex_C, A
	btfsc	skip_byte, 0, A
	bra	Cancel
	CPFSEQ	hex_D, A
	btfsc	skip_byte, 0, A
	bra	Delete
	CPFSEQ	hex_E, A
	btfsc	skip_byte, 0, A
	bra	Enter_Time
	
	movff	keypad_val, set_time_min2
	
	call	Write_keypad_val
	call	Write_colon	    ;write ':' to LCD
	call	delay
Set_Time5:	;check for input of 1st digit of seconds
	call	Input_Check	  
	
	CPFSEQ	hex_C, A
	btfsc	skip_byte, 0, A
	bra	Cancel
	CPFSEQ	hex_D, A
	btfsc	skip_byte, 0, A
	bra	Delete
	CPFSEQ	hex_E, A
	btfsc	skip_byte, 0, A
	bra	Enter_Time
	
	movff	keypad_val, set_time_sec1
	
	call	Write_keypad_val
	call	delay
Set_Time6:	;check for input of 2nd digit of seconds
	call	Input_Check	  
	
	CPFSEQ	hex_C, A
	btfsc	skip_byte, 0, A
	bra	Cancel
	CPFSEQ	hex_D, A
	btfsc	skip_byte, 0, A
	bra	Delete
	CPFSEQ	hex_E, A
	btfsc	skip_byte, 0, A
	bra	Enter_Time
	
	movff	keypad_val, set_time_sec2
	
	call	Write_keypad_val
	call	delay

Check_Enter:	;check for enter, delete or cancel repeatedly
	call	Input_Check
	
	CPFSEQ	hex_C, A
	btfsc	skip_byte, 0, A
	bra	Cancel
	CPFSEQ	hex_D, A
	btfsc	skip_byte, 0, A
	bra	Delete
	CPFSEQ	hex_E, A
	btfsc	skip_byte, 0, A
	bra	Enter_Time
	bra	Check_Enter
	
Enter_Time:	;check time valid and if so store, also reset LCD
	call	Input_Sort	;check time valid and if so enter into either alarm or time storage bytes
	
	call	LCD_cursor_off	;turn off LCD blinking and cursor
	
	bcf	operation_check, 0, A	;clear operation_check bit to signal end of operation
	bcf	alarm, 0, A
	
	call	LCD_Clear   ;clear LCD display
	
	return
	
Cancel:		;cancel operation and reset LCD
	call	LCD_cursor_off
	
	bcf	operation_check, 0, A
	bcf	alarm, 0, A
	
	call	LCD_Clear
	
	return
	
Delete:		;cancel operation and reset LCD
	btfss	alarm, 0, A ;test alarm bit and skip if set and alarm setting chosen
	bra	Cancel	
	bcf	alarm_on, 0, A	;clear alarm_on bit to turn off alarm
	bra	Cancel
  
Input_Check:	;read keypad and check not A, B, F  or null
	call	Keypad	;read Keypad
	movf	keypad_val, W, A    ;move keypad_val to W
	CPFSEQ	hex_null, A	    ;check if keypad = null
	bra	Keypad_Input_A	    ;if not branch to compare with A
	bra	Input_Check	    ;if null branch back to read keypad again
Keypad_Input_A:
	CPFSEQ	hex_A, A	    ;check if keypad = A
	bra	Keypad_Input_B	    ;if not branch to compare with B
	bra	Input_Check	    ;if A branch back to read keypad again
Keypad_Input_B:
	CPFSEQ	hex_B, A	    ;check if keypad = B
	bra	Keypad_Input_F	    ;if not branch to compare with F
	bra	Input_Check	    ;if B branch back to read keypad again
Keypad_Input_F:
	CPFSEQ	hex_F, A	    ;check if keypad = F	
	return			    ;if not F return	
	bra	Input_Check	    ;if F branch back to read keypad again
	
	
Display_Set_Time:	;display Set_Time LCD setupt
	call	LCD_Set_to_Line_1   ;set LCD cursor to line 1
	
	call	Write_Set_Time	    ;write 'Set Time' to LCD
	
	call	LCD_Set_to_Line_2   ;set LCD cursor to line 2
	
	call	Write_Time	    ;write 'Time: ' to LCD
	call	Write_zeros	    ;write '00:0:00' to LCD
	
	return
	
Display_Set_Alarm:	;display Set_Alarm LCD setupt
    	call	LCD_Set_to_Line_1
	
	call	Write_Alarm	    ;write 'Alarm:' to LCD
	call	Write_space	    ;write space to LCD

	btfss	alarm_on, 0, A	    ;check if alarm on and skip if on
	call	Write_no_alarm	    ;if not on write 'No Alarm'
	btfsc	alarm_on, 0, A	    ;check if alarm on and skip if off
	call	Display_Alarm_Time  ;if on display current alarm time
	
	call	LCD_Set_to_Line_2   ;set LCD cursor to line 2
	    
	call	Write_New	    ;write 'New: ' to LCD
	call	Write_zeros	    ;write '00:00:00' to LCD
	
	return

Display_Alarm_Time:
	movf	alarm_hrs, W, A	    ;move hex alarm hours to W
	call Write_Decimal_to_LCD   ; convert W to dec and display
	call	Write_colon	    ;write ':' to LCD
	
	movf	alarm_min, W, A	    ;move hex alarm min to W
	call Write_Decimal_to_LCD   ; convert W to dec and display
	call	Write_colon	    ;write  ':' to LCD
	
	movf	alarm_sec, W, A	    ;move hex alarm sec to W
	call Write_Decimal_to_LCD   ; convert W to dec and display
	return
	
Write_keypad_val:   ;write low nibble of byte to LCD
	movf	keypad_val, A	;move keypad_val to W
	call	LCD_Write_Low_Nibble	;write low nibble of W to LCD
	return	
    
Input_Sort:
	movf	set_time_hrs1, W, A ;move set_time_hrs1 to W
	mullw	0x0A		    ;multiply W by 10
	movf	PRODL, W, A	    ;move lower product to W
	addwf	set_time_hrs2, 0, 0 ;add set_time_hrs2 to W
	CPFSGT	check_24, A	    ;c heck W less than 24
	bra	Output_Error	    ;if not branch to ouput error
	movwf	temporary_hrs, A    ;if valid move to temporary_hrs
	
	movf	set_time_min1, W, A
	mullw	0x0A
	movf	PRODL, W, A
	addwf	set_time_min2, 0, 0
	CPFSGT	check_60, A
	bra	Output_Error
	movwf	temporary_min, A
	
	movf	set_time_sec1, W, A
	mullw	0x0A
	movf	PRODL, W, A
	addwf	set_time_sec2, 0, 0
	CPFSGT	check_60, A
	bra	Output_Error
	movwf	temporary_sec, A
	
	btfss	alarm, 0, A	    ;if alarm setting selected skip
	bra	Input_into_Clock    ;branch to Input_into_Clock
	bra	Input_into_Alarm    ;branch to Input_into_Alarm
	
Input_into_Clock:		    ;move temporary time to clock time
	movff	temporary_hrs, clock_hrs
	movff	temporary_min, clock_min
	movff	temporary_sec, clock_sec
	;call	Rewrite_Clock		
	return

Input_into_Alarm:		    ;move temporary time to alarm time
	movff	temporary_hrs, alarm_hrs
	movff	temporary_min, alarm_min
	movff	temporary_sec, alarm_sec
	
	bsf	alarm_on, 0, A	;turn alarm on by setting alarm_on bit to 1

	return

Output_Error:
	call    LCD_cursor_off	    ;turn off cursor and blinking
	call	LCD_Clear	    ;clear LCD display
	call	LCD_Set_to_Line_1   ;set position in LCD to first line
	call	Write_Error	    ;write 'Error' to LCD
	bra	Cancel		    ;branch to cancel 
    
	


