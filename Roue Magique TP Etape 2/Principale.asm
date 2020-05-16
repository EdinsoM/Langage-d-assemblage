		

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
	IMPORT 	DriverGlobal
	IMPORT	DriverReg
	IMPORT	DriverPile
	IMPORT	Tempo
	IMPORT 	Barrette1
	IMPORT	Barrette2
	IMPORT 	SetSCLK
	IMPORT 	ResetSCLK
	IMPORT 	SetSin
	IMPORT 	ResetSin	
		

	
	EXPORT 	main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

M EQU 2
		
;*******************************************************************************
	
	AREA  moncode, code, readonly


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		MOV R0,#1
		BL Init_Cible
		MOV R1, #0
		

Boucle 									; on relève la valeur actuelle du capteur 

		LDR R4 ,=GPIOBASEA+OffsetInput	; R4 --> entrée du capteur
		LDRH R5,[R4]					; R5 --> valeur actuelle du capteur
		
		ANDS R5,#(0x01<<8)				;on compare R5 avec 0x100
		BEQ Capteur0					;si ce n'est pas égal, on laisse le R4 à 0
		MOV R4,#1						;sinon on met R4 à 1
		B FinCapteur
			
Capteur0	MOV R4,#0					;si on est ici alors on avait un 0 au 8eme bit (capteur à 0) donc on affecte un 0 à R4	

FinCapteur 
 
; conditions de la boucle while --> tant que le capteur = 0 et que on a fait moins de M fois la boucle 

		CMP R4, #1 
		BEQ FinBoucle	; si le capteur est à 1, on sort
		
		CMP R1, #M		
		BEQ FinBoucle	; si on est passé M fois dans la boucle, on sort
	
; gestion de Barrette 1 et temporisation

		LDR R0, =Barrette1
		PUSH {R0}		; on met la valeur de Barrette1 sur la pile
		BL DriverPile
		ADD SP, #4		; nettoyage de la pile
		
		MOV R0, #1
		BL Tempo
		
; gestion de Barrette 2 et temporisation 
		
		LDR R0, =Barrette2
		PUSH {R0}
		BL DriverPile
		ADD SP, #4
		
		MOV R0, #1
		BL Tempo

;incrémentation du compteur 
		ADD R1, #1
		
		B Boucle

FinBoucle

		
		ENDP

	END

;*******************************************************************************
