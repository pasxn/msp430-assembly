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

; CS   -> 0x01
; CLK  -> 0x02
; DATA -> 0x04

init:		bis.w #110011001b, R5		; data
			bis.w #100000000b, R6		; bit no.
			bis.w #0x0a, R7				; i

			bis.b #0x07, P1DIR


main:		bic.b #0x01, P1OUT
            bic.b #0x02, P1OUT


begin:		bit.w R5, R6				; AND operation of the particular bit
			jz bitiszero
			bit.w R5, R6
			jnz bitisone
			rlc R5
			jmp begin


bitiszero:	dec.b R7
			call #condition
			bic.b #0x04, P1OUT			; DATA -> LOW
			bis.b #0x02, P1OUT			; CLK -> HIGH
			bic.b #0x02, P1OUT			; CLK -> LOW
			ret

bitisone:	dec.b R7
			call #condition
			bis.b #0x04, P1OUT			; DATA -> HIGH
			bis.b #0x02, P1OUT			; CLK -> HIGH
			bic.b #0x02, P1OUT			; CLK -> LOW
			ret

condition:	cmp.w #0x00, R7
			jz end
			ret

end:		bis.b #0x01, P1OUT			; CS -> HIGH
			bic.b #0x01, P1OUT			; CS -> LOW
			jmp main
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
