;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************
; 					IMPORT/EXPORT Syst�me
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]

	EXPORT Barrette1
	EXPORT Barrette2
		

;*******************************************************************************
	AREA  mesdonnees, data, readwrite
		
			;	Rouge	 Vert	 Bleu

Barrette1	DCB		255,	0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0xAA,	0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		0
			DCB		0,		0,		255
			
Barrette2	DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			DCB		255,	0,		0
			
	END

;*******************************************************************************