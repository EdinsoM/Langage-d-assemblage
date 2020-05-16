		

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
	IMPORT 	Run_Timer1
	IMPORT	Stop_Timer1
	IMPORT	Timer_CC
	IMPORT	Timer_UP
	IMPORT  Timer_UP4
		
	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite, align = 9
		
TVI 		space 1024 ;4*(N+1)? soit N = 256 (on va copier toute la table)
Tourne		DCD 0
Tr			DCD 0
	
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

		;Maintenant, on commence a instancier les routines pour les interruptions 25, 27 et 30 dans la TVI
		
		LDR R1, =TVI		
				
		LDR R0, =Timer_UP			;Pour l'interruption 25 (TIM1_CNT = 0xFFFF), on crée la routine Timer_UP
		STR R0, [R1, #(16+25)*4]

		LDR R0, =Timer_CC			;Pour l'interruption 27 (senseur du capteur activé), on crée la routine Timer_CC
		STR R0, [R1, #(16+27)*4]

		LDR	R0, =Timer_UP4
		STR R0, [R1, #(16+30)*4]	;Pour l'interruption 30 (TIM4_ARR = Tr/Nbsecteurs), on crée la routine Timer_UP

		BL	Run_Timer1
		
RoueMagique		B		RoueMagique	
		
		ENDP
	END

;*******************************************************************************
