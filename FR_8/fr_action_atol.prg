LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint, lcQ, lType_doc 


SET PROCEDURE TO FR_driver_atol.prg additive
SET PROCEDURE TO FR_BASE_ATOL.prg ADDITIVE


lPassword = 30

lSumm = 0


SET STEP ON 
	lFrPrint = NEWOBJECT( "myFr_print")
	lFrPrint.fr_Choose("ATOL")


lFrPrint = CREATEOBJECT("FR_action_ATOL")
lFrPrint.FR_mess()

lFrObj = lFrPrint.FR_INIT()

*MESSAGEBOX(lFrObj.CheckState,'lFrObj.CheckState')
*aa =  lFrPrint.FR_CANCEL_DOC(lFrObj)
*MESSAGEBOX(aa)

*return

*lFrPrint.FR_X(lFrObj,lPassword)

*lFrPrint.FR_Z(lFrObj,lPassword)
*SET STEP ON 
*lFrPrint.FR_CashOut(lFrObj,lPassword,lSumm)
*lFrPrint.FR_CashInc(lFrObj,lPassword,lSumm)

***????????
return

lcQ = SYS(2015)
CREATE CURSOR (lcQ) (name c(200),price Y, quantity Y, Department I)

INSERT INTO (lcQ)(name ,price , quantity , Department) ;
VALUES('tovar 1', NTOM(100),NTOM(3),0)
INSERT INTO (lcQ)(name ,price , quantity , Department) ;
VALUES('tovar 2', NTOM(150),NTOM(2),0)

SELECT (lcQ)


*SET STEP ON 

***???????
lType_doc = 1
lSumm = 0
lFrPrint.FR_DOC(lFrObj,lPassword,lType_doc,lcQ,lSumm)


*--------------------------------------*
*--------------------------------------*
DEFINE CLASS FR_PRINT as Custom 
lFrObj = null

FUNCTION fr_Choose()
* Virtual 
ENDFUNC
ENDDEFINE

DEFINE CLASS myFr_print as FR_PRINT 

FUNCTION fr_Choose( lcType)
	this.lFrObj = this.Get_fr_driver(lcType) 
	
ENDFUNC
*----------
FUNCTION Get_fr_driver()
	LPARAMETERS lcTypeFR
	
	LOCAL lFrObj 
	
	DO CASE
		CASE lcTypeFR = "ATOL"
			lFrObj  = NEWOBJECT( "FR_driver_ATOL")
		CASE lcTypeFR = "ATOL10"
			lFrObj  = NEWOBJECT( "FR_driver_ATOL10")		
		CASE lcTypeFR = "SHTRIX"
			lFrObj  = NEWOBJECT( "FR_driver_STRIX")	
		OTHERWISE
			ERROR '?? ????????? ??? ?? - ' + tcType 
	ENDCASE

	RETURN lFrObj 
ENDFUNC 

ENDDEFINE







DEFINE Class FR_ACTION_ATOL as myFr_print
*FR_DRIVER_ATOL 
*myFr_print

**
	FUNCTION fr_Choose( lcType)
		RETURN DODEFAULT()
	
	ENDFUNC
	
	
	FUNCTION FR_mess
		RETURN DODEFAULT()
	ENDFUN


	FUNCTION FR_INIT
		RETURN DODEFAULT()
	ENDFUNC

	****X- ?????
	FUNCTION FR_X
		LPARAMETERS lFrObj,lPassword
		RETURN DODEFAULT(lFrObj,lPassword)
	ENDFUN	

	****Z- ?????
	FUNCTION FR_Z
		LPARAMETERS lFrObj,lPassword
		RETURN DODEFAULT(lFrObj,lPassword)
	ENDFUN	
	
	**** ???????? ??????????
	FUNCTION FR_CashInc
		LPARAMETERS lFrObj,lPassword, lSumm  
		RETURN DODEFAULT(lFrObj,lPassword, lSumm)
	ENDFUNC
	
	**** ?????? ??????????
	FUNCTION FR_CashOut 
		LPARAMETERS lFrObj,lPassword, lSumm 	 
		RETURN DODEFAULT(lFrObj,lPassword, lSumm)
	ENDFUNC
	
	*****????????
	**
	FUNCTION FR_BEGIN_DOC
		LPARAMETERS lFrObj,lPassword
		RETURN DODEFAULT(lFrObj,lPassword)
	ENDFUNC
	
	FUNCTION FR_BODY_DOC
		LPARAMETERS lFrObj, lObjBody, lType_doc
		RETURN DODEFAULT(lFrObj,lObjBody,lType_doc)
	ENDFUNC
	
	FUNCTION FR_CLOSE_DOC
		LPARAMETERS lFrObj, lSumm, lType_doc
		RETURN DODEFAULT(lFrObj,lSumm, lType_doc)
	ENDFUNC
	
	FUNCTION FR_CANCEL_DOC
		LPARAMETERS lFrObj
		RETURN DODEFAULT(lFrObj)
	ENDFUNC
	
	
	FUNCTION FR_DOC
		LPARAMETERS lFrObj,lPassword,lType_doc,lcQ,lSumm
	
		LOCAL lBodyObj, lError, lException , lResult
		lError = .F.

		
		TRY
			lBodyObj = createobject('custom')
			
			lBodyObj.addproperty('Tovarname','')
			lBodyObj.addproperty('Price',NTOM(0))
			lBodyObj.addproperty('Quantity',NTOM(0))
			lBodyObj.addproperty('Department',0)				
		
			**********?????? ?????????
			THIS.FR_BEGIN_DOC(lFrObj,lPassword)
			
			
			SELECT (lcQ)
			GO TOP	
			DO WHILE !EOF(lcQ)
			
				lBodyObj.Tovarname		= EVALUATE(lcQ + '.name')
				lBodyObj.Price 			= EVALUATE(lcQ + '.price')
				lBodyObj.Quantity 		= EVALUATE(lcQ + '.quantity')
				lBodyObj.Department 	= EVALUATE(lcQ + '.Department')
				*************???? ?????????			
				THIS.FR_BODY_DOC(lFrObj,lBodyObj,lType_doc)
		
				SKIP IN (lcQ)
			ENDDO	
			
			************???????? ?????????	
			lResult = THIS.FR_CLOSE_DOC(lFrObj, lSumm, lType_doc)
			IF lResult <> 0
				ERROR '??????' + ALLTR(STR(lResult))
			EndIF	
					
		CATCH TO lException
			lError = .T.
		ENDTRY 
		                  
		                   
		IF lError
			THIS.FR_CANCEL_DOC(lFrObj)
			error lException.Message                 
			return 
		ENDIF

		
	ENDFUN

ENDDEFINE

