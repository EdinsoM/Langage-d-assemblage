		

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
	
	IMPORT	Allume_LED
	IMPORT	Eteint_LED

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite
		
;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		MOV R0,#0
		MOV	R5,#0
		BL Init_Cible;
		
TantQue		
		
		LDR		R2, =0X40010808
		LDRB	R1, [R2,#1]
		CMP		R1, #1
		
		BEQ	Allume	
		BL	Eteint_LED;

Allume
		BL	Allume_LED;
		
		ADD	R5,#1
		CMP	R5,#10
		BEQ	Boucle
		
		B	TantQue


		; pour allumer la LED avec le registre output		
		LDR		R2, =0x40010C0C
		LDRH	R1, [R2]
		ORR		R1, R1, #(0x01 << 10)
		STRH 	R1, [R2]

		; pour éteindre la LED avec le registre output
		LDR		R2, =0x40010C0C
		LDRH	R1, [R2]
		AND		R1, #~(0x01 << 10)
		STRH	R1,	[R2]
		
Boucle		
		B Boucle ;boucle inifinie terminale...

		ENDP

	END

;*******************************************************************************
