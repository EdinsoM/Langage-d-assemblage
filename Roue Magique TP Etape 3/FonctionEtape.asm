;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
;  Fichier Vierge.asm
; Auteur : V.MAHOUT
; Date :  12/11/2013
;**************************************************************************

;***************IMPORT/EXPORT**********************************************

;**************************************************************************
	IMPORT	Run_Timer4
	IMPORT	Stop_Timer4
	IMPORT	Nbsecteurs
	IMPORT	mire
	IMPORT 	DataSend
		
	EXPORT	Timer_CC
	EXPORT	Timer_UP
	EXPORT	Timer_UP4

;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

Capture		DCD	0
Valcourante DCD 0
PisteMire	DCD 0
	
;**************************************************************************

;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************


;########################################################################
; Proc�dure: routines utilis�es par la TVI
;########################################################################
;
; Param�tre entrant  : LR, PC
; Param�tre sortant  : LR, PC
; Variables globales : Nbsecteurs, mire, DataSend
; Registres modifi�s : Aucun, tous les registres utilis�s sont sauvegard�s dans la Pile Syst�me 
;------------------------------------------------------------------------

Timer_CC	PROC
		
		PUSH	{R1-R3, LR}
		LDR		R0, =Capture
		LDR		R1, [R0]
		CMP		R1, #3
		LDR		R2, =PisteMire
		MOV		R3, #0
		STR		R3, [R2]			;On r�demarre la Piste � 0 parce que si on est ici, dans Timer_CC, est d� � que la roue a fait une tourne complete
		BEQ		BonneVitesse		;Si R1 = 3, �a va dire que la roue a tourn� 3 fois, c'est suffisant pour assurer la vitesse radiale constante et faire un bon calcul de TIM4_ARR

		ADD		R1, R1, #1
		STR		R1, [R0]			;Sinon, on augmente 1 � la valeur de Capture
		
		LDR		R0, =TIM1_CNT		
		MOV		R1, #0	
		STR		R1, [R0]			;On red�marre le compteur de TIM1 � 0
		
		LDR		R0, =TIM1_SR		
		LDR		R1, [R0]
		AND		R1, R1, #0xFFFFFFFD
		STR		R1, [R0]			;Acquittement de l'interruption
		
		POP		{R1-R3, LR}
		BX		LR					;Fin de l'interruption
		
BonneVitesse						;Partie de la procedure Timer_CC
		
		LDR		R0,	=TIM1_CNT		
		LDR		R1, [R0]			;Cette valeur corresponde � la valeur de Tr (la roue tourne � une vitesse constante)
		LDR		R2, =Nbsecteurs
		UDIV	R1, R1, R2			;Maintenant on calcule la valeur de Reload
		LDR		R0, =TIM4_ARR
		STR		R1, [R0]
		
		LDR		R0, =TIM1_SR		
		LDR		R1, [R0]
		AND		R1, R1, #0xFFFFFFFD 
		STR		R1, [R0]			;Acquittement de l'interruption en effa�ant le bit de rang 1 trouv� dans TIM1_SR
		
		LDR		R0, =TIM1_CNT		
		MOV		R1, #0	
		STR		R1, [R0]			;On red�marre le compteur de TIM1 � 0
		
		BL		Run_Timer4			;D�marrage du Timer4 pour commencer l'affichage des secteurs
		
		POP		{R1-R3, LR}
		BX		LR				
		
			ENDP
			
Timer_UP	PROC					;Ici, TIM1_CNT = 0xFFFF
		
		PUSH	{R1, LR}
		
		LDR 	R0, =Capture		
		MOV 	R1, #0
		STR		R1, [R0]			;On met � 0 la valeur de Capture
		
		BL		Stop_Timer4
				
		LDR		R0, =TIM1_SR		
		LDR		R1, [R0]
		AND		R1, R1, #0xFFFFFFFE
		STR		R1, [R0]			;Acquittement de l'interruption en effa�ant de bit de rang 0 trouv� dans TIM1_SR
		
		POP		{R1, LR}
		BX		LR					
		
			ENDP
			
Timer_UP4	PROC
		
		PUSH	{R0-R3, LR}
		
		NOP
		LDR		R0, =PisteMire		;On regarde dans quelle piste se trouve la roue
		LDR		R2, [R0]
		
		LDR 	R1, =mire
		MOV		R3, #0x30			;Pendant chaque tourne, l'information pour les 48 LED's est envoy�, ensuite, pour changer de secteur, on doit sauter un space de 48 octets (ou 0x30)
		MUL		R3, R2, R3			;En plus, on doit sauter les 48 octets multipli�s par la piste o� on se trouve
		ADD		R0, R1, R3			;Finalement, on ajoute cette valeur � l'adresse de mire
		BL 		DriverReg

		LDR		R0, =PisteMire
		LDR		R2, [R0]
		ADD		R2, R2, #1
		STR		R2, [R0]			;On avance � la piste suivante
		
		LDR		R0, =TIM4_SR		
		LDR		R1, [R0]
		AND		R1, R1, #0xFFFFFFFE
		STR		R1, [R0]			;Acquittement de l'interruption en effa�ant le bit de rang 0 trouv� dans TIM4_SR
		
		POP		{LR, R0-R3}
		BX		LR
		
			ENDP

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
		BL 		ResetSin

FinSiReg
		LSL		R3, #1 ; on positionne ValCourante au bit suivant
		BL 		SetSCLK

		ADD		R2, #1 
		B		AutrePourReg
		
FinAutrePourReg		
		ADD		R1, #1 
		B		PourReg

FinPourReg

; Les deux boucles sont termin�es 

		MOV		R5, #0 ;DataSend = 0 � chaque envoi de donn�e 
		LDR 	R1, =DataSend 
		STRB	R1, [R5]
		
		POP 	{R1-R5, LR}
		
		BX 		LR
		
		ENDP			
;########################################################################
; Proc�dure de gestion des LEDs 
;########################################################################

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
			
;**************************************************************************
	END