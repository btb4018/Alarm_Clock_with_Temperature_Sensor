#include <xc.inc>
    
    
extrn	LCD_Setup, LCD_Clear, LCD_Set_Position, LCD_Send_Byte_D
extrn	LCD_Write_Hex, LCD_Write_Character, LCD_Write_Low_Nibble ; external LCD subroutines
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn	Multiply24x8, Multiply16x8 
extrn	out_16x8_h, out_16x8_m, out_16x8_l, in_16x8_8, in_16x8_16h, in_16x8_16l
extrn   out_24x8_l, out_24x8_ul, out_24x8_lu, out_24x8_u, in_24x8_24l,in_24x8_24m, in_24x8_24h, in_24x8_8
    
global	Temp
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
in_K_h: ds 1	;k high byte, an input for 16x16
in_K_l: ds 1	;k low byte, an input for 16x16
in_AD_l:    ds 1
in_AD_h:    ds 1
    
out_16x16_l:	ds 1	;16x16, low byte output
out_16x16_ul:	ds 1	;16x16, second lowest byte output
out_16x16_lu:	ds 1	;16x16, second highest byte output
out_16x16_u:	ds 1	;16x16, high byte output
intermediate1_16x16:	ds 1	;16x16, intermediate used while multiplying
intermediate2_16x16:	ds 1	;16x16, intermediate used while multiplying

    
psect	temp_code, class=CODE
	;convert and display binary voltage as decimal on LCD;
Temp:
	call	ADC_Read	; reads voltage value and stores in ADRESH:ADRESL
	
	call	Conversion	;converst from hex to decimal
	
	movlw	10110010B	;write degrees symbol to LCD
	call	LCD_Write_Character
	movlw	0x43		;write 'C' to LCD
	call	LCD_Write_Character
	
	return

	;convert hex to decimal;
Conversion:
	movlw	0x8A	;move least significant byte of conversion factor to in_K_l
	movwf	in_K_l, A
	movlw	0x41	;move least significant byte of conversion factor to in_K_h
	movwf	in_K_h, A
	movff	ADRESH, in_AD_h	;move most siginicant byte of ADC output to in_AD_h
	movff	ADRESL, in_AD_l	;move least siginicant byte of ADC output to in_AD_l
	
	call  Multiply16x16_ADRES   ;1st step: multiply ADC output by conversion factor
	
	movlw	0x0A	;move dec10 to in_24x8_8
	movwf	in_24x8_8, A
	
	movff	out_16x16_lu, in_24x8_24h	;move 1st multiplication remainders into 2nd multiplication inputs
	movff	out_16x16_ul, in_24x8_24m
	movff	out_16x16_l, in_24x8_24l
	call	Multiply24x8	;2nd step: multiply 1st multiplication remainder by 0x0A
	movf	out_24x8_u, W, A
	call	LCD_Write_Low_Nibble	;display low nibble of most sig byte of answer
	
	
	
	movff	out_24x8_lu, in_24x8_24h	;move 2nd multiplication remainders into 3rd multiplication inputsn
	movff	out_24x8_ul, in_24x8_24m
	movff	out_24x8_l, in_24x8_24l
	call	Multiply24x8  ;3rd step: multiply 2nd multiplication remainder by 0x0A
	movf	out_24x8_u, W, A
	call	LCD_Write_Low_Nibble	;display low nibble of most sig byte of answer
	
	movlw	0x2E
	call	LCD_Write_Character ;writing decimal point
	
	movff	out_24x8_lu, in_24x8_24h	;move 3rd multiplication remainders into 4th multiplication inputs
	movff	out_24x8_ul, in_24x8_24m
	movff	out_24x8_l, in_24x8_24l
	call	Multiply24x8  ;4th step: multiply 3rd multiplication remainder by 0x0A
	movf	out_24x8_u, W, A
	call	LCD_Write_Low_Nibble	;display low nibble of most sig byte of answer
	
	return
	
Multiply16x16_ADRES:
	   ;multiplying least sig byte of first number with second number;
	   
	movff	in_AD_l, in_16x8_16l  ;least sig byte of second number
	movff	in_AD_h, in_16x8_16h  ;most sig byte of second number  
	
	movff	in_K_l, in_16x8_8		;least sig byte of first number into W
	call	Multiply16x8	;multiply 
	movff	out_16x8_l, out_16x16_l	;store product in file registers
	movff	out_16x8_m, out_16x16_ul
	movff	out_16x8_h, out_16x16_lu
	
	    ;multiplying most sig byte of first number with second number;
	    
	movff	in_K_h, in_16x8_8		;most sig byte of first number
	call	Multiply16x8	;multiply
	movff	out_16x8_l, intermediate1_16x16	;store product in file registers
	movff	out_16x8_m, intermediate2_16x16
	movff	out_16x8_h, out_16x16_u
	
	    ;adding the two products to get final product;
	    
	movf	intermediate1_16x16, W, A	     
	addwfc	out_16x16_ul, 1, 0	;adding second most sig byte of first product with least sig byte of second prod

	movf	intermediate2_16x16, W, A
	addwfc	out_16x16_lu, 1, 0  ;adding most sig byte of first product with second least sig byte of second prod, with carry
	
	movlw	0x00
	addwfc	out_16x16_u, 1, 0  ;add carry to most sig byte of second prod
	return


