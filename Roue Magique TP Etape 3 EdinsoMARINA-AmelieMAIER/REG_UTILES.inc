
;**************************************
;     Les adresess utiles 	
;***************************************


;**************************************
;     Affectation des bits GPIO 	
;***************************************
; GSLCK..... PA0 
; DSPRG..... PA1 
; BLANK..... PA2 
; XLAT...... PA3
; VPRG...... PA4
; SCLK...... PA5
; SIN1...... PA7
;Capteur.....PA8

;LED.........PB10
;****************************************/



GPIOBASEA		EQU 0X40010800
GPIOBASEB		EQU 0X40010C00

OffsetInput		EQU 0x08
OffsetOutput	EQU 0x0C
OffsetSet		EQU 0x10
OffsetReset		EQU 0x14


MaskSerial_In1  equ 0x80
MaskSerial_Dots equ 0x80
MaskVprg		equ 0x10
MaskXlat		equ 0x08
MaskBlank	    equ 0x04
MaskSclk	    equ 0x20
MaskDsprg	    equ 0x02
MaskGsclk       equ 0x01


SCB_VTOR		EQU 0xE000ED08
TIM1_SR			EQU 0x40012c10
TIM1_CNT 		EQU 0x40012c24
TIM4_ARR 		EQU 0x4000082C 
TIM4_SR 		EQU 0x40000810

	
	
	
	
	END