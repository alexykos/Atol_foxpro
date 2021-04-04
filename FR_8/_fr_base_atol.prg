**********************************************************************************
**********************************************************************************
DEFINE Class _FR_Base_atol as custom

	
	
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

