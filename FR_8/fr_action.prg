LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint, lcQ, lType_doc ,lType_tax


SET PROCEDURE TO FR_driver_atol.prg additive
SET PROCEDURE TO FR_driver_shtrix.prg additive
SET PROCEDURE TO FR_BASE_atol.prg additive


lcType = "ATOL"
*"SHTRIX"

lPassword = 30

lSumm = 100



*SET STEP ON 

	lFrPrint = NEWOBJECT( "myFr_print")
	lFRDriver = lFrPrint.fr_Choose(lcType)


lFrPrint = CREATEOBJECT("FR_action")
*lFrPrint.FR_mess(lFRDriver)

lFrObj = lFrPrint.FR_INIT(lFRDriver)


*MESSAGEBOX(lFrObj.CheckState,'lFrObj.CheckState')
*aa =  lFrPrint.FR_CANCEL_DOC(lFRDriver,lFrObj)
*MESSAGEBOX(aa)

*return

*lFrPrint.FR_X(lFRDriver,lFrObj,lPassword)


lFrPrint.FR_Z(lFRDriver,lFrObj,lPassword)
*SET STEP ON 
*lFrPrint.FR_CashOut(lFRDriver,lFrObj,lPassword,lSumm)
*lFrPrint.FR_CashInc(lFRDriver,lFrObj,lPassword,lSumm)

***????????

return

lcQPay = SYS(2015)
CREATE CURSOR (lcQPay) (type i,summ Y)

INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(1, NTOM(40))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(2, NTOM(300))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(3, NTOM(200))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(4, NTOM(60))



lcQ = SYS(2015)
CREATE CURSOR (lcQ) (name c(200),price Y, quantity Y, Department I)

INSERT INTO (lcQ)(name ,price , quantity , Department) ;
VALUES('tovar 1', NTOM(100),NTOM(3),0)
INSERT INTO (lcQ)(name ,price , quantity , Department) ;
VALUES('tovar 2', NTOM(150),NTOM(2),0)

SELECT (lcQ)


*SET STEP ON 

  *!*	lType_tax  // ??????????? ??????? ??????????????? ? ????:  
  *!*	  // 	??? - 1  
  *!*	  // 	??? ????? - 2  
  *!*	  // 	??? ?????-?????? - 4  
  *!*	  // 	???? - 8  
  *!*	  // 	??? - 16  
  *!*	  // 	??? - 32

***???????
lType_doc = 2

lSumm = 0
lType_tax = 32
lFrPrint.FR_DOC(lFRDriver,lFrObj,lPassword,lType_doc,lcQ,lSumm,lType_tax, lcQPay )


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
		RETURN this.lFrObj
	ENDFUNC

	*----------
	FUNCTION Get_fr_driver()
		LPARAMETERS lcTypeFR
		
		DO CASE
			CASE lcTypeFR = "ATOL"
				lFrObj  = CREATEOBJECT("FR_driver_ATOL")
			CASE lcTypeFR = "ATOL"
				lFrObj  = CREATEOBJECT("FR_driver_ATOL")	
			CASE lcTypeFR = "SHTRIX"
				lFrObj  = CREATEOBJECT( "FR_driver_SHTRIX")	
		ENDCASE

		RETURN lFrObj  
	ENDFUNC 

ENDDEFINE




DEFINE Class FR_ACTION as custom
*FR_DRIVER_ATOL 
*myFr_print


	
	
	FUNCTION FR_mess
		LPARAMETERS lDriver
		RETURN lDriver.FR_mess()
	ENDFUN

	
	FUNCTION FR_INIT
		LPARAMETERS lDriver

		RETURN lDriver.FR_INIT()
	ENDFUNC

	****X- ?????
	FUNCTION FR_X
		LPARAMETERS lFRDriver,lFrObj,lPassword
		RETURN lFRDriver.FR_X(lFrObj,lPassword)
	ENDFUN	

	****Z- ?????
	FUNCTION FR_Z
		LPARAMETERS lDriver,lFrObj,lPassword
		RETURN lDriver.FR_Z(lFrObj,lPassword)
	ENDFUN	
	
	**** ???????? ??????????
	FUNCTION FR_CashInc
		LPARAMETERS lDriver,lFrObj,lPassword, lSumm  
		RETURN lDriver.FR_CashInc(lFrObj,lPassword, lSumm)
	ENDFUNC
	
	**** ?????? ??????????
	FUNCTION FR_CashOut 
		LPARAMETERS lDriver,lFrObj,lPassword, lSumm 	 
		RETURN lDriver.FR_CashOut(lFrObj,lPassword, lSumm)
	ENDFUNC

	**** ???????????
	FUNCTION FR_log
		LPARAMETERS lDriver,lError 	 
		RETURN lDriver.FR_log(lError)
	ENDFUNC
	
	*****????????
	**
	
	FUNCTION FR_BEGIN_DOC
		LPARAMETERS lDriver,lFrObj,lPassword
		RETURN lDriver.FR_BEGIN_DOC(lFrObj,lPassword)
	ENDFUNC
	
	FUNCTION FR_BODY_DOC
		LPARAMETERS lDriver,lFrObj, lObjBody, lType_doc
		RETURN lDriver.FR_BODY_DOC(lFrObj,lObjBody,lType_doc)
	ENDFUNC
	
	FUNCTION FR_CLOSE_DOC
		LPARAMETERS lDriver,lFrObj, lSumm, lType_doc, lType_tax, lcQPay 
		RETURN lDriver.FR_CLOSE_DOC(lFrObj,lSumm, lType_doc, lType_tax, lcQPay )
	ENDFUNC
	
	FUNCTION FR_CANCEL_DOC
		LPARAMETERS lDriver,lFrObj
		RETURN lDriver.FR_CANCEL_DOC(lFrObj)
	ENDFUNC
	
	FUNCTION FR_BEFORE_DOC
		LPARAMETERS lFrObj
	ENDFUNC
	
	FUNCTION FR_AFTER_DOC
		LPARAMETERS lFrObj
	ENDFUNC
	
	
	FUNCTION FR_DOC
		LPARAMETERS lFRDriver,lFrObj,lPassword,lType_doc,lcQ,lSumm,lType_tax, lcQPay 
	
		LOCAL lBodyObj, lError, lException , lResult
		lError = .F.

		
		TRY
			lBodyObj = createobject('custom')
			
			lBodyObj.addproperty('Tovarname','')
			lBodyObj.addproperty('Price',NTOM(0))
			lBodyObj.addproperty('Quantity',NTOM(0))
			lBodyObj.addproperty('Department',0)				
		
			********** ????? ??????? ?????????
			THIS.FR_BEFORE_DOC(lFrObj)
		
			**********?????? ?????????
			THIS.FR_BEGIN_DOC(lFRDriver,lFrObj,lPassword)
			
			
			SELECT (lcQ)
			GO TOP	
			DO WHILE !EOF(lcQ)
			
				lBodyObj.Tovarname		= EVALUATE(lcQ + '.name')
				lBodyObj.Price 			= EVALUATE(lcQ + '.price')
				lBodyObj.Quantity 		= EVALUATE(lcQ + '.quantity')
				lBodyObj.Department 	= EVALUATE(lcQ + '.Department')
				*************???? ?????????			
				THIS.FR_BODY_DOC(lFRDriver,lFrObj,lBodyObj,lType_doc)
		
				SKIP IN (lcQ)
			ENDDO	
*ERROR '1'


			************???????? ?????????	
			lResult = THIS.FR_CLOSE_DOC(lFRDriver,lFrObj, lSumm, lType_doc, lType_tax, lcQPay )
			IF lResult <> 0
				ERROR '??????' + ALLTR(STR(lResult))
			EndIF	
			
			********** ????? ???????? ?????????
			THIS.FR_AFTER_DOC(lFrObj)
		
					
		CATCH TO lException
			lError = .T.
		ENDTRY 
		                  
		                   
		IF lError
			THIS.FR_CANCEL_DOC(lFRDriver,lFrObj)
			THIS.FR_log(lFRDriver,lException.Message)
			error lException.Message                 
			return 
		ENDIF

		
	ENDFUN

ENDDEFINE

