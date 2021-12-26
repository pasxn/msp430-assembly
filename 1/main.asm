;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
init:		bis.b #0x8f, P1DIR
		mov.w #0xffff, R5
		mov.w #0x0000, R6

init_int:	bic.b #0x10, P1DIR
		bis.b #0x10, P1REN
		bis.b #0x10, P1IES		;sellecting the falling edge
		bic.b #0x10, P1IFG
		bis.b #0x10, P1IE
		eint 				;enable interrut -> bis.w #GIE, SR

main:		bis.b #0x03, P1OUT
		call #delay 			; call a delay
		bic.b #0x03, P1OUT
		call #delay

		bis.b #0x06, P1OUT
		call #delay
		bic.b #0x06, P1OUT
		call #delay

		bis.b #0x0c, P1OUT
		call #delay
		bic.b #0x0c, P1OUT
		call #delay

		jmp main



delay:		dec.w R5			;bis.w #LPM1, SR
		jnz delay
		mov.w #0xffff, R5
		ret 				;return to the caller


P1_ISR:     	inc.w R6
		cmp.w #0x0001, R6 		;compare: R6 - 0x0001 = 0
		jz first
		cmp.w #0x0002, R6 		;compare: R6 - 0x0002 = 0
		jz second
		mov.w #0x0000, R6
		bic.b #0x10, P1IFG
		reti				;return from inturrupt

first:		xor.b #0x20, P1OUT
		ret

second:		xor.b #0x40, P1OUT
		ret


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                	; MSP430 RESET Vector
            .short  RESET
            .sect	".int02"		; pragma
            .short	P1_ISR
            
