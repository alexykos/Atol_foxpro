LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint

lPassword  = '30'
lSumm = 0

lFrPrint = createobject("_FR_Printer")

lFrObj = lFrPrint.FR_CreateObj()
IF VARTYPE(lFrObj) <> ''
	ERROR '������ ���������� ������ FR_CreateObj()'
EndIF	

*FR_X(lFrPrint,lFrObj,lPassword)

FR_CHEK(lFrPrint,lFrObj,lPassword)

*FR_Z(lFrPrint,lFrObj,lPassword)

lFrObj = 0
RELEASE lFrPrint,lFrObj



FUNCTION FR_CHEK
	LPARAMETERS lFrPrint,lFrObj,lPassword    
	* �������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* ������������� ������
	lFrPrint.FR_Password(lFrObj, lPassword)

	 * ������ � ����� �����������
	lMode = 1
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR '������ ��������� ������ FR_SetMode(,1) - ' + STR(lSetMode)
	EndIF	

	  * ����������� �������
	lFrObj.Name = "������"
	lFrObj.Price = 10.45
	lFrObj.Quantity = 1
	lFrObj.Department = 2
	If lFrObj.Registration <> 0 Then
		ERROR '������  Registration'
	EndIf
	
	  * �������� ���� ��������� ��� ����� ���������� �� ������� �����
	lFrObj.TypeClose = 0
	If lFrObj.CloseCheck <> 0 Then
		ERROR '������  CloseCheck '
	EndIf


	* ����������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

EndFun


*************************
**************************

FUNCTION FR_X
	LPARAMETERS lFrPrint,lFrObj,lPassword    
	* �������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* ������������� ������
	lFrPrint.FR_Password(lFrObj, lPassword)

	 * ������ � ����� ������� ��� �������
	lMode = 2
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR '������ ��������� ������ FR_SetMode(,2)'
	EndIF	

	* X - �����
	lPrint = lFrPrint.FR_Print_X(lFrObj)
	IF lPrint <> 0
		ERROR '������ FR_Print_X()-'+ STR(lPrint)
	EndIF	 

	* ����������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

EndFun

*************************
**************************

FUNCTION FR_Z
	LPARAMETERS lFrPrint,lFrObj,lPassword    
	
			
	IF !lFrObj.SessionOpened Then
		MESSAGEBOX('����� �������',64,'��������',10000)	
		return
	EndIF	

	* �������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* ������������� ������
	lFrPrint.FR_Password(lFrObj, lPassword)

	 * ������ � ����� �������  � ��������
	lMode = 3
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR '������ ��������� ������ FR_SetMode(,3)'
	EndIF	

	* Z - �����
	lPrint = lFrPrint.FR_Print_Z(lFrObj)
	MESSAGEBOX(lPrint)
	IF lPrint <> 0
		ERROR '������ FR_Print_Z() - ' + STR(lPrint)
	EndIF	 

	* ����������� ����
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
	FUNCTION FR_GetStatus
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
	
ENDDEFINE






