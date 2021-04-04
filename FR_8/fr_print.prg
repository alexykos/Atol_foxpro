
SET PROCEDURE TO FR_ACTION_ATOL.prg additive
SET PROCEDURE TO FR_driver_atol.prg additive
SET PROCEDURE TO FR_BASE_ATOL.prg ADDITIVE

*--------------------------------------*
*--------------------------------------*
DEFINE CLASS FR_PRINT as Custom 
lFrObj = null

FUNCTION fr_int()
* Virtual 
ENDFUNC
ENDDEFINE

DEFINE CLASS myFr_print as FR_PRINT 

FUNCTION fr_int( tcType)
	this.lFrObj = this.fr_choose(tcType) 

ENDFUNC
*----------
FUNCTION fr_choose()
	LPARAMETERS tcType
	
	LOCAL lFrObj 
	
	DO CASE
		CASE tcType = "ATOL"
			lFrObj  = NEWOBJECT( "FR_ACTION_ATOL")
		CASE tcType = "SHTRIX"
			lFrObj  = NEWOBJECT( "FR_ACTION_STRIX")	
		OTHERWISE
			ERROR 'Не определен тип ФР - ' + tcType 
	ENDDO

	RETURN tcType 
ENDFUNC 

ENDDEFINE
