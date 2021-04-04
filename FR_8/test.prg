LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint

lPassword  = '30'
lSumm = 0

lFrPrint = createobject("_FR_Printer")

lFrObj = lFrPrint.FR_CreateObj()
IF VARTYPE(lFrObj) <> ''
	ERROR 'Ошибка выполнения метода FR_CreateObj()'
EndIF	

*FR_X(lFrPrint,lFrObj,lPassword)

FR_CHEK(lFrPrint,lFrObj,lPassword)

*FR_Z(lFrPrint,lFrObj,lPassword)

lFrObj = 0
RELEASE lFrPrint,lFrObj



FUNCTION FR_CHEK
	LPARAMETERS lFrPrint,lFrObj,lPassword    
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

	  * регистрация продажи
	lFrObj.Name = "Молоко"
	lFrObj.Price = 10.45
	lFrObj.Quantity = 1
	lFrObj.Department = 2
	If lFrObj.Registration <> 0 Then
		ERROR 'Ошибка  Registration'
	EndIf
	
	  * закрытие чека наличными без ввода полученной от клиента суммы
	lFrObj.TypeClose = 0
	If lFrObj.CloseCheck <> 0 Then
		ERROR 'Ошибка  CloseCheck '
	EndIf


	* освобождаем порт
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

EndFun


*************************
**************************

FUNCTION FR_X
	LPARAMETERS lFrPrint,lFrObj,lPassword    
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

*************************
**************************

FUNCTION FR_Z
	LPARAMETERS lFrPrint,lFrObj,lPassword    
	
			
	IF !lFrObj.SessionOpened Then
		MESSAGEBOX('Смена закрыта',64,'Внимание',10000)	
		return
	EndIF	

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

EndFun

**********************************************************************************
**********************************************************************************
**********************************************************************************
DEFINE Class _FR_Printer as custom

	
	
	FUNCTION FR_CreateObj
			LOCAL lFR 
			lFR = CreateObject("AddIn.FprnM45")
			RETURN lFR 
	ENDFUNC
		
	*******************************************	
	* устанавливаем пароль системного администратора ККМ
   
	FUNCTION FR_Password
		Lparam lFR,lPassword 
		LFR.Password = lPassword 
			
	ENDFUNC
	
	*******************************************	
	*Удаляем переменную
	FUNCTION FR_Release
		Lparam lFR 
			lFR  = 0
			RELEASE lFR 
	ENDFUNC
	
	*******************************************	
	* занимаем порт
	FUNCTION FR_DeviceEnabled
		lparam lFR 
		lFR.DeviceEnabled = .T.
	  			
	  	RETURN lFR.ResultCode 
	 ENDFUNC

	*******************************************	
	* освобождаем порт
	FUNCTION FR_DeviceEnabledFalse
		lparam lFR 
		lFR.DeviceEnabled = .F.
	  			
	  	RETURN lFR.ResultCode 
	 ENDFUNC

	*******************************************	 
	* входим в режим
	FUNCTION FR_SetMode
		lparam lFR, lMode  
		* входим в режим 
	  	lFR.Mode = lMode  
  		RETURN lFR.SetMode
	 ENDFUNC

	*******************************************
	* получаем состояние ККМ
	FUNCTION FR_GetStatus
		lparam lFR 
	  
	  	RETURN lFR.GetStatus
	 ENDFUNC
	  		
	*******************************************
	* внесение наличности
	FUNCTION FR_GetStatus
		param lFR, lSumm 
	  		 lFR.Summ = lSumm 
	  	RETURN lFR.CashIncome 
	 ENDFUNC

	*******************************************
	* выплата наличности
	FUNCTION FR_CashOutcome 
		lparam lFR, lSumm 
	  		 lFR.Summ = lSumm
	  	RETURN lFR.CashOutcome 
	 ENDFUNC
	  		
	*******************************************
	* X - отчет
	FUNCTION FR_Print_X
		lparam lFR 
		
		* снимаем отчет
		lFR.ReportType = 2
		RETURN lFR.Report
	ENDFUNC

	*******************************************
	* Z - отчет
	FUNCTION FR_Print_Z
		lparam lFR 

		* снимаем отчет
		lFR.ReportType = 1
		RETURN lFR.Report
	ENDFUNC	
	
ENDDEFINE






