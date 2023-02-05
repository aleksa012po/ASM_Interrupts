;
; InterruptTwoLEDs.asm
;
; Created: 23/06/2022 22:26:21
; Author : Aleksandar Bogdanovic
;


.include "M328Pdef.inc"
.org 0x0000
rjmp main
.org 0x0002
rjmp delay

main:
	CLI						;onemogucuje interrupt tokom sekvence / Clears the Global Interrupt Flag in SREG
	LDI R17, LOW(RAMEND)	;Load the low byte value of ramend
	OUT SPL, R17
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17			;Postavlja SP (Stack Pointer)	
	LDI R16, 0xFF		
	OUT DDRB, R16			;Postavlja PINB4 i PINB5 kao izlaz
	LDI R16, 0b00001000
	OUT PORTB, R16			;Ukljucuje PINB5, iskljucuje PINB4
	LDI R16, 0b00000100
	OUT DDRD, R16			;Postavlja PIND2 kao ulaz
	LDI R16, 0b00000100
	OUT PORTD, R16			;Ukljucuje PullUp resistor
	LDI R16, 0x01			;Omogucava ekserne prekide
	OUT EIMSK, R16			;External Interrupt Mask Register
	LDI R16, 0b00000010		;Menja okidace (triggers) logical change
	STS EICRA, R16			;Store direct to SRAM, External Interrupt Control Register A
	IN R16, PORTB
	SEI						;Omogucuje interrupt
loop:
	rjmp loop
blink_int:
	PUSH R17				;Push register on stack
	IN R17, SREG			;Stavlja statusreg na Stack Pointer
	COM R16
	OUT PORTB, R16			;Negira PORTB (PINB4 i PINB5)
	OUT SREG, R17			;Vraca status registar
	POP R17					;Pop register from stack
	RETI					;Vraca se iz interrupt-a (INT0) - (Interrupt return, PC <- STACK )
	 
	 delay:
	ldi  r20, 21
    ldi  r21, 75
    ldi  r22, 191
L1: dec  r22
    brne L1
    dec  r21
    brne L1
    dec  r20
    brne L1
	rjmp blink_int
