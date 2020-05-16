		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Système
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]




; IMPORT/EXPORT de procédure           

	IMPORT 	Init_Cible
	IMPORT Run_Timer1
	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite, align = 9
		
TVI space 1024 ;4*(N+1)? soit N = 256 (on va copier toute la table)
		
;*******************************************************************************
	
	AREA  moncode, code, readonly
		
;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************
		MOV R0,#2
		BL Init_Cible;
		
		LDR R0, =TVI
		LDR R1, =SCB_VTOR
		STR R0, [R1]
		
		LDR R1, =0x00000000
		MOV R2, #0
		
CopierTVI
		LDR R3, [R1]
		STR R3, [R0], #4
		ADD R1, R1, #4
		ADD R2, R2, #1
		CMP R2, #256
		BNE CopierTVI
			
Capteur
		LDR 	R1, =GPIOBASEA+OffsetInput
		LDRB	R2, [R1,#1]		
		CMP		R2, #1
		BNE		Capteur		
		
Timer1
		MOV		R0, #0
		LDR		R1, =TIM1_CNT
		STRH	R0,	[R1]
		BL		Run_Timer1

		ENDP
	END

;*******************************************************************************
