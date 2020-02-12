;*****************************************************************************
;*
;*		Title:		Magnet Trigger Control
;*		Authors: 	Tony Fields
;*					Uros Topalovic
;* 		Date:		1. 10/19/2015	- Initial Program Start 
;*					2. 12/10/2015	- Modification Complete
;*					3. 06/26/2018	- Changing 30s timeout to 29s
;*
;*
;*		Resources:
;*			PORT A:
;*				A0 VSync Blue LED
;*				A1 !Mag Energize MAgnet
;*				A2 NU (Not Used)
;*				A3 NU
;*				A4 NU
;*				!MCLR INIT
;*			PORT B:
;*				B0 !Reset CLear Time
;*				B1 !Start/!Stop
;*				B2 NU
;*				|
;*				B& NU
;*
;*
;*			Timer Module
;******
;*
;*
;*		Configuration:
;*			Internal Clock Generation 4MHz
;*
;*			Registers;
;*				Tristate Port A 	(TRISA)
;*				Tristate Port B 	(TRISB)
;*				Configuration Register	(CONFIG)
;*				Oscillator Control Register (OSCCON)
;*				Option Regstier 			(OPTION REG)
;*				Timer0 Control				(T0CON)
;*
;*
;*
;************* PROGRAM OUTLINE   **************************************
;*
;*
;*
;*		INIT: Program initialization (Power On or !MCLR) 
;*			Timer0 Free Timing with Rollover interrupt
;*			Timing Variable for Interrupt set for apprx
;*			500 micro second Timeouts
;*			Timeouts used for MAG On Duration Intervals
;*			Cumulative Count0 register set for 1 second
;*			BLUE LED ON Duratioin during MAG On period
;*			Cumulative Count1 register set for 2.5 minute
;*			MAG On Interval when Start mode is active
;*		
;*		VARS:
;*			Tick	=>	Timer Interrupt Tick approx 500us
;*			MagP	=>	Magnet Pulse On or Energized
;*			Count0  =>	Count0 Cummulative 1 second count
;*			Count1  =>  Count1 Cummulative 2.5 minute count
;*			IdleOut =>  5 minute stop mode goto sleep
;*			Reset	=>  Disable MagP Clear Count0&1
;*			Start/!Stop => Start or Stop mode
;* 			Sleep	=>	Was in sleep mode due to idle time
;*
;*
;*
;*************	END PROGRAM OUTLINE ************************************
;* Constants

STAT0	  EQU 03H		;* Status Register Bank 0
STAT1	  EQU 83H		;* Status Register Bank 1
IND		  EQU 00H		;* Indirect Addressing
TMR0	  EQU 01H		;* Timer0 Register
RP0		  EQU 05H		;* Bank Select Bit
FSR		  EQU 04H		;* File Select Register Bank 0
FSR1	  EQU 84H		;* File Select Register Bank 1
PORTA	  EQU 05H		;* Port A Register
PORTB	  EQU 06H		;* Port B Register
INTCON 	  EQU 0BH		;* Interrupt Control Register

;* Bank 1
OPTREG	  EQU 81H		;* Option Register
TRISA	  EQU 85H		;* Port A Direction Register
TRISB	  EQU 86H		;* Port B Direction Register

;* BIT TESTS
T0IF	  EQU 02H		;* Timer0Overflow Interrupt Flag Bit
T0IE	  EQU 05H		;* Peripheral Interrupts Enable
INTE	  EQU 04H		;* Port B Interrupt Clear Button WAKEUP
INTF      EQU 01H		;* Port B Interrupt Flag
GIE		  EQU 07H		;* Global Interrupt Enable
TO		  EQU 04H		;* Time Out Status Bit
PD		  EQU 03H		;* Power down Status Bit
W   	  EQU 00H		;* Working Register Destination
F	      EQU 01H		;* File Register Destination
Z  		  EQU 02H		;* Zero Bit
C		  EQU 00H		;* Carry Bit
TLO	      EQU 0xD0		;* Low Value of Seconds Count 					NOT REALLY A SECOND. CANNOT BE COUNTED TOWARDS ROUND NUMBER OF SECONDS
THI		  EQU 07H		;* High Value of Seconds Count					NEEDS CHANGE AS WELL AS COUNTER BELOW IN ORDER TO CHANGE DURATIONS
MLO		  EQU 24H		;* Low Value of Mag Duration
MHI	      EQU 05H		;* High Value of Mag Duration
MVA		  EQU 0xFF		;* For 4.25 Minute IDLE
MAG 	  EQU 99H		;* Magnet Interval of 2.5 minutes 150 seconds
MOE		  EQU 00H		;* Magnet On Blue LED Off
MON		  EQU 01H		;* Magnet On Blue LED On
MOF		  EQU 02H		;* Magnet Off Blue LED Off
BON		  EQU 03H		;* Magnet Off Blue LED On
PRLD	  EQU 0x0A		;* Timer Register PreLoad Value for 500us
CLB		  EQU 00H		;* Clear State Bit
SSB		  EQU 01H		;* Start Stop Key Bit
MTC		  EQU 00H		;* Magnet On Duration Bit
CLR		  EQU 01H		;* Master Clear Bit in State Register
RUN 	  EQU 02H		;* Run Bit in State Register
IDLE	  EQU 03H		;* Idle Bit in State Register
TEST      EQU 04H		;* Test Bit in State Register
SEC		  EQU 05H		;* One Second Bit
TOUT	  EQU 06H		;* 2.5 Minute Interval Elapsed
TICK	  EQU 07H		;* 500us Tick Interrupt
T40		  EQU 0xF7		;* 240 Second Mag Interval						COUNTING NUMBER OF 'SECONDS'
O80		  EQU 0xC9		;* 180 Second Mag Interval
NTY		  EQU 0x65		;* 90 Second Mag Interval
STY		  EQU 0x43		;* 60 Second Mag Interval
TTY 	  EQU 0x22		;* 30 Second Mag Interval

;*  	------------------------------
;*	The following is an assignment of address values for all of the
;*	configuration registers for the purpose of table reads
;*

CONFIG	  EQU H'2007'

;*	------- CONFIG Options	-------------------------
MYCFG	  EQU H'3FF2'	; No Code Protect Power Up Timer No WDT HS OSC


;* Variables
Cnt0L	  EQU 20H		;* Count Low Register
Cnt0H	  EQU 21H		;* Count High Register
Cnt1L	  EQU 22H		;* Count1 Low Register
Cnt1H	  EQU 23H		;* Count1 High Register
Keys	  EQU 24H		;* Keys Bits 0 - 2
Idle	  EQU 25H		;* 5 Minutes Idle Goto Sleep
MagP	  EQU 26H		;* Mag Pulse On
Rst		  EQU 27H		;* Minute Counter value 60 seconds
Slp		  EQU 28H		;* Was in Sleep Mode
StSp	  EQU 29H		;* Start or Stop mode Count Register
State	  EQU 2AH		;* State of Processor
Tick 	  EQU 2BH		;* Timer Tick 500us
Temp 	  EQU 2CH		;* Temporary for Nada
Mag		  EQU 2DH		;* Magnet Timeout Variable
tmpc	  EQU 40H		;* W Save for Serial Interrupt Routine
tmpt	  EQU 41H		;* W Save for Timer1 Interrupt Routine
tmps	  EQU 42H		;* Scratch
tmpe	  EQU 43H		;* Tmp Entry into ISR

;* -----------------------------------------------------
config MYCFG

;* Program Start

org 0x0000			;* Reset Vector 4 Words
PStart nop
	nop
	goto init		;* Will set program loop
	org 0x0004		;* Interrupt Vector
IVect goto isr		;* Will Poll to Find interrupt source
init nop
	bcf		STAT0, RP0
	clrf	PORTB
	bsf		STAT0, RP0		;* Switch to Bank 1
	movlw   0FCH			;* Port A
	movwf	TRISA			;* Bit0&1 are Output
	movlw	0FFH			;* Port B
	movwf	TRISB			;* Port B is Input
	clrf	OPTREG			;* Pull-Ups Internal 1:2 Prescale
	bcf		STAT1, RP0		;* Switch to Bank 0
	movlw 	4FH				;* Stack Pointer
	movwf	FSR
	movlw	20H				;* Enable Timer Interrupts
	movwf	INTCON			;*
	movlw 	MOF				;* Blue LED OFF & Magnet Off 0010b
	movwf	MagP
	movwf	PORTA
	movlw	0x01
	andwf	State, F		;* If this is a reset preserve State Bits
	movlw	TLO				;* One Second Count 2000 or 07D0
	movwf	Cnt0L
	movlw	THI
	movwf 	Cnt0H
	movlw  	MLO
	movwf	Cnt1L
	movlw	MHI
	movwf	Cnt1H
	bcf		State, TEST
	clrf	Keys
	clrf	Idle
	movlw	MVA				;* 5 Minute Idle Count or 02
	movwf	Rst
	clrf	Slp
	;movlw MAG				;* 2.5 Minute Count 150 Seconds or 09C
	movf	PORTB, W 		;* Read Port B for Timeout Value
	andlw	0xF0
	movwf	Temp
	;***************************** Determine Timeout Variable Value
	movlw 	T40
	movwf 	Mag
	movf	Temp, W
	xorlw 	0xF0			;* 240 seconds
	btfsc	STAT0, Z
	goto to
	movlw 	O80
	movwf 	Mag
	movf	Temp, W
	xorlw 	0x70			;* 180 seconds
	btfsc	STAT0, Z
	goto to
	movlw 	NTY
	movwf 	Mag
	movf	Temp, W
	xorlw 	0xB0			;* 90 seconds
	btfsc	STAT0, Z
	goto to
	movlw 	STY
	movwf 	Mag
	movf	Temp, W
	xorlw 	0xD0			;* 60 seconds
	btfsc	STAT0, Z
	goto to
	movlw 	TTY
	movwf 	Mag
	movf	Temp, W
	xorlw 	0xE0			;* 30 seconds
	btfsc	STAT0, Z
	goto to
	movlw 	MAG				;* 150 Seconds if there is fall through
	movwf 	Mag

to nop
	movf 	Mag, W
	movwf 	StSp
	clrf	Tick
	clrf	Temp
	bcf		State, CLR
	nop
start nop
	movlw 	PRLD			;* Load Timer Value
	movwf	TMR0
	bsf		INTCON, GIE		;*

;********************************************

	movlw	BON
	movwf	PORTA
p0 	btfss	State, SEC		;* TEST BLOW UP Blue ON
	goto p0
	bcf State, SEC
p1 	btfss	State, SEC
	goto p1
	bcf		State, SEC
	movlw	MOF
	movwf	PORTA

;*******************************************

	call 	chky			;* Enter Test Mode
	btfsc	State, CLR
	bsf		State, TEST		;* Enter Test Mode

;******* Program Loop **********************

lp0 nop						;* Waste Some Time
	call 	chky			;* Check Key Inputs for Mode Changes
	call 	doit			;* Execute Mode Depending On Time
	btfsc	State, IDLE		;* No Run State After 5 Minutes Goto Sleep
	goto 	ps				;* Idle to long so go to sleep
	goto 	lp0				;* Program Loop0
ps 	nop
	bsf		INTCON, INTE
	sleep
	goto 	lp0

; return 					;******************************************
chky nop					;* Check For Key Press
	clrf	Temp
	movf 	PORTB, W
	movwf 	Keys
	btfss	Keys, SSB		;* Clear = Key Press
	goto	tglrun			;* Toggle State Run Bit
	btfss	Keys, CLB		;* Clear = Key Press
	goto 	clrst			;* Clear States and Time
	btfsc	State, SEC
	bcf		State, SEC
	return
tglrun nop
;*******************************************
	movlw	BON				;* Test Only Blue LED On
	movwf	PORTA
p2 	btfss	State, SEC
	goto 	p2
	movlw 	MOF
	movwf	PORTA
;******************************************
; btfss State, SEC			;* Make Sure to LockOut For One Second
; goto 	rd1
	bcf		State, SEC
	bsf		Temp, RUN
	movf	Temp, W
	xorwf	State, F		;* Toggle Run Bit Start/Stop
	btfsc	State, RUN		;* DO We Need to Arm Output
	bsf		State, TOUT		;* Yes OUT IS ARMED
	bcf		State, CLR		;* Make Sure to Clear Execution State
	goto 	rd1
clrst nop
;******************************************
	nop
	;movlw BON				;* Test Only Blue LED On
	;movwf PORTA			;*
p3	btfss	State, SEC
	goto p3
	bcf		State, SEC
	movlw 	MOF
	movwf	PORTA

;*******************************************
	bsf		State, CLR
	btfsc	State, SEC
	bcf		State, SEC

rd1 nop
	return
doit nop					;* Execute Mode According to Time
	btfsc	State, CLR		;* Clear All Modes Except Test if set
	goto	camet
	btfsc	State, RUN		;* Run Mode if Set
	goto 	rm
	btfss	State, TEST		;* Execute Test Signal Generation if Set
	return
	btfss	State, TICK
	return					;* No Output Toggle Activation
	movlw	0x03			;* Toggle Both Vsync & Magnet
	xorwf	MagP, F			;* Store Result
	movf	MagP, W
	movwf	PORTA			;* Output Port Values
	bcf		State, TICK
	return

camet nop					;* Clear All Modes Except Test
	bcf		State, CLR		;* Clear Mode Flag
	btfsc	State, TEST		;* We are in Test Mode so Invalid Key
	return
	movlw 	MOF				;* Blue LED OFF & Magnet Off 0010b
	movwf 	MagP			;* 
	movwf	PORTA
	movlw	0x10			;* Preserve TEST
	andwf	State, F
	movlw	TLO
	movwf 	Cnt0L
	movlw	THI
	movwf	Cnt0H
	movlw	MLO
	movwf	Cnt1L
	movlw	MHI
	movwf	Cnt1H
	clrf	Keys
	clrf	Idle
	movlw	MVA
	movwf	Rst
	clrf	Slp
	;movlw	MAG
	movf	Mag, W
	movwf	StSp
	clrf	Tick
	clrf	Temp
	btfsc	State, TICK
	bcf		State, TICK
	return
rm nop
	btfss 	State, TOUT		;* Can we Output? Set = Yes
	return					;* No So Let's Return
	bcf		State, TOUT		;* Disarm Until Next Interval 
	bcf		State, MTC		;* We'll wait in this section for timeout
	movlw	MLO
	movwf	Cnt1L
	movlw 	MHI
	movwf	Cnt1H
	movlw	MON				;* Turn MAgnet & Blue LED ON
	movwf	PORTA
w0	btfss	State, MTC
	goto w0
	movlw	BON
	movwf	PORTA
	bcf		State, TICK
	bcf		State, IDLE
	return
	goto lp0				;* If we are executing bad thing happened
isr bcf INTCON, T0IF
	movf	PORTB, F
	bcf		INTCON, INTF
	bcf		INTCON, INTE
	movwf	IND				; Save W
	movf	STAT0, W
	decf	FSR, F 			; Move to next Stack Position
	movwf	IND				;* Save STATUS	Register
	movlw	PRLD
	movwf	TMR0			;* Reset Timer0
	bsf		State, TICK
	decfsz	Cnt1L, F
	goto 	os
	decfsz	Cnt1H, F
	goto	os

	;*********************** One Second Has Elapsed
	bsf		State, MTC
	movlw	MLO				;* Reset Counter
	movwf	Cnt1L
	movlw 	MHI
	movwf	Cnt1H
os	decfsz	Cnt0L, F
	goto 	dn
	decfsz	Cnt0H, F
	goto	dn

	;*********************** One Second Has Elapsed
	bsf		State, SEC
	movlw	MOF
	movwf	PORTA			;* Turn Off Blue LED & MAgnet
	movlw	TLO				;* Reset Counter
	movwf	Cnt0L			
	movlw 	THI
	movwf	Cnt0H
	btfss	State, RUN
	goto	id
	decfsz	StSp, F
	goto	dn
	;************************ 2.5 Minutes or MAG Limit Has Elapsed

	;movlw MAG				;* Constant for approx 2.5 minutes timeout
	movf	Mag, W 			;* Variable for selectable timeout
	movwf	StSp
	bsf		State, TOUT
	btfsc	State, RUN
	goto 	dn
id	decfsz	Rst
	goto dn
	;************************ 4.25 Minutes Has Elapsed
	movlw	MVA
	movwf	Rst
	bsf		State, IDLE
	nop
dn	nop
	movf 	IND, W 			;* Restore Entry STATUS Register Value
	incf	FSR, F			;*
	movwf	STAT0			;* Restore Status
	movf	IND, W 			;* Restore W Register
	bsf		INTCON, T0IE
	retfie
	end
