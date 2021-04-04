

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
*!*		ERROR '������ ���������� ������ FR_CreateObj()'
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
**** ���
**************************************************
FUNCTION FR_CHEK
	LPARAMETERS lFrPrint,lFrObj,lPassword, lcQ ,lSumm   
	
	
	*�������� ���������� ����
	this.fr_check_param(lFrPrint,lFrObj,lPassword, lcQ ,lSumm)
	
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
	
	***********�������� ������� ����
	THIS.FR_BEFORE_CHEK()
	
  * ����������� �������
  * ���� ����
  	THIS.FR_BODY_CHEK(lFrObj, lcQ)
	
	
	***********�������� �����  ���� ����
	this.FR_AFTER_CHEK()
	
	  * �������� ���� 
	this.FR_CLOSE_CHEK(lFrPrint, lFrObj,lSumm)

	* ����������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

ENDFUNC

**** �������� ����������� ����
FUNCTION fr_check_param	
	LPARAMETERS lFrPrint,lFrObj,lPassword, lcQ ,lSumm   

	LOCAL lTotal, lcQTotal
			
	IF RECCOUNT(lcQ) = 0
		ERROR '������ ������ ���� (lcQ)'
	ENDIF	
	
	****��������, ���� ����� ��������� �� ������� ������, ��� 
	****����� ����������, �� ������
	IF lSumm > 0
		
		lcQTotal = SYS(2015)
		SELECT SUM(price*quantity) as total FROM (lcQ) INTO CURSOR (lcQTotal)
		
		lTotal= EVALUATE(lcQTotal + '.total')
		
		IF lTotal > lSumm 
			ERROR '����� ��������� ������, ��� ����� ���������. ����� ��������� -' + STR(lTotal,9,2) + '/ ����� ��������� -' + STR(lSumm,9,2) 
		ENDIF	
		
	EndIF

ENDFUN

**** ������� ���� ����
FUNCTION FR_BEFORE_CHEK
ENDFUNC

**** ������ ���� ����
FUNCTION FR_AFTER_CHEK
EndFun

****���� ����
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
			ERROR '������  Registration'
		EndIf
		SKIP IN (lcQ)
	ENDDO
	
ENDFUNC

**** �������� ����
FUNCTION FR_CLOSE_CHEK
	LPARAMETERS lFrPrint, lFrObj, lSumm
	
	local lTypeClose

	  * ���� lSumm = 0 ��������� ��� ����� ���������� �� ������� �����

	lTypeClose = 0 &&���������	  
	IF lSumm > 0
		lFrObj.summ = lSumm 	
		If lFrPrint.FR_Delivery(lFrObj,lTypeClose) <> 0 Then
			ERROR '������  CloseCheck '
		EndIf
	ELSE
		If lFrPrint.FR_CloseCheck(lFrObj,lTypeClose) <> 0 Then
			ERROR '������  CloseCheck '
		EndIf
	
	EndIF 


ENDFUNC


**************************************************
****X- �����
**************************************************

FUNCTION FR_X
	LPARAMETERS lFrPrint,lFrObj,lPassword   
	
	LOCAL lDevice, lPrint, lMode 
	  
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


**************************************************
****Z- �����
**************************************************

FUNCTION FR_Z
	LPARAMETERS lFrPrint,lFrObj,lPassword    
	
	LOCAL lDevice, lPrint , lSetMode  
**������-�� ������ FALSE ����� ��-�� ��������� ��			
*!*		IF !lFrObj.SessionOpened Then
*!*			messagebox('������ �������',64,'��������')	
*!*			return
*!*		ENDIF
*!*			

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


**************************************************
**** �������� ����������
**************************************************

FUNCTION FR_CashInc
	LPARAMETERS lFrPrint,lFrObj,lPassword, lSumm    
	
	LOCAL lDevice, lPrint , lSetMode  

	* �������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* ������������� ������
	lFrPrint.FR_Password(lFrObj, lPassword)
	
	 * ������ � ����� �������  � ��������
	lMode = 1
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR '������ ��������� ������ FR_SetMode(,1)'
	EndIF	
	lFrPrint.FR_CashIncome(lFrObj, lSumm) 
	
	* ����������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)
	
	
ENDFUN

**************************************************
**** ������ ����������
**************************************************
FUNCTION FR_CashOut 
	LPARAMETERS lFrPrint,lFrObj,lPassword, lSumm    
	
	LOCAL lDevice, lPrint , lSetMode  

	* �������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)

	* ������������� ������
	lFrPrint.FR_Password(lFrObj, lPassword)
	
	 * ������ � ����� �������  � ��������
	lMode = 1
	lSetMode = lFrPrint.FR_SetMode(lFrObj, lMode) 
	IF lSetMode <> 0
		ERROR '������ ��������� ������ FR_SetMode(,1)'
	EndIF	
	lFrPrint.FR_CashOutcome(lFrObj, lSumm) 
	
	* ����������� ����
	lDevice = lFrPrint.FR_DeviceEnabled(lFrObj)
	
	
ENDFUN

ENDDEFINE