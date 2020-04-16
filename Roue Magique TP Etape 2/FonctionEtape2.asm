;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
; Fichier Vierge.asm
; Auteur : V.MAHOUT
; Date :  12/11/2013
;**************************************************************************

;***************IMPORT/EXPORT**********************************************


	IMPORT	Barrette1
	IMPORT 	Init_Cible
	EXPORT	DriverGlobal
;**************************************************************************


;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************



;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************

		MOV R0,#1
		BL Init_Cible;

DriverGlobal	PROC
	
		PUSH 	{R1,R8}
		BL 		SetSCLK
		MOV		R1, #0 	;NbLED
Pour
		CMP		R1, #47
		BNE		FairePour
		B		Semaphore
		
FairePour
		LDR		R2,=Barrette1
		LDRB	R3,[R2,R1]
		LSL		R3, R3, #24
			
		MOV		R4, #0 ;NbBit
AutrePour		
		CMP		R4, #11
		BNE		FaireAutrePour

FaireAutrePour
		
		BL		ResetSCLK
		
		AND		R6, R3, #0x80000000
		CMP		R6, #0x80000000
		BEQ		SetSin	;commence le si (if)
		B		ResetSin

SetSin	
		LDR		R7, =0X40010810
		MOV		R8, #(0x01<<7)
		STRB	R8,	[R7]
		B		AvantFinir
		
ResetSin		
		LDR		R7, =0x40010814
		MOV		R8, #(0x01<<7)
		STRB	R8, [R7]
		;le si est fini

		LSL		R3, R3, #1

		BL 		SetSCLK
		
AvantFinir	;Sont finis les deux boucles? On verra
		
		ADD		R4, R4, #1 ;NbBit+1
		CMP		R4, #11
		BNE		AutrePour
		
		ADD		R1, R1, #1 ;NbLed+1
		CMP		R1,	#47
		BNE		Pour
		
		POP		{R1,R8}

;Les deux boucles sont finis

Semaphore
		MOV		R1, #0 ;DataSend = 0
		BX		LR
		ENDP

SetSCLK		PROC
		LDR		R2, = GPIOBASEA + OffsetSet
		MOV		R1, #(0x01<<5)
		STRB 	R1, [R2]
		BX		LR
		
		ENDP
			
ResetSCLK	PROC
		LDR		R5, = GPIOBASEA + OffsetReset ; Reset(SCLK) 
		MOV		R6, #(0x01<<5)
		STRB	R6, [R5]
		BX		LR
		
		ENDP
		

;########################################################################
; Procédure ????
;########################################################################
;
; Paramètre entrant  : ???
; Paramètre sortant  : ???
; Variables globales : ???
; Registres modifiés : ???
;------------------------------------------------------------------------






;**************************************************************************
	END