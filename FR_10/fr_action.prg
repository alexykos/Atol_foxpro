LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint, lcQ, lType_doc ,lType_tax

SET EXACT ON
**SET PROCEDURE TO fr_driver_atol10.prg additive
SET PROCEDURE TO FR_DRIVER_ATOL10.prg additive


lcType = "ATOL10"


lFrPrint = NEWOBJECT( "myFr_print")
lFRDriver = lFrPrint.fr_Choose(lcType)
lFrPrint = CREATEOBJECT("FR_action")





lcQPay = SYS(2015)
CREATE CURSOR (lcQPay) (type i,summ Y)

INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(1, NTOM(400))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(2, NTOM(200))
*INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(3, NTOM(200))
*INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(4, NTOM(60))


lcQ = SYS(2015)
CREATE CURSOR (lcQ) (name c(200),price Y, quantity Y, Department I, nds Y)

INSERT INTO (lcQ)(name ,price , quantity , Department, nds) ;
VALUES('tovar 1', NTOM(100),NTOM(3),0,120)
INSERT INTO (lcQ)(name ,price , quantity , Department,nds) ;
VALUES('tovar 2', NTOM(150),NTOM(2),0,18)



LOCAL lFptr,LCashierFio, lCashierINN, loParam, lRecipientName, lRecipientINN


LCashierFio = 'Белобородов'
lCashierINN = '503501835111'


LCashierFio = 'Белобородов А.С.'
lCashierINN = '123456789047'

lRecipientName	= ''&&'ИП Белобородов'
lRecipientINN	= ''&&'503501835144'

lCashIncSumm = NTOM(150)
lCashOutSumm = NTOM(110)

loParam = createobject('custom')
loParam.addproperty('CashierFio', lCashierFio)
loParam.addproperty('CashierINN', lCashierINN)

loParam.addproperty('RecipientName', lRecipientName)
loParam.addproperty('RecipientINN',lRecipientINN)

loParam.addproperty('CashIncSumm', lCashIncSumm )
loParam.addproperty('CashOutSumm', lCashOutSumm)



lCashIncSumm = NTOM(150)
lCashOutSumm = NTOM(110)

loParam = createobject('custom')
loParam.addproperty('CashierFio', LCashierFio)
loParam.addproperty('CashierINN', lCashierINN)


loParam.addproperty('RecipientName', lRecipientName)
loParam.addproperty('RecipientINN',lRecipientINN)

loParam.addproperty('CashIncSumm', lCashIncSumm )
loParam.addproperty('CashOutSumm', lCashOutSumm)

loParam.addproperty('TAX', 1)

loParam.addproperty('CashQPay', lcQPay)
loParam.addproperty('CashCheckBody', lcQ)
loParam.addproperty('TypeDoc', 1 )

*SET STEP ON 

*lFrPrint.FR_X(lFRDriver,loParam)
*lFrPrint.FR_Z(lFRDriver,loParam)
*lFrPrint.FR_CashInc(lFRDriver,loParam)
*lFrPrint.FR_CashOut(lFRDriver,loParam)
lFrPrint.FR_DOC(lFRDriver,loParam)


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
			CASE lcTypeFR = "ATOL10"
				lFrObj  = CREATEOBJECT("FR_DRIVER_ATOL10")	
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

	****X- отчет
	FUNCTION FR_X
		LPARAMETERS lDriver,lFrObj
		RETURN lDriver.FR_X(lFrObj)
	ENDFUN	

	****Z- отчет
	FUNCTION FR_Z
		LPARAMETERS lDriver,lFrObj
		RETURN lDriver.FR_Z(lFrObj)
	ENDFUN	
	
	**** внесение наличности
	FUNCTION FR_CashInc
		LPARAMETERS lDriver,lFrObj
		RETURN lDriver.FR_CashInc(lFrObj)
	ENDFUNC
	
	**** Выдача наличности
	FUNCTION FR_CashOut 
		LPARAMETERS lDriver,lFrObj	 
		RETURN lDriver.FR_CashOut(lFrObj)
	ENDFUNC

	**** Логирование
	FUNCTION FR_log
		LPARAMETERS lDriver,lError 	 
		RETURN lDriver.FR_log(lError)
	ENDFUNC
	
	*****документ
	**
	FUNCTION FR_DOC
		LPARAMETERS lDriver,lFrObj 
	
		RETURN lDriver.FR_DOC(lFrObj)
		
	ENDFUN

ENDDEFINE

