

SET PROCEDURE TO FR_BASE_ATOL.prg ADDITIVE

lPassword  = '30'
lSumm = 0


lFrPrint = createobject("FR_action_ATOL")
lFrPrint.FR_mess()
RETURN

*!*	lPassword  = '30'
*!*	lSumm = 0

*!*	lFrPrint = createobject( "FR_action_atol")

*!*	lFrObj = lFrPrint.FR_CreateObj()
*!*	IF VARTYPE(lFrObj) <> ''
*!*		ERROR 'Ошибка выполнения метода FR_CreateObj()'
*!*	EndIF	

*!*	lFrPrint.FR_X(lFrPrint,lFrObj,lPassword)

*!*	*FR_CHEK(lFrPrint,lFrObj,lPassword)

*!*	*FR_Z(lFrPrint,lFrObj,lPassword)

*!*	lFrObj = 0
*!*	RELEASE lFrPrint,lFrObj





DEFINE Class FR_action_ATOL as FR_BASE_ATOL 

FUNCTION FR_mess
	MESSAGEBOX('1')
ENDFUN


FUNCTION FR_CreateObj
		LOCAL lFR 
		lFR = CreateObject("AddIn.FprnM45")
		RETURN lFR 
ENDFUNC

**************************************************
**** ЧЕК
**************************************************
FUNCTION FR_CHEK
	LPARAMETERS lFrPrint,lFrObj,lPassword, lcQ ,lSumm   
	
	
	*Проверка параметров чека
	this.fr_check_param(lFrPrint,lFrObj,lPassword, lcQ ,lSumm)
	
	* занимаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* устанавливаем пароль
	lFrPrint.FR_Password(lFrObj, lPassword)

	 * входим в режим регистрации
	lMode = 1
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR 'Ошибка установки режима FR_SetMode(,1) - ' + STR(lSetMode)
	EndIF	
	
	***********действие вначале чека
	THIS.FR_BEFORE_CHEK()
	
  * регистрация продажи
  * тело чека
  	THIS.FR_BODY_CHEK(lFrObj, lcQ)
	
	
	***********действие после  тела чека
	this.FR_AFTER_CHEK()
	
	  * закрытие чека 
	this.FR_CLOSE_CHEK(lFrPrint, lFrObj,lSumm)

	* освобождаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

ENDFUNC

**** Проверка параметрова чека
FUNCTION fr_check_param	
	LPARAMETERS lFrPrint,lFrObj,lPassword, lcQ ,lSumm   

	LOCAL lTotal, lcQTotal
			
	IF RECCOUNT(lcQ) = 0
		ERROR 'Пустой курсор чека (lcQ)'
	ENDIF	
	
	****Проверяе, если сумма наличными от клиента меньше, чем 
	****сумаа докумжента, то ошибка
	IF lSumm > 0
		
		lcQTotal = SYS(2015)
		SELECT SUM(price*quantity) as total FROM (lcQ) INTO CURSOR (lcQTotal)
		
		lTotal= EVALUATE(lcQTotal + '.total')
		
		IF lTotal > lSumm 
			ERROR 'Сумма наличными меньше, чем сумма документа. Сумма документа -' + STR(lTotal,9,2) + '/ Сумма наличными -' + STR(lSumm,9,2) 
		ENDIF	
		
	EndIF

ENDFUN

**** Вначале тела чека
FUNCTION FR_BEFORE_CHEK
ENDFUNC

**** Вконце тела чека
FUNCTION FR_AFTER_CHEK
EndFun

****Тело чека
FUNCTION FR_BODY_CHEK
	LPARAMETERS lFrObj, lcQ
	
	SELECT (lcQ)
	GO TOP	
	DO WHILE !EOF(lcQ)
		lFrObj.Name 		= EVALUATE(lcQ + '.name')
		lFrObj.Price 		= EVALUATE(lcQ + '.price')
		lFrObj.Quantity 	= EVALUATE(lcQ + '.quantity')
		lFrObj.Department 	= EVALUATE(lcQ + '.Department')
		
		
		If lFrObj.Registration <> 0 Then
			ERROR 'Ошибка  Registration'
		EndIf
		SKIP IN (lcQ)
	ENDDO
	
ENDFUNC

**** закрытие чека
FUNCTION FR_CLOSE_CHEK
	LPARAMETERS lFrPrint, lFrObj, lSumm
	
	local lTypeClose

	  * если lSumm = 0 наличными без ввода полученной от клиента суммы

	lTypeClose = 0 &&Наличными	  
	IF lSumm > 0
		lFrObj.summ = lSumm 	
		If lFrPrint.FR_Delivery(lFrObj,lTypeClose) <> 0 Then
			ERROR 'Ошибка  CloseCheck '
		EndIf
	ELSE
		If lFrPrint.FR_CloseCheck(lFrObj,lTypeClose) <> 0 Then
			ERROR 'Ошибка  CloseCheck '
		EndIf
	
	EndIF 


ENDFUNC


**************************************************
****X- отчет
**************************************************

FUNCTION FR_X
	LPARAMETERS lFrPrint,lFrObj,lPassword   
	
	LOCAL lDevice, lPrint, lMode 
	  
	* занимаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* устанавливаем пароль
	lFrPrint.FR_Password(lFrObj, lPassword)

	 * входим в режим отчетов без гашения
	lMode = 2
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR 'Ошибка установки режима FR_SetMode(,2)'
	EndIF	
	
	* X - отчет
	lPrint = lFrPrint.FR_Print_X(lFrObj)
	IF lPrint <> 0
		ERROR 'Ошибка FR_Print_X()-'+ STR(lPrint)
	EndIF	 

	* освобождаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

EndFun


**************************************************
****Z- отчет
**************************************************

FUNCTION FR_Z
	LPARAMETERS lFrPrint,lFrObj,lPassword    
	
	LOCAL lDevice, lPrint , lSetMode  
**почему-то всегда FALSE может из-за тестового ФН			
*!*		IF !lFrObj.SessionOpened Then
*!*			messagebox('Сметна закрыта',64,'Внимание')	
*!*			return
*!*		ENDIF
*!*			

	* занимаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* устанавливаем пароль
	lFrPrint.FR_Password(lFrObj, lPassword)

	 * входим в режим отчетов  с гашением
	lMode = 3
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR 'Ошибка установки режима FR_SetMode(,3)'
	EndIF	

	* Z - отчет
	lPrint = lFrPrint.FR_Print_Z(lFrObj)
	MESSAGEBOX(lPrint)
	IF lPrint <> 0
		ERROR 'Ошибка FR_Print_Z() - ' + STR(lPrint)
	EndIF	 

	* освобождаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)


ENDFUNC


**************************************************
**** внесение наличности
**************************************************

FUNCTION FR_CashInc
	LPARAMETERS lFrPrint,lFrObj,lPassword, lSumm    
	
	LOCAL lDevice, lPrint , lSetMode  

	* занимаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* устанавливаем пароль
	lFrPrint.FR_Password(lFrObj, lPassword)
	
	 * входим в режим отчетов  с гашением
	lMode = 1
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR 'Ошибка установки режима FR_SetMode(,1)'
	EndIF	
	lFrPrint.FR_CashIncome(lFrObj, lSumm) 
	
	* освобождаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)
	
	
ENDFUN

**************************************************
**** Выдача наличности
**************************************************
FUNCTION FR_CashOut 
	LPARAMETERS lFrPrint,lFrObj,lPassword, lSumm    
	
	LOCAL lDevice, lPrint , lSetMode  

	* занимаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* устанавливаем пароль
	lFrPrint.FR_Password(lFrObj, lPassword)
	
	 * входим в режим отчетов  с гашением
	lMode = 1
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR 'Ошибка установки режима FR_SetMode(,1)'
	EndIF	
	lFrPrint.FR_CashOutcome(lFrObj, lSumm) 
	
	* освобождаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)
	
	
ENDFUN

ENDDEFINE