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
	IMPORT 	Barrette2
	IMPORT 	DataSend
		
	EXPORT	DriverGlobal
	EXPORT 	DriverReg
	EXPORT 	DriverPile
	EXPORT 	Tempo
	EXPORT 	SetSCLK
	EXPORT 	ResetSCLK
	EXPORT 	SetSin
	EXPORT 	ResetSin
		
		
;**************************************************************************


;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

Valcourante DCD 0


;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************


;########################################################################
; Procédure DriverGlobal
;########################################################################
; Paramètre entrant  : //
; Paramètre sortant  : //
; Variables globales : DataSend, Barrette1, Valcourante
; Registres modifiés : de R1 à R5 et LR (car appel imbriqué)
;------------------------------------------------------------------------

; R0 --> Barrette1
; R1 --> NbLed
; R2 --> NbBit
; R3 --> ValCourante
; R5 --> DataSend

DriverGlobal	PROC
	
		PUSH 	{R0-R5, LR}
		
		LDR 	R0, =Barrette1
		LDR 	R3, =Valcourante 
		BL 		SetSCLK
		
		MOV 	R1, #0 				; NbLed = 0
		
Pour
		CMP		R1, #48 			; on passe 47 fois et on sort à la 48ème
		BEQ		FinPour
		

		LDRB	R3,[R0,R1]
		LSL		R3, #24
			
		MOV		R2, #0 				; NbBit = 0
		
AutrePour	

		CMP		R2, #12 			; de même, on passe 11 fois et on sort à la 12eme
		BEQ		FinAutrePour

		BL		ResetSCLK
		
		ANDS	R4, R3, #0x80000000	; on compare le bit de PF de R3 (Valcourante) avec 0
		
		BEQ		Sinon				; si il est 0, on fait Sinon
		BL		SetSin 				; sinon on allume SetSin
		B		FinSi
		
Sinon 
		BL ResetSin

FinSi
		LSL		R3, #1 				; on positionne ValCourante au bit suivant
		BL 		SetSCLK

		ADD		R2, #1 				; NbBit+1
		B		AutrePour
		
FinAutrePour		
		ADD		R1, #1 ;NbLed+1
		B		Pour

FinPour 

; Les deux boucles sont terminées 

		MOV		R5, #0 			;DataSend = 0 à chaque envoi de donnée 
		LDR 	R1, =DataSend 
		STRB	R1, [R5]
		
		POP {R0-R5, LR}
		
		BX LR
		
		ENDP
			
		

;########################################################################
; Procédure DriverReg
;########################################################################
; Paramètre entrant  : Barrette1 dans R0
; Paramètre sortant  : Barrette1 dans R0
; Variables globales : DataSend
; Registres modifiés : de R1 à R4 et LR
;------------------------------------------------------------------------

; R0 --> Barrette1
; R1 --> NbLED
; R2 --> NbBit
; R3 --> ValCourante

; R5 --> DataSend 

; Procédure identique à DriverGlobal mais en passant Barrette1 par référence dans un registre
DriverReg	PROC
	
		PUSH 	{R1-R5, LR}
		
		MOV		R1, #0 	;NbLED
		LDR 	R3, =Valcourante
		BL 		SetSCLK
		
PourReg
		CMP		R1, #48
		BEQ		FinPourReg
		
		
FairePourReg
		LDRB	R3,[R0,R1]
		LSL		R3, #24
			
		MOV		R2, #0 
		
AutrePourReg		
		CMP		R2, #12
		BEQ		FinAutrePourReg

		BL		ResetSCLK
		
		ANDS	R4, R3, #0x80000000 
		BEQ		SinonReg	
		BL		SetSin 		
		B		FinSiReg
		
SinonReg
		BL ResetSin

FinSiReg
		LSL		R3, #1 ; on positionne ValCourante au bit suivant
		BL 	SetSCLK

		ADD		R2, #1 
		B		AutrePourReg
		
FinAutrePourReg		
		ADD		R1, #1 
		B		PourReg

FinPourReg

; Les deux boucles sont terminées 

		MOV		R5, #0 ;DataSend = 0 à chaque envoi de donnée 
		LDR 	R1, =DataSend 
		STRB	R1, [R5]
		
		POP {R1-R5, LR}
		
		BX LR
		
		ENDP
			

;########################################################################
; Procédure DriverPile
;########################################################################
; Paramètre entrant  : Barrette1 sur la pile système
; Paramètre sortant  : Barrette1 sur la pile système
; Variables globales : DataSend
; Registres modifiés : R1 - R4 et LR
;------------------------------------------------------------------------


; R0 --> Barrette1
; R1 --> NbLed
; R2 --> NbBit
; R3 --> ValCourante
; R5 --> DataSend

; Procédure identique à DriverGlobal mais en passant Barrette1 
DriverPile	PROC
	
		PUSH {R10}
		MOV R10, SP
	
		PUSH 	{LR,R1-R4}
		
		
		MOV		R1, #0 	
		LDR 	R3, =Valcourante
		BL 		SetSCLK
		LDR 	R0, [R10, #4] ;on rajoute 4o pour récupérer l'adresse de la barrette pushée
		
PourPile
		CMP		R1, #48
		BEQ		FinPourPile		
		
		LDRB	R3,[R0,R1]
		LSL		R3, #24
			
		MOV		R2, #0 
		
AutrePourPile	
		CMP		R2, #12
		BEQ		FinAutrePourPile

		BL		ResetSCLK
		
		ANDS	R4, R3, #0x80000000 
		BNE		SinonPile	
		BL		SetSin 		
		B		FinSiPile
		
SinonPile
		BL 		ResetSin

FinSiPile
		LSL		R3, #1 ; on positionne ValCourante au bit suivant
		BL 		SetSCLK

		ADD		R2, #1 
		B		AutrePourPile
		
FinAutrePourPile
		ADD		R1, #1 ;NbLed+1
		B		PourPile

FinPourPile

; Les deux boucles sont terminées 

		MOV		R1, #0 ;DataSend = 0 à chaque envoi de donnée 
		LDR 	R2, =DataSend 
		STRB	R1, [R2]
		
		POP {LR, R1-R4}
		POP{R10}
		
		BX LR
		
		ENDP
			
		

;########################################################################
; Procédure de gestion des LEDs 
;########################################################################
; Paramètre entrant  : 
; Paramètre sortant  : 
; Variables globales : 
; Registres modifiés : 
;------------------------------------------------------------------------



SetSin	PROC
		PUSH 	{R2,R3}
		LDR		R2, =GPIOBASEA+OffsetSet
		MOV		R3, #(0x01<<7)
		STRH	R3,	[R2]
		POP 	{R2,R3}
		BX 		LR
		ENDP
			
ResetSin	PROC	
		PUSH 	{R2,R3}
		LDR		R2, =GPIOBASEA+OffsetReset
		MOV		R3, #(0x01<<7)
		STRH	R3, [R2]
		POP 	{R2,R3}
		BX 		LR
		ENDP
			
SetSCLK	PROC
		PUSH 	{R2,R3}
		LDR		R2, =GPIOBASEA+OffsetSet
		MOV		R3, #(0x01<<5)
		STRH 	R3, [R2]
		POP 	{R2,R3}
		BX		LR
		
		ENDP
			
ResetSCLK	PROC
		PUSH 	{R2, R3}
		LDR		R2, =GPIOBASEA+OffsetReset 
		MOV		R3, #(0x01<<5)
		STRH	R3, [R2]
		POP 	{R2, R3}
		BX		LR
		
		ENDP
		

;########################################################################
; Procédure Tempo
;########################################################################
; Paramètre entrant  : R0
; Paramètre sortant  : R0
; Variables globales : // 
; Registres modifiés : de R1 à R8 et LR
;------------------------------------------------------------------------

Tempo PROC
	
		PUSH {R1-R3}
		MOV R1, #0
		MOV R3, #10 ; 
		MUL R3,R3,R0 ; R0 contient N = Nombre d'itérations
		
	
For1    CMP R1, R3
		BEQ Fin1
		MOV R2, #500 ; qui correspond à 0,1 ms (chaque itération de la boucle For1	dure environ 83 ns) 

For2	CMP R2, #0
		BEQ Fin2
		NOP
		SUB R2, #1
		B For2
		
Fin2	ADD R1, #1
		B For1

Fin1
		POP {R1, R3}
		BX LR
		ENDP
			


		

;**************************************************************************
	END