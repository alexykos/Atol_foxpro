LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint, lcQ, lType_doc 



lcQPay = SYS(2015)
CREATE CURSOR (lcQPay) (type i,summ Y)

INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(1, NTOM(200))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(2, NTOM(300))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(0, NTOM(100))


lcQ = SYS(2015)
CREATE CURSOR (lcQ) (name c(200),price Y, quantity Y, Department I, nds Y)

INSERT INTO (lcQ)(name ,price , quantity , Department, nds) ;
VALUES('tovar 1', NTOM(100),NTOM(3),0,20)
INSERT INTO (lcQ)(name ,price , quantity , Department,nds) ;
VALUES('tovar 2', NTOM(150),NTOM(2),0,20)



LOCAL lFptr,LCashierFio, lCashierINN, loParam, lRecipientName, lRecipientINN

LCashierFio = '����������� �.�.'
lCashierINN = '123456789047'

lRecipientName	= '�� �����������'
lRecipientINN	= '503501835144'

lCashIncSumm = NTOM(150)
lCashOutSumm = NTOM(110)

loParam = createobject('custom')
loParam.addproperty('CashierFio', lCashierFio)
loParam.addproperty('CashierINN', lCashierINN)

loParam.addproperty('RecipientName', lRecipientName)
loParam.addproperty('RecipientINN',lRecipientINN)

loParam.addproperty('CashIncSumm', lCashIncSumm )
loParam.addproperty('CashOutSumm', lCashOutSumm)

loParam.addproperty('TypeDoc', 1 )

loParam.addproperty('TAX', 32)

loParam.addproperty('CashQPay', lcQPay)
loParam.addproperty('CashCheckBody', lcQ)


lFrPrint= createobject("FR_DRIVER_ATOL10")
*SET STEP ON 
*lFrPrint.FR_X(loParam)
*lFrPrint.FR_Z(loParam)
*lFrPrint.FR_CashInc(loParam)
*lFrPrint.FR_CashOut(loParam)
lFrPrint.FR_DOC(loParam)




DEFINE Class FR_DRIVER_ATOL10 as custom
	
	FUNCTION FR_INIT
			LOCAL lFR 
			lFR = CreateObject("AddIn.Fptr10")
			RETURN lFR 
	ENDFUNC
	
	
**************************************************
****������ ���������
**************************************************	
FUNCTION FR_DOC
	LPARAMETERS loParam 
		
		LOCAL lFrObj
		lFrObj = THIS.FR_INIT()
		
		THIS.FR_log('FR_DOC')
		  
		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    EndIF

		isOpened = lFrObj.isOpened()

	****����������� �������
	   THIS.FR_REG_CASHIER(lFrObj,loParam)

	****����������� ����������
	   THIS.FR_REG_RECIPIENT(lFrObj,loParam)

	***#�������� ��������� ����
	***#��� ����:������
	
*!*	   	��� - 1  
*!*	   	��� ����� - 2  
*!*	   	��� �����-������ - 4  
*!*	   	���� - 8  
*!*	   	��� - 16  
*!*	   	��� - 32	
*!*	    LIBFPTR_TT_DEFAULT - �� ���������
*!*	   	LIBFPTR_TT_OSN - ����� ���
*!*	    LIBFPTR_TT_USN_INCOME - ���������� �����
*!*	    LIBFPTR_TT_USN_INCOME_OUTCOME - ���������� ����� ����� ������
*!*	    LIBFPTR_TT_ENVD - ����
*!*	    LIBFPTR_TT_ESN - ������ �������������������� �����
*!*	    LIBFPTR_TT_PATENT - ��������� ���
	LOCAL lTax, lTaxParam, lNDS, lNDSParam  
SET STEP ON 
	lTax = loParam.Tax
	DO CASE
		CASE lTax = 1
			lTaxParam = lFrObj.LIBFPTR_TT_OSN 
		CASE lTax = 2
			lTaxParam = lFrObj.LIBFPTR_TT_USN_INCOME 
		CASE lTax = 4
			lTaxParam = lFrObj.LIBFPTR_TT_USN_INCOME_OUTCOME 
		CASE lTax = 8
			lTaxParam = lFrObj.LIBFPTR_TT_ENVD 
		CASE lTax = 16
			lTaxParam = lFrObj.LIBFPTR_TT_ESN 
		CASE lTax = 32
			lTaxParam = lFrObj.LIBFPTR_TT_PATENT 	
	ENDCASE	

	lTypeDoc = loParam.TypeDoc

	DO CASE
		CASE lTypeDoc = 1 && �������
			lTypeDocParam = lFrObj.LIBFPTR_RT_SELL 
		CASE lTypeDoc = 2 && �������
			lTypeDocParam = lFrObj.LIBFPTR_RT_SELL_RETURN 
	ENDCASE	

	lFrObj.setParam(1055, lTaxParam )
	lFrObj.setParam(lFrObj.LIBFPTR_PARAM_RECEIPT_TYPE, lTypeDocParam )
	lFrObj.openReceipt()
	***#����������� ������� � ��������� ����� ������
	
	lcQ = loParam.CashCheckBody
	SELECT (lcQ)

			GO TOP	
			DO WHILE !EOF(lcQ)
			
				lTovarname		= ALLTRIM(EVALUATE(lcQ + '.name'))
				lPrice 			= EVALUATE(lcQ + '.price')
				lQuantity 		= EVALUATE(lcQ + '.quantity')
				lDepartment 	= EVALUATE(lcQ + '.Department')
				lNDS 			= EVALUATE(lcQ + '.nds')
			
				DO CASE
					CASE lNDS = -1 
						lNDSParam = lFrObj.LIBFPTR_TAX_NO &&�� ����������
					CASE lNDS = 0
						lNDSParam = lFrObj.LIBFPTR_TAX_VAT0 &&- ��� 0%
					CASE lNDS = 110
						lNDSParam = lFrObj.LIBFPTR_TAX_VAT110 &&- ��� ����������� 10/11
					CASE lNDS = 118
						lNDSParam = lFrObj.LIBFPTR_TAX_VAT118 &&- ��� ����������� 18/118
					CASE lNDS = 120
						lNDSParam = lFrObj.LIBFPTR_TAX_VAT120 &&- ��� ����������� 20/120
					CASE lNDS = 10
						lNDSParam = lFrObj.LIBFPTR_TAX_VAT10 &&- ��� 10%	
					CASE lNDS = 18
						lNDSParam = lFrObj.LIBFPTR_TAX_VAT18 &&- ��� 18%	
					CASE lNDS = 20
						lNDSParam = lFrObj.LIBFPTR_TAX_VAT20 &&- ��� 20%		
				ENDCASE	
			
				
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_COMMODITY_NAME, lTovarname)
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_PRICE, lPrice )
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_QUANTITY, lQuantity )
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_DEPARTMENT , lDepartment  )
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_TAX_TYPE, lNDSParam )
				*LIBFPTR_PARAM_TAX_SUM - ����� ������. ��� �������� �������� 0 �������������� �������������
				lFrObj.setParam(lFrObj.LIBFPTR_PARAM_TAX_SUM, 0)
				lFrObj.registration()
				
				
		
				SKIP IN (lcQ)
			ENDDO	
	
	****#������ ����

	THIS.FR_PAYMENT_DOC(lFrObj,loParam)
	*lFrObj.setParam(lFrObj.LIBFPTR_PARAM_PAYMENT_TYPE, lFrObj.LIBFPTR_PT_ELECTRONICALLY)
	*lFrObj.payment()
	***#����������� ������ �� ���
*!*		lFrObj.setParam(lFrObj.LIBFPTR_PARAM_TAX_TYPE, lNDSParam )
*!*		lFrObj.receiptTax()
	****#����������� ����� ����
	IF lFrObj.receiptTotal() = -1
		THIS.ERROR_MESS(lFrObj)
    ENDIF

	***#�������� ��������� ����������� ����
	IF lFrObj.closeReceipt() = -1
		THIS.ERROR_MESS(lFrObj)
    ENDIF

	***#���������� ���������� � ���
	IF lFrObj.close() = -1
		THIS.ERROR_MESS(lFrObj)
    EndIF

ENDFUN

	****�������� ������ ��������� (��������������� ������)
	FUNCTION FR_PAYMENT_DOC()
		LPARAMETERS lFrObj,loParam 
		
		*LIBFPTR_PT_CASH - ���������
		*LIBFPTR_PT_ELECTRONICALLY - ������������
		*LIBFPTR_PT_PREPAID - ��������������� ������ (�����)	

		local lcQPay, lSUMM, lPayType  
		
		lcQPay = loParam.CashQPay
		
		SELECT (lcQPay)

		GO TOP 
		DO WHILE !EOF(lcQPay)
			lSUMM 		= EVALUATE(lcQPay + '.summ')
			lTypePay 	= EVALUATE(lcQPay + '.type')
			DO CASE
				CASE lTypePay = 1 &&������������
					lPayType   = lFrObj.LIBFPTR_PT_ELECTRONICALLY 
				CASE lTypePay = 2 &&��������������� ������ (�����)
					lPayType   = lFrObj.LIBFPTR_PT_PREPAID 
				OTHERWISE &&	��������� 		
					lPayType   = lFrObj.LIBFPTR_PT_CASH
			ENDCASE
								
			lFrObj.setParam(lFrObj.LIBFPTR_PARAM_PAYMENT_TYPE, lPayType )
			lFrObj.setParam(lFrObj.LIBFPTR_PARAM_PAYMENT_SUM, lSUMM)
			
			IF lFrObj.PAYMENT() = -1
				THIS.ERROR_MESS(lFrObj)
			ENdIF		
		SKIP IN (lcQPay)
		ENDDO 
	
	ENDFUNC
	


**************************************************
	****X- �����
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
	****�������� 
	**************************************************
	FUNCTION FR_CashInc
		LPARAMETERS loParam 
		
		THIS.FR_log('FR_CashInc')

		LOCAL lFrObj, LSumm 
		lFrObj = THIS.FR_INIT()

		LSumm = loParam.CashIncSumm
		
		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    ENDIF
	    
	    ****����������� �������
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
	****������
	**************************************************
	FUNCTION FR_CashOut 
		LPARAMETERS loParam 
		
		THIS.FR_log('FR_CashOut')

		LOCAL lFrObj, LSumm 
		lFrObj = THIS.FR_INIT()

		LSumm = loParam.CashOutSumm
		
		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    ENDIF
	    
	    ****����������� �������
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
	****����������� �������
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
	    	
	ENDFUNC
	
		**************************************************
	****����������� ����������
	**************************************************
	FUNCTION FR_REG_RECIPIENT
		LPARAMETERS lFrObj, loParam 
		
		LOCAL LRecipientName, lRecipientINN


		LRecipientName	= ALLTRIM(loParam.RecipientName)
		lRecipientINN	= ALLTRIM(loParam.RecipientINN)
	    lFrObj.setParam(1227, LRecipientName)
	    lFrObj.setParam(1228, lRecipientINN)
	
	    	
	EndFun


	**************************************************
	****Z- �����
	**************************************************
	FUNCTION FR_Z
		LPARAMETERS loParam 
		
		THIS.FR_log('FR_Z')
		
		LOCAL lFrObj
		lFrObj = THIS.FR_INIT()
		

		IF lFrObj.Open = -1
			THIS.ERROR_MESS(lFrObj)
	    EndIF

		****����������� �������
	   THIS.FR_REG_CASHIER(lFrObj,loParam)

	    lFrObj.setParam(lFrObj.LIBFPTR_PARAM_REPORT_TYPE, lFrObj.LIBFPTR_RT_CLOSE_SHIFT)
	    IF lFrObj.report = -1
	    	THIS.ERROR_MESS(lFrObj)
	    ENDIF	

	    lFrObj.checkDocumentClosed

	ENDFUNC
	
	**************************************************
	**** ����� ���
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
		LOCAL lErrMess
		lErrMess = STR(lFrObj.errorCode) + '/' + lFrObj.errorDescription()
		lFrObj.cancelReceipt()
		ERROR lErrMess 

	ENDFUN

ENDDEFINE