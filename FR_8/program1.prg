LPARAM LDrf, lTax



SET PROCEDURE TO FR_DRIVERS\FR_ATOL\FR_ACTION.prg additive
SET PROCEDURE TO FR_DRIVERS\FR_ATOL\FR_DRIVER_ATOL.prg additive
SET PROCEDURE TO FR_DRIVERS\FR_ATOL\FR_BASE_ATOL.prg additive

LOCAL lFrObj, lFrPrint, lPassword, lError, lException , lCursorReport ,lcQ, idDoc

lcType = "ATOL"
*"SHTRIX"

lPassword = 30

local lError, lException 
lError = .F.
   
               
TRY




	lcQPay = SYS(2015)
	lCursorReport = _CursorCreate(lcQPay)
	goDACommand.Command  = " EXEC [FR_document_type_pay_cursor]  @drf = " + STR(LDrf) + ", @tax = " + STR(lTax) 
	goDACommand.Cursor =  lCursorReport.Alias
	IF !goDACommand.Execute()
		error 'goDACommand.Execute()'
	EndIF
	lCursorReport.DestroyCursor = .F.



	lFrPrint = NEWOBJECT( "myFr_print")
	lFRDriver = lFrPrint.fr_Choose(lcType)

	lFrPrint = CREATEOBJECT("FR_action")
	lFrObj = lFrPrint.FR_INIT(lFRDriver)

	lcQ = SYS(2015)
	lCursorReport = _CursorCreate(lcQ)
	goDACommand.Command  = "EXEC  FR_document_get_cursor @drf = " + STR(LDrf)+ ", @tax = " + STR(lTax) 
	goDACommand.Cursor =  lCursorReport.Alias
	IF !goDACommand.Execute()
		error 'goDACommand.Execute()'
	EndIF
	lCursorReport.DestroyCursor = .F.
	IF lCursorReport.reccount() = 0
		ERROR 'нет данных для печати'
	EndIF

	***Продажа

  *!*	lType_tax  // Применяемая система налогооблажения в чеке:  
  *!*	  // 	ОСН - 1  
  *!*	  // 	УСН доход - 2  
  *!*	  // 	УСН доход-расход - 4  
  *!*	  // 	ЕНВД - 8  
  *!*	  // 	ЕСН - 16  
  *!*	  // 	ПСН - 32



	lType_doc = 1
	lType_tax  = 32
	lSumm = 0
	lFrPrint.FR_DOC(lFRDriver,lFrObj,lPassword,lType_doc,lcQ,lSumm,lType_tax, lcQPay )

CATCH TO lException
	lError = .T.
ENDTRY 
                  
                   
IF lError
	lFrPrint.FR_log(lFRDriver,lException.Message)
	error lException.Message                 
	return 
ENDIF
