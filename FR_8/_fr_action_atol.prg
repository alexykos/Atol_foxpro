
SET PROCEDURE TO _fr_base_atol ADDITIVE

LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint

lPassword  = '30'
lSumm = 0

lFrPrint = createobject("_FR_action_atol")

lFrObj = lFrPrint.FR_CreateObj()
IF VARTYPE(lFrObj) <> ''
	ERROR '������ ���������� ������ FR_CreateObj()'
EndIF	

lFrPrint.FR_X(lFrPrint,lFrObj,lPassword)

*FR_CHEK(lFrPrint,lFrObj,lPassword)

*FR_Z(lFrPrint,lFrObj,lPassword)

lFrObj = 0
RELEASE lFrPrint,lFrObj


**********************************************************************************
**********************************************************************************
DEFINE Class _FR_action_atol as _FR_Base_atol



	FUNCTION FR_CreateObj
		
			RETURN CreateObject("AddIn.FprnM45")
	ENDFUNC
		


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

	this.FR_BEFORE_CHEK()

	  * ����������� �������
	lFrObj.Name = "������"
	lFrObj.Price = 10.45
	lFrObj.Quantity = 1
	lFrObj.Department = 2
	If lFrObj.Registration <> 0 Then
		ERROR '������  Registration'
	ENDIF
	
	this.FR_BEFORE_CHEK()
	
	  * �������� ���� ��������� ��� ����� ���������� �� ������� �����
	lFrObj.TypeClose = 0
	If lFrObj.CloseCheck <> 0 Then
		ERROR '������  CloseCheck '
	EndIf


	* ����������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

ENDFUNC

FUNCTION FR_BEFORE_CHEK
ENDFUNC

FUNCTION FUNCTION FR_BEFORE_CHEK
ENDFUNC
*************************
***X-�����***************
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

ENDFUNC


*************************
***Z-�����***************
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

ENDFUNC





ENDDEFINE