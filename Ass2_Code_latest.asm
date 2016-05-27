	   title    "Assignment 2 Markus"
	   list     p=16f877A
	   include  "p16f877a.inc"
	   __CONFIG  _CPD_OFF&_HS_OSC&_WDT_OFF&_PWRTE_ON&_BODEN_ON&_LVP_OFF&_WRT_OFF&_DEBUG_OFF&_CP_OFF

;#############################################################   
;
; Program Description:
;
; Generate Pulse depending on switch states
;
;
;#############################################################   
; Variable declarations.

delcnt       equ    h'20'        ; parameter register for del500us routine
count        equ    h'21'        ; Variable storage area starts at h'20'
count1       equ    h'22'        ; for the 16F877a chip
count2       equ    h'23'

;#############################################################

; Initial system vectors.
 
	org     h'00'           ; initialise system restart vector
	clrf	STATUS
	clrf	PCLATH
	goto    start           ;jump to "main" part

;############################################################# 
; System subroutines.

	org     h'05'           ; start of program space

;#############################################################
; init : initialise I/O ports
;1=input 0=output
;Register counting from Right to Left

init    
	bsf     STATUS, RP0    ; enable page 1 register set
	bcf     STATUS, RP1

	movlw	h'07'
	movwf	ADCON1		   ; set PORTA to be digital rather than analogue

	movlw   b'11111111'
	movwf   TRISA          ; ALL Ports on Register A are Input
	
	movlw   b'11111111'                 
	movwf   TRISB          ; ALL Ports on Register B are Input
	
	movlw   b'11111100'    ; set RC0 and RC1 to Output     
	movwf   TRISC          ; all other Ports on Register C are input
	
	movlw   b'11111111'                 
	movwf   TRISD          ; PORTD input

	bcf     STATUS, RP0    ; back to page 0 register set

	return

;#############################################################			DELAY					#############################################################
;NOTE: Its more accurate to use loops through NOPS than loops through a onetime defined loop of nops
;that means for its in accurate to use a 1us nop delay and use this 1000 times this is not equal to 1000us
;because the loops and everything around consumes time, too
;#############################################################
;Provide a 10uS delay
;For 5 times loop through 7 NOP's
del10uS
	movlw   d'5' ;copy number x to W
	movwf   delcnt ;move the content from W to 'delcnt'
del10uS_loop    
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz  delcnt,f ;decrease count
	goto    del10uS_loop ;repeat
	return    
;#############################################################
;Provide a 50uS delay
;For 25 times loop through 7 NOP's
del50uS
	movlw   d'25' ;copy number x to W
	movwf   delcnt ;move the content from W to 'delcnt'
del50uS_loop    
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz  delcnt,f ;decrease count
	goto    del50uS_loop ;repeat
	return

;#############################################################
;Provide a 100uS delay
;For 50 times loop through 7 NOP's
del100uS
	movlw   d'50' ;copy number x to W
	movwf   delcnt ;move the content from W to 'delcnt'
del100uS_loop    
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz  delcnt,f ;decrease count
	goto    del100uS_loop ;repeat
	return

;############################################################# 
;Provide a 500uS delay
;For 249 times loop through 7 NOP's
;set delcnt = 249
del500uS
	movlw   d'249' ;copy number x to W
	movwf   delcnt ;move the content from W to 'delcnt'
del500uS_loop    
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz  delcnt,f ;decrease count
	goto    del500uS_loop ;repeat
	return
 
;#############################################################
;Provide a 3mS delay
;For 6 times run del500uS
;set count1 = 6
del3mS
	movlw	d'6' ;copy number x to W
	movwf	count1 ;move the content from W to 'count1'
del3mS_loop
	call del500uS
	decfsz	count1,f  ;decrease count
	goto del3mS_loop ;repeat
	return

;############################################################# 
;Provide a 500mS delay
del500mS
	movlw	d'100';for 100 times run the next loop ;copy number x to W
	movwf	count1 ;move the content from W to 'count1'
del500mS_lp1
	movlw	d'10';for 10 times pause for 500uS ;copy number x to W
	movwf	count2 ;move the content from W to 'count2'
del500mS_lp2
	call	del500uS
	decfsz	count2,f ;decrease count
	goto	del500mS_lp2

	decfsz	count1,f ;decrease count
	goto	del500mS_lp1

	return

;#############################################################			SWITCH CONFIG					#############################################################

; SWITCH-N IS PRESSED / OR NOT

;SWITCH N is Active
SWITCH_A
;PARAMETER C = PULSES
	bsf		PORTC,1;Set PortC1 High
	call	PARMC;Pause for Parameter C Time
	bcf		PORTC,1;Set PortC1 Low
	call	PARMC;Pause for Parameter C Time
	return
;SWITCH N is NOT Active
SWITCH_NA
	call	PARMC;Pause for Parameter C Time
	call	PARMC;Pause for Parameter C Time
	return

;#############################################################			PARAMETER CONFIG					#############################################################

;PARAMETER A - START
;DEFAULT: 3.0mS
PARMA
	call del3mS
	return

;PARAMETER B - PAUSE START/END
;DEFAULT: 1.5mS
PARMB
	movlw	d'3'; 3x 500uS ;copy number x to W
	movwf	count1 ;move the content from W to 'count1'
PARMB_loop
	call del500uS
	decfsz	count1,f ;decrease count
	goto PARMB_loop ;repeat
	return

;PARAMETER C - SWITCH TIME
;DEFAULT 350uS
;just run 3x 100uS 1x 50uS
PARMC
	call	del100uS
	call	del100uS
	call	del100uS
	call	del50uS
	return

;PARAMETER D
;DEFAULT 8
;-> SEE SWITCHES

;PARAMETER E
;DEFAULT: 3.0mS - END
PARME
	call del3mS
	return

;#############################################################			MAIN PROGRAM 					#############################################################

start  
	call    init
	bcf	PORTC,1;Set Output to 0

loop
;WAITING FOR YOU TO PUSH THE BUTTON (PORTA3)
	btfsc	PORTA,3
	goto    loop

;####################################
;			SYNC PULSE
	bsf		PORTC,0
	call	del10uS
	bcf		PORTC,0

;####################################
;			START PULSE
;Set PortC High for 3ms
;PARAMETER A 3mS
	bsf		PORTC,1
	call	PARMA
	bcf		PORTC,1
; Now 1.5ms pause
	call PARMB

;####################################
;Check the switches
;if the switch is enabled set the output pulse, else pause 2x

	btfss	PORTB,0
	call	SWITCH_A
	btfsc	PORTB,0
	call	SWITCH_NA	

	btfss	PORTB,1
	call	SWITCH_A
	btfsc	PORTB,1
	call	SWITCH_NA	

	btfss	PORTB,2
	call	SWITCH_A
	btfsc	PORTB,2
	call	SWITCH_NA	

	btfss	PORTB,3
	call	SWITCH_A
	btfsc	PORTB,3
	call	SWITCH_NA	

	btfss	PORTB,4
	call	SWITCH_A
	btfsc	PORTB,4
	call	SWITCH_NA	

	btfss	PORTB,5
	call	SWITCH_A
	btfsc	PORTB,5
	call	SWITCH_NA	

	btfss	PORTB,6
	call	SWITCH_A
	btfsc	PORTB,6
	call	SWITCH_NA	

	btfss	PORTB,7
	call	SWITCH_A
	btfsc	PORTB,7
	call	SWITCH_NA	

;###############################
; FIRE END PULSE
; 3ms PortC1 on High
;Parameter E 3mS
	bsf		PORTC,1
	call	PARME
	bcf		PORTC,1

;Now 1.5ms pause
;Parameter B 1.5mS
	call PARMB

;###############################
;Now Repeat everything
	goto	loop;#############################################################			The END					##########################################################
    end