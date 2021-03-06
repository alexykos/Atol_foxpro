LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint, lcQ, lType_doc 





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



LOCAL lFptr,LCashierFio, lCashierINN, loParam

LCashierFio = '??????????? ?.?.'
lCashierINN = '123456789047'
lCashIncSumm = NTOM(150)
lCashOutSumm = NTOM(110)

loParam = createobject('custom')
loParam.addproperty('CashierFio', LCashierFio)
loParam.addproperty('CashierINN', lCashierINN)
loParam.addproperty('lCashIncSumm', lCashIncSumm )
loParam.addproperty('lCashOutSumm', lCashOutSumm)

loParam.addproperty('CashQPay', lcQPay)
loParam.addproperty('CashCheckBody', lcQ)


lFrPrint = createobject("FR_DRIVER_ATOL10")
*SET STEP ON 
*lFrPrint.FR_X(loParam)
*lFrPrint.FR_Z(loParam)
*lFrPrint.FR_CashInc(loParam)
*lFrPrint.FR_CashOut(loParam)
*lFrPrint.FR_DOC(loParam)




DEFINE Class FR_DRIVER_ATOL10 as custom
	
	FUNCTION FR_INIT
			LOCAL lFR 
			lFR = CreateObject("AddIn.Fptr10")
			RETURN lFR 
	ENDFUNC
	
	
**************************************************
****?????? ?????????
**************************************************	
FUNCTION FR_DOC
	LPARAMETERS loParam 
		
		LOCAL lFrObj
		lFrObj = THIS.FR_INIT()
		
		THIS.FR_log('FR_X')
		  
		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    EndIF

		isOpened = lFrObj.isOpened()

	****??????????? ???????
	   THIS.FR_REG_CASHIER(lFrObj,loParam)

	***#???????? ????????? ????
	***#??? ????:??????
	
*    LIBFPTR_TT_DEFAULT - ?? ?????????
*   LIBFPTR_TT_OSN - ????? ???
*    LIBFPTR_TT_USN_INCOME - ?????????? ?????
*    LIBFPTR_TT_USN_INCOME_OUTCOME - ?????????? ????? ????? ??????
*    LIBFPTR_TT_ENVD - ????
*    LIBFPTR_TT_ESN - ?????? ???????????????????? ?????
*    LIBFPTR_TT_PATENT - ????????? ???

	lFrObj.setParam(1055, lFrObj.LIBFPTR_TT_ENVD )
	lFrObj.setParam(lFrObj.LIBFPTR_PARAM_RECEIPT_TYPE, lFrObj.LIBFPTR_RT_SELL)
	lFrObj.openReceipt()
	***#??????????? ??????? ??? ???????? ????? ??????
	lcQ = loParam.CashCheckBody
	SELECT (lcQ)
			GO TOP	
			DO WHILE !EOF(lcQ)
			
				lTovarname		= ALLTRIM(EVALUATE(lcQ + '.name'))
				lPrice 			= EVALUATE(lcQ + '.price')
				lQuantity 		= EVALUATE(lcQ + '.quantity')
				lDepartment 	= EVALUATE(lcQ + '.Department')
				
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_COMMODITY_NAME, lTovarname)
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_PRICE, lPrice )
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_QUANTITY, lQuantity )
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_DEPARTMENT , 2 )
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_TAX_TYPE, lFrObj.LIBFPTR_TAX_VAT110)
				lFrObj.registration()
				
				
		
				SKIP IN (lcQ)
			ENDDO	
	
	****#?????? ????
	*LIBFPTR_PT_CASH - ?????????
	*LIBFPTR_PT_ELECTRONICALLY - ????????????
	*LIBFPTR_PT_PREPAID - ??????????????? ?????? (?????)
	
	lFrObj.setParam(lFrObj.LIBFPTR_PARAM_PAYMENT_TYPE, lFrObj.LIBFPTR_PT_ELECTRONICALLY)
	lFrObj.payment()
	***#??????????? ?????? ?? ???
	lFrObj.setParam(lFrObj.LIBFPTR_PARAM_TAX_TYPE, lFrObj.LIBFPTR_TAX_VAT110)
	lFrObj.receiptTax()
	****#??????????? ????? ????
	lFrObj.receiptTotal()
	***#???????? ????????? ??????????? ????
	lFrObj.closeReceipt()
	***#?????????? ?????????? ? ???
	IF lFrObj.close() = -1
		THIS.ERROR_MESS(lFrObj)
    EndIF

ENDFUN

	


**************************************************
	****X- ?????
	**************************************************

	FUNCTION FR_X
		LPARAMETERS loParam 
		
		LOCAL lFrObj
		lFrObj = THIS.FR_INIT()
		
		THIS.FR_log('FR_X')
		  
		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    EndIF

		lFrObj.setParam(lFrObj.LIBFPTR_PARAM_REPORT_TYPE, lFrObj.LIBFPTR_RT_X)
		IF lFrObj.report = -1
			THIS.ERROR_MESS(lFrObj)
	    ENDIF
		
	ENDFUNC
	
	**************************************************
	****???????? 
	**************************************************
	FUNCTION FR_CashInc
		LPARAMETERS loParam 
		
		THIS.FR_log('FR_CashInc')

		LOCAL lFrObj, LSumm 
		lFrObj = THIS.FR_INIT()

		LSumm = loParam.lCashIncSumm
		
		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    ENDIF
	    
	    ****??????????? ???????
	   THIS.FR_REG_CASHIER(lFrObj,loParam)

	    
	    lFrObj.setParam(lFrObj.LIBFPTR_PARAM_SUM, LSumm ) 
		IF lFrObj.cashIncome = -1
	    	THIS.ERROR_MESS(lFrObj)
	    EndIF	
	    
	    IF lFrObj.Close= -1
			THIS.ERROR_MESS(lFrObj)
	    ENDIF
	    	
	ENDFUNC
	
	**************************************************
	****??????
	**************************************************
	FUNCTION FR_CashOut 
		LPARAMETERS loParam 
		
		THIS.FR_log('FR_CashOut')

		LOCAL lFrObj, LSumm 
		lFrObj = THIS.FR_INIT()

		LSumm = loParam.lCashOutSumm
		
		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    ENDIF
	    
	    ****??????????? ???????
	   THIS.FR_REG_CASHIER(lFrObj,loParam)

	    
	    lFrObj.setParam(lFrObj.LIBFPTR_PARAM_SUM, LSumm ) 
		IF lFrObj.cashOutcome = -1
	    	THIS.ERROR_MESS(lFrObj)
	    EndIF	
	    
	    IF lFrObj.Close= -1
			THIS.ERROR_MESS(lFrObj)
	    ENDIF
	    	
	EndFun

	**************************************************
	****??????????? ???????
	**************************************************
	FUNCTION FR_REG_CASHIER
		LPARAMETERS lFrObj, loParam 
		
		LOCAL LCashierFio, lCashierINN


		LCashierFio = ALLTRIM(loParam.CashierFio)
		lCashierINN = ALLTRIM(loParam.CashierINN)
	    lFrObj.setParam(1021, LCashierFio )
	    lFrObj.setParam(1203, lCashierINN )
	    IF lFrObj.operatorLogin = -1
	    	THIS.ERROR_MESS(lFrObj)
	    EndIF	
	    	
	EndFun

	**************************************************
	****Z- ?????
	**************************************************
	FUNCTION FR_Z
		LPARAMETERS loParam 
		
		THIS.FR_log('FR_Z')
		
		LOCAL lFrObj
		lFrObj = THIS.FR_INIT()
		

		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    EndIF

		****??????????? ???????
	   THIS.FR_REG_CASHIER(lFrObj,loParam)

	    lFrObj.setParam(lFrObj.LIBFPTR_PARAM_REPORT_TYPE, lFrObj.LIBFPTR_RT_CLOSE_SHIFT)
	    IF lFrObj.report = -1
	    	THIS.ERROR_MESS(lFrObj)
	    ENDIF	

	    lFrObj.checkDocumentClosed

	ENDFUNC
	
	**************************************************
	**** ????? ???
	**************************************************
	FUNCTION FR_log
		LPARAMETERS lcName
		
		LOCAL lcdate,lcfiless  
		
		IF !DIRECTORY('FR_log')
			MKDIR 'FR_log'
		EndIF
		
		lcdate = STRTRAN(STRTRAN(DTOC(date()),'.','_'),'/','_')
		lcfiless = 'FR_log\FR_' + lcdate + '.txt'

		IF !EMPTY(lcName)

			lcName = time() + ' - ' + SYS(0) + ' - ' +  lcName + chr(13) + chr(10)
			STRTOFILE(lcName, lcfiless,.t.)

		ENDIF
	 
		
	ENDFUNC
	
	FUNCTION ERROR_MESS
		LPARAMETERS lFrObj

		ERROR STR(lFrObj.errorCode) + '/' + lFrObj.errorDescription()
	ENDFUN

ENDDEFINE