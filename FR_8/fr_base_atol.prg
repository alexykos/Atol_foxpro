**********************************************************************************
**********************************************************************************
**********************************************************************************
DEFINE Class FR_BASE_ATOL as custom

	
	
	FUNCTION FR_CreateObj
			LOCAL lFR 
			lFR = CreateObject("AddIn.FprnM45")
			*("AddIn.TFprnM8")
			*
			RETURN lFR  
	ENDFUNC
		
	*******************************************	
	* ������������� ������ ���������� �������������� ���
   
	FUNCTION FR_Password
		Lparam lFR,lPassword 
		LFR.Password = lPassword 
			
	ENDFUNC
	
	*******************************************	
	*������� ����������
	FUNCTION FR_Release
		Lparam lFR 
			lFR  = 0
			RELEASE lFR 
	ENDFUNC
	
	*******************************************	
	* �������� ����
	FUNCTION FR_DeviceEnabled
		lparam lFR 
		lFR.DeviceEnabled = .T.
	  			
	  	RETURN lFR.ResultCode 
	 ENDFUNC

	*******************************************	
	* ����������� ����
	FUNCTION FR_DeviceEnabledFalse
		lparam lFR 
		lFR.DeviceEnabled = .F.
	  			
	  	RETURN lFR.ResultCode 
	 ENDFUNC

	*******************************************	 
	* ������ � �����
	FUNCTION FR_SetMode
		lparam lFR, lMode  
		* ������ � ����� 
	  	lFR.Mode = lMode  
  		RETURN lFR.SetMode
	 ENDFUNC

	*******************************************
	* �������� ��������� ���
	FUNCTION FR_GetStatus
		lparam lFR 
	  
	  	RETURN lFR.GetStatus
	 ENDFUNC
	  		
	*******************************************
	* �������� ����������
	FUNCTION FR_CashIncome 
		param lFR, lSumm 
	  		 lFR.Summ = lSumm 
	  	RETURN lFR.CashIncome 
	 ENDFUNC

	*******************************************
	* ������� ����������
	FUNCTION FR_CashOutcome 
		lparam lFR, lSumm 
	  		 lFR.Summ = lSumm
	  	RETURN lFR.CashOutcome 
	 ENDFUNC
	  		
	*******************************************
	* X - �����
	FUNCTION FR_Print_X
		lparam lFR 
		
		* ������� �����
		lFR.ReportType = 2
		RETURN lFR.Report
	ENDFUNC

	*******************************************
	* Z - �����
	FUNCTION FR_Print_Z
		lparam lFR 

		* ������� �����
		lFR.ReportType = 1
		RETURN lFR.Report
	ENDFUNC	

	*******************************************
	* ����� - �����
	FUNCTION FR_Print_type
		lparam lFR , lTypeReport 

		* ������� �����
		lFR.ReportType = lTypeReport 
		RETURN lFR.Report
	ENDFUNC	
	
	*******************************************
	* �������� ���� ��� �����
	FUNCTION FR_CloseCheck 
		lparam lFR
		*, lTypeClose  
		*** ��� ������
		*lFR.TypeClose = lTypeClose  

		RETURN lFR.CloseCheck
	ENDFUNC		
	
	*******************************************
	* ��������  ���� ��������� � ������ ���������� �� ������� �����
	FUNCTION FR_Delivery
		lparam lFR, lSumma  
		*** ��� ������ �������
		lFR.TypeClose = 0  

		RETURN lFR.Delivery 
	ENDFUNC		
	
	
ENDDEFINE

