#include <xc.inc>

extrn	clock_sec, clock_min, clock_hrs
extrn	Write_ALARM, Write_Snooze
extrn	Keypad, keypad_val
extrn	LCD_delay_x4us, LCD_Set_to_Line_2, LCD_Clear
extrn	hex_C, hex_A, skip_byte
    
global	alarm_sec, alarm_min, alarm_hrs
global	Check_Alarm, Alarm_Setup
global	alarm_on
    
psect	udata_acs

;reserveed bytes for storage of alarm time	
alarm_sec:	ds  1
alarm_min:	ds  1
alarm_hrs:	ds  1
    
    
alarm_on:   ds 1    ;reserve byte to indicate if alarm on or off
buzz_on_or_off: ds	1   ;reserve byte to indicate if to buzz or not

buzzer_counter_1: ds 1	;reserve byte to count down number of remaining loops of buzz_loop_1
buzzer_counter_2: ds 1	;reserve byte to count down number of remaining loops of buzz_loop_2

alarm_countdown: ds 1    ;reserve byte to countdown when alarm going off
    
psect	Alarm_code, class=CODE
    
Alarm_Setup:	;clear alarm time
	clrf	alarm_sec, A
	clrf	alarm_min, A
	clrf	alarm_hrs, A
	
	bcf	alarm_on, 0, A	;clear alarm_on bit to turn alarm off
	bcf	buzz_on_or_off, 0, A	;clear buzz_on_or_off bit 
	
	clrf	alarm_countdown, A  ;clear alarm_countdown
	return
	
Check_Alarm:	
	movlw	0x00	;move 0 to W
	cpfseq	alarm_countdown, A	;check if alarm_countdown = W 
	bra	Decrement_Alarm_Countdown   ;if not equal branch to Decrement_Alarm_Countdown 
	bra	Compare_Alarm	;if equal branch to Compare_Alarm

Decrement_Alarm_Countdown:
	decf	alarm_countdown, A  ;decrease alarm_countdown by one
	call	ALARM	
	return
	
Compare_Alarm:  
	btfss	alarm_on, 0, A	;check if alarm_on bit set to see if alarm on and skip if on
	return	    ;return as alarm off
	movf	alarm_hrs, W, A	;move alarm_hrs to W
	CPFSEQ	clock_hrs, A	;check if W = clock_hrs
	return
	movf	alarm_min, W, A
	CPFSEQ	clock_min, A
	return
	movf	alarm_sec, W, A
	CPFSEQ	clock_sec, A
	return
	
	movlw	0x3C	;if alarm time = clock time, move 0x3C = dec 60 to W
	movwf	alarm_countdown, A  ;set alarm_countdown to 0x3C
	
	call ALARM
	return
ALARM:
	call	Write_ALARM ;Write 'ALARM'

	BTG	buzz_on_or_off,0 ;toggle buzz_on_or_off bit
	call	Buzzer
	
	call	LCD_Clear

	return	
	  
Buzzer:	
	;Initialize
	bcf	TRISB, 6, A ;set Port B 6 as an output
	
	movlw	0x64
	movwf	buzzer_counter_1, A ;set buzzer_counter_1 to 0x64 = dec 100
	movlw	0x1E
	movwf	buzzer_counter_2, A ;set buzzer_counter_2 to 0x1E = dec 30

Buzz_Loop_1:
    
Check_Cancel_Snooze:	;check if C to cancel or A to snooze pressed
	call	Keypad	    ;read keypad
	movf	keypad_val, W, A    
	CPFSEQ	hex_C, A    ;check if keypad_val is C and skip if so 
	btfsc	skip_byte, 0, A	;skip next line
	bra	Cancel_Alarm	
	CPFSEQ	hex_A, A    ;check if keypad_val is A and skip if so 	
	btfsc	skip_byte, 0, A	;skip next line
	bra	Snooze_Alarm	    
   

	call	Buzz_Loop_2
	movlw	0x1E	    ;reset buzzer_counter_2 to 0x1E
	movwf	buzzer_counter_2, A
	
	decfsz	buzzer_counter_1, A ;decrease buzzer_counter_1 by 1
	bra	Buzz_Loop_1
	return
    
Buzz_Loop_2:
	call	Buzz_Sequence	;call Buzz_Sequence to create buzz sound
    
	decfsz	buzzer_counter_2, A ;decrease buzzer_counter_2 by one and skip if 0
	bra	Buzz_Loop_2	
	return
	
	
Buzz_Sequence:	
Check_if_Buzz:
	btfss	buzz_on_or_off, 0, A	;check if buzz_on_or_off bit set and skip if set
	bra	No_Buzz
	bra	Yes_Buzz
	
No_Buzz:    ;delay by 2 x 128 = 256 us 
	call	Delay_Buzzer
	call	Delay_Buzzer
	return
	
Yes_Buzz:	
	bsf	LATB, 6, A	;Buzzer Ouput high
	call	Delay_Buzzer	
	bcf	LATB, 6, A	;Buzzer Ouput low
	call	Delay_Buzzer
	return	
	
Delay_Buzzer:	;128 us delay
	movlw   0x20 ;move 0x20 = dec 32 to W
	call    LCD_delay_x4us	
	return
	
Cancel_Alarm:	;stop alarm going off
	clrf	alarm_countdown, A  ;clear alarm_countdown
	return	
	
Snooze_Alarm:	;stop alarm going off and set new alarm for five mins after original 
	call	LCD_Clear   ;clear LCD 
	
	clrf	alarm_countdown, A  ;clear alarm_countdown
	call	Write_Snooze	    ;Write snooze to LCD
	
	movlw	0x05	;move 0x05 to W	    
	addwf	alarm_min, A	;add W to alarm_min
	movlw	0x3B		;move 0x3B = dec 59 to W        
	CPFSGT	alarm_min, A	;check if alarm_min greater than 59 and skip if so 
	return
	movlw	0x3C		;move 0x3C = dec 60 to W
	subwf	alarm_min, 1, 0	;subract 0x3C from alarm_min and store result in alarm_min
	incf	alarm_hrs, A	;increase alarm_hrs by 1
	movlw	0x17		;move 0x17 = dec 23 to W
	CPFSGT	alarm_hrs, A	;check if alarm_hrs greater than 23 and skip if so     
	return
	movlw	0x18		;move 0x18 = dec 24 to W
	subwf	alarm_hrs, 1, 0	;subract 0x18 from alarm_hrs and store result in alarm_hrs
	
	call	LCD_Clear
	
	return


