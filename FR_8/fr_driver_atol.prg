

SET PROCEDURE TO FR_BASE_ATOL.prg ADDITIVE

lPassword  = '30'
lSumm = 0


lFrPrint = createobject("FR_DRIVER_ATOL")
*lFrPrint.FR_mess()
aa = lFrPrint.FR_INIT()
lFrPrint.FR_X(aa,lPassword)
return
lFrPrint.FR_DeviceEnabled(aa)
lFrPrint.FR_Password(aa, lPassword)

lFrPrint.FR_X(aa,lPassword)
MESSAGEBOX(aa.CheckState)
MESSAGEBOX(aa.CancelCheck())
*CheckState)

*aa.GetLastError())
*aa.CheckState)
RETURN






DEFINE Class FR_DRIVER_ATOL as FR_BASE_ATOL 

	FUNCTION FR_mess
		MESSAGEBOX('1')
	ENDFUN


	FUNCTION FR_INIT
			
			RETURN This.FR_CreateObj()
	ENDFUNC

	**************************************************
	**** Док
	**************************************************
	FUNCTION FR_BEGIN_DOC
		LPARAMETERS lFrObj,lPassword

		THIS.FR_log('FR_BEGIN_DOC')
		
		* занимаем порт
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_BEGIN_DOC - FR_DeviceEnabled')
		EndIF
		* устанавливаем пароль
		THIS.FR_Password(lFrObj, lPassword)

		 * входим в режим регистрации
		lMode = 1
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode,'FR_BEGIN_DOC. Ошибка установки режима FR_SetMode(,1)')
		EndIF	
		

	ENDFUNC

	****Строка документа
	FUNCTION FR_BODY_DOC
		LPARAMETERS lFrObj, lObjBody, lType_doc 

		*** lType_doc = 1 - ЧЕК
		*** lType_doc = 2 - Возврат
		*** lType_doc = 3 - Анулирование	
		
		LOCAL lResult	
		
		THIS.FR_log('FR_BODY_DOC')
		
		IF !INLIST(NVL(lType_doc,0),1,2)
			this.FR_error(lType_doc,'FR_BODY_DOC - неизвестный тип документа (lType_doc)')
		EndIF
		
		lFrObj.Name 		= lObjBody.Tovarname
		lFrObj.Price 		= lObjBody.price
		lFrObj.Quantity 	= lObjBody.quantity
		lFrObj.Department 	= lObjBody.Department
		***** определяется номер налоговой ставки 0- из секции
		lFrObj.TaxTypeNumber = 0
		DO CASE 
			
			CASE lType_doc = 1 && Продажа
				lResult = lFrObj.Registration
				
				If lResult <> 0 Then
					this.FR_error(lResult,'FR_BODY_DOC - Ошибка Registration')
				ENDIF
			
			CASE lType_doc = 2 && Возврат
				lResult = lFrObj.Return
			
				If lResult <> 0 Then
					this.FR_error(lResult,'FR_BODY_DOC - Ошибка Return')
				ENDIF
		ENDCASE		

	ENDFUNC

	**** закрытие чека
	FUNCTION FR_CLOSE_DOC
		LPARAMETERS lFrObj, lSumm, lType_doc, lType_tax, lcQPay

	
		local lTypeClose, lResult

		THIS.FR_log('FR_CLOSE_DOC')
		
		lFrObj.AttrNumber = 1055  
		lFrObj.AttrValue = lType_tax  
		lFrObj.WriteAttribute()  
		
		 * если lSumm = 0 наличными без ввода полученной от клиента суммы
		 * lType_doc = 1 - ЧЕК
		 * и курсор комбинированной оплаты пустой
		lTypeClose = 0 &&Наличными	  
		IF lSumm > 0 AND lType_doc = 1 AND reccount(lcQPay) = 0
			
			lFrObj.summ = lSumm 
			
			lResult = THIS.FR_Delivery(lFrObj,lTypeClose)	
			If lResult <> 0 Then
				this.FR_error(lResult,'FR_CLOSE_DOC - Ошибка  FR_Delivery()')
			ENDIF
			
		ELSE
			*Если есть комбинированная оплата
			IF  reccount(lcQPay) > 0
				THIS.FR_PAYMENT_DOC(lFrObj, lcQPay)
			ELSE
				**Оплата наличными
				lFrObj.TypeClose = lTypeClose  	
			EndIF
			lResult = THIS.FR_CloseCheck(lFrObj) &&,lTypeClose
			If lResult <> 0 Then
				this.FR_error(lResult,'FR_CLOSE_DOC - Ошибка FR_CloseCheck()')
			ENDIF
			
		EndIF 

		RETURN lResult

	ENDFUNC
	
	****Варианты оплаты документа (Комбинированная оплата)
	FUNCTION FR_PAYMENT_DOC()
		LPARAMETERS lFrObj, lcQPay
		local lResult 
		
		SELECT (lcQPay)

		GO TOP 
		DO WHILE !EOF(lcQPay)
			lFrObj.SUMM 		= EVALUATE(lcQPay + '.summ')
			lFrObj.TypeClose 	= EVALUATE(lcQPay + '.type')
			lResult = lFrObj.PAYMENT()
			IF lResult <> 0	
				this.FR_error(lResult,'FR_PAYMENT_DOC - Ошибка PAYMENT() ')
			ENdIF		
		SKIP IN (lcQPay)
		ENDDO 
	
	ENDFUNC

	**** отмена документа, если CheckState <> 0
	FUNCTION FR_CANCEL_DOC
		LPARAMETERS lFrObj
		
		local lResult, lDevice 
		
		THIS.FR_log('FR_CANCEL_DOC')
		
		* занимаем порт
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CANCEL_DOC - FR_DeviceEnabled')
		EndIF
		
		*IF lFrObj.CheckState <> 0
			lResult = lFrObj.CancelCheck()
			IF lResult <> 0
				this.FR_error(lResult,'FR_CANCEL_DOC - Ошибка CancelCheck()')
			ENDIF	
		*EndIF		
		
		* освобождаем порт
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CANCEL_DOC - FR_DeviceEnabled')
		EndIF

	ENDFUNC



	**************************************************
	****X- отчет
	**************************************************

	FUNCTION FR_X
		LPARAMETERS lFrObj,lPassword   
		

		LOCAL lDevice, lPrint, lMode 
		 
		THIS.FR_log('FR_X')
		  
		* занимаем порт
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_X - FR_DeviceEnabled')
		EndIF

		* устанавливаем пароль
		THIS.FR_Password(lFrObj, lPassword)

		 * входим в режим отчетов без гашения
		lMode = 2
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode ,'FR_X - Ошибка установки режима FR_SetMode(,'+ALLTRIM(STR(lMode)))
		EndIF	
		
		* X - отчет
		lPrint = THIS.FR_Print_X(lFrObj)
		IF lPrint <> 0
			this.FR_error(lPrint,'FR_X - Ошибка FR_Print_X()')
		EndIF	 

		* освобождаем порт
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_X - FR_DeviceEnabled')
		EndIF
	EndFun


	**************************************************
	****Z- отчет
	**************************************************

	FUNCTION FR_Z
		LPARAMETERS lFrObj,lPassword    
		
		LOCAL lDevice, lPrint , lSetMode
		
		THIS.FR_log('FR_Z')  
			
	*!*		IF !lFrObj.SessionOpened Then
	*!*			messagebox('Сметна закрыта',64,'Внимание')	
	*!*			return
	*!*		ENDIF
	*!*			

		* занимаем порт
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_Z - FR_DeviceEnabled')
		EndIF
		* устанавливаем пароль
		THIS.FR_Password(lFrObj, lPassword)

		 * входим в режим отчетов  с гашением
		lMode = 3
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode ,'FR_Z - Ошибка установки режима FR_SetMode(,'+ALLTRIM(STR(lMode)))
		EndIF	

		* Z - отчет
		lPrint = THIS.FR_Print_Z(lFrObj)
		
		IF lPrint <> 0
			this.FR_error(lPrint ,'FR_Z - Ошибка FR_Print_Z')
		EndIF	 

		* освобождаем порт
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_Z - FR_DeviceEnabled')
		EndIF

	ENDFUNC

	**************************************************
	****отчет 
	*!*	Каждому отчету соответствует свой режим(lMode)
	*!*	Режим снятия отчетов без гашения.
	*!*	2.0 - ReportType = 2,7,8,9 … 11, 42 (только при закрытой смене)
	*!*	Режим снятия отчетов с гашением.
	*!*	3.0 - ReportType = 0,1,34 … 36
	*!*	Режим доступа к ФП.
	*!*	5.0 - ReportType = 3 … 6
	*!*	Режим доступа к ЭКЛЗ.
	*!*	6.0 - ReportType = 22 … 33   
	**************************************************

	FUNCTION FR_report
		LPARAMETERS lFrObj,lPassword, lTypeReport , lMode   
		
		LOCAL lDevice, lPrint   
		
		THIS.FR_log('FR_report')
		
		* занимаем порт
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_report - FR_DeviceEnabled')
		EndIF

		* устанавливаем пароль
		THIS.FR_Password(lFrObj, lPassword)

		 * входим в режим отчетов 
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode ,'FR_report - Ошибка установки режима FR_SetMode(,'+ALLTRIM(STR(lMode)))
		EndIF	

		* отчет в зависимости от типа
		lPrint = THIS.FR_Print_type(lFrObj,lTypeReport)
		*MESSAGEBOX(lPrint)
		IF lPrint <> 0
			this.FR_error(lPrint,'FR_report - Ошибка FR_Print_type('+ALLTRIM(STR(lTypeReport)))
		EndIF	 

		* освобождаем порт
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_report - FR_DeviceEnabled')
		EndIF

	ENDFUNC


	**************************************************
	**** внесение наличности
	**************************************************

	FUNCTION FR_CashInc
		LPARAMETERS lFrObj,lPassword, lSumm    
		
		LOCAL lDevice, lPrint , lSetMode ,lResult 
		
		THIS.FR_log('FR_CashInc')
		
		* занимаем порт
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashInc - FR_DeviceEnabled')
		EndIF

		* устанавливаем пароль
		THIS.FR_Password(lFrObj, lPassword)
		
		 * входим в режим отчетов  с гашением
		lMode = 1
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode,'FR_CashInc - Ошибка установки режима FR_SetMode(,1)')
		EndIF	

		lResult = THIS.FR_CashIncome(lFrObj, lSumm) 
		IF lResult <> 0
			this.FR_error(lResult,'FR_CashInc - Ошибка FR_CashIncome')
		EndIF	
		
		* освобождаем порт
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashInc - FR_DeviceEnabledFalse')
		EndIF
		
	ENDFUN

	**************************************************
	**** Выдача наличности
	**************************************************
	FUNCTION FR_CashOut 
		LPARAMETERS lFrObj,lPassword, lSumm    
		
		LOCAL lDevice, lPrint , lSetMode , lResult  
		
		THIS.FR_log('FR_CashOut')
		
		* занимаем порт
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashOut - FR_DeviceEnabled')
		EndIF

		* устанавливаем пароль
		THIS.FR_Password(lFrObj, lPassword)
		
		 * входим в режим отчетов  с гашением
		lMode = 1
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode,'FR_CashOut  - Ошибка установки режима FR_SetMode(,1)')
		ENDIF
			
		lResult  = THIS.FR_CashOutcome(lFrObj, lSumm) 
		IF lResult <> 0
			*ERROR 'Ошибка FR_CashIncome' + ALLTRIM(STR(lResult))
			this.FR_error(lResult,'FR_CashOut  - Ошибка FR_CashIncome')
		EndIF	
		
		* освобождаем порт
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashOut - FR_DeviceEnabledFalse')
		EndIF
		
	ENDFUNC

	**************************************************
	**** Печать строки
	**************************************************
	FUNCTION FR_PrintString
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** Печать шапки
	**************************************************
	FUNCTION FR_PrintHeader
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** Печать подвала
	**************************************************
	FUNCTION FR_PrintFooter
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** Печать ШК 
	**************************************************
	FUNCTION FR_PrintBarcode
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** Печать изображения 
	**************************************************
	FUNCTION FR_PrintImage
		LPARAMETERS lFrObj
	ENDFUNC


	**************************************************
	**** обработка ошибок
	**************************************************
	FUNCTION FR_error
		LPARAMETERS lResult, lCaption
		LOCAL lNameError
		
		lNameError = lCaption + ALLTR(STR(lResult))
		THIS.FR_log(lNameError)
		
		ERROR lNameError 
	ENDFUNC

	**************************************************
	**** Пишем лог
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
	 
		
	ENDFUN

ENDDEFINE