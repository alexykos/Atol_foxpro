

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
	**** ���
	**************************************************
	FUNCTION FR_BEGIN_DOC
		LPARAMETERS lFrObj,lPassword

		THIS.FR_log('FR_BEGIN_DOC')
		
		* �������� ����
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_BEGIN_DOC - FR_DeviceEnabled')
		EndIF
		* ������������� ������
		THIS.FR_Password(lFrObj, lPassword)

		 * ������ � ����� �����������
		lMode = 1
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode,'FR_BEGIN_DOC. ������ ��������� ������ FR_SetMode(,1)')
		EndIF	
		

	ENDFUNC

	****������ ���������
	FUNCTION FR_BODY_DOC
		LPARAMETERS lFrObj, lObjBody, lType_doc 

		*** lType_doc = 1 - ���
		*** lType_doc = 2 - �������
		*** lType_doc = 3 - ������������	
		
		LOCAL lResult	
		
		THIS.FR_log('FR_BODY_DOC')
		
		IF !INLIST(NVL(lType_doc,0),1,2)
			this.FR_error(lType_doc,'FR_BODY_DOC - ����������� ��� ��������� (lType_doc)')
		EndIF
		
		lFrObj.Name 		= lObjBody.Tovarname
		lFrObj.Price 		= lObjBody.price
		lFrObj.Quantity 	= lObjBody.quantity
		lFrObj.Department 	= lObjBody.Department
		***** ������������ ����� ��������� ������ 0- �� ������
		lFrObj.TaxTypeNumber = 0
		DO CASE 
			
			CASE lType_doc = 1 && �������
				lResult = lFrObj.Registration
				
				If lResult <> 0 Then
					this.FR_error(lResult,'FR_BODY_DOC - ������ Registration')
				ENDIF
			
			CASE lType_doc = 2 && �������
				lResult = lFrObj.Return
			
				If lResult <> 0 Then
					this.FR_error(lResult,'FR_BODY_DOC - ������ Return')
				ENDIF
		ENDCASE		

	ENDFUNC

	**** �������� ����
	FUNCTION FR_CLOSE_DOC
		LPARAMETERS lFrObj, lSumm, lType_doc, lType_tax, lcQPay

	
		local lTypeClose, lResult

		THIS.FR_log('FR_CLOSE_DOC')
		
		lFrObj.AttrNumber = 1055  
		lFrObj.AttrValue = lType_tax  
		lFrObj.WriteAttribute()  
		
		 * ���� lSumm = 0 ��������� ��� ����� ���������� �� ������� �����
		 * lType_doc = 1 - ���
		 * � ������ ��������������� ������ ������
		lTypeClose = 0 &&���������	  
		IF lSumm > 0 AND lType_doc = 1 AND reccount(lcQPay) = 0
			
			lFrObj.summ = lSumm 
			
			lResult = THIS.FR_Delivery(lFrObj,lTypeClose)	
			If lResult <> 0 Then
				this.FR_error(lResult,'FR_CLOSE_DOC - ������  FR_Delivery()')
			ENDIF
			
		ELSE
			*���� ���� ��������������� ������
			IF  reccount(lcQPay) > 0
				THIS.FR_PAYMENT_DOC(lFrObj, lcQPay)
			ELSE
				**������ ���������
				lFrObj.TypeClose = lTypeClose  	
			EndIF
			lResult = THIS.FR_CloseCheck(lFrObj) &&,lTypeClose
			If lResult <> 0 Then
				this.FR_error(lResult,'FR_CLOSE_DOC - ������ FR_CloseCheck()')
			ENDIF
			
		EndIF 

		RETURN lResult

	ENDFUNC
	
	****�������� ������ ��������� (��������������� ������)
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
				this.FR_error(lResult,'FR_PAYMENT_DOC - ������ PAYMENT() ')
			ENdIF		
		SKIP IN (lcQPay)
		ENDDO 
	
	ENDFUNC

	**** ������ ���������, ���� CheckState <> 0
	FUNCTION FR_CANCEL_DOC
		LPARAMETERS lFrObj
		
		local lResult, lDevice 
		
		THIS.FR_log('FR_CANCEL_DOC')
		
		* �������� ����
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CANCEL_DOC - FR_DeviceEnabled')
		EndIF
		
		*IF lFrObj.CheckState <> 0
			lResult = lFrObj.CancelCheck()
			IF lResult <> 0
				this.FR_error(lResult,'FR_CANCEL_DOC - ������ CancelCheck()')
			ENDIF	
		*EndIF		
		
		* ����������� ����
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CANCEL_DOC - FR_DeviceEnabled')
		EndIF

	ENDFUNC



	**************************************************
	****X- �����
	**************************************************

	FUNCTION FR_X
		LPARAMETERS lFrObj,lPassword   
		

		LOCAL lDevice, lPrint, lMode 
		 
		THIS.FR_log('FR_X')
		  
		* �������� ����
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_X - FR_DeviceEnabled')
		EndIF

		* ������������� ������
		THIS.FR_Password(lFrObj, lPassword)

		 * ������ � ����� ������� ��� �������
		lMode = 2
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode ,'FR_X - ������ ��������� ������ FR_SetMode(,'+ALLTRIM(STR(lMode)))
		EndIF	
		
		* X - �����
		lPrint = THIS.FR_Print_X(lFrObj)
		IF lPrint <> 0
			this.FR_error(lPrint,'FR_X - ������ FR_Print_X()')
		EndIF	 

		* ����������� ����
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_X - FR_DeviceEnabled')
		EndIF
	EndFun


	**************************************************
	****Z- �����
	**************************************************

	FUNCTION FR_Z
		LPARAMETERS lFrObj,lPassword    
		
		LOCAL lDevice, lPrint , lSetMode
		
		THIS.FR_log('FR_Z')  
			
	*!*		IF !lFrObj.SessionOpened Then
	*!*			messagebox('������ �������',64,'��������')	
	*!*			return
	*!*		ENDIF
	*!*			

		* �������� ����
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_Z - FR_DeviceEnabled')
		EndIF
		* ������������� ������
		THIS.FR_Password(lFrObj, lPassword)

		 * ������ � ����� �������  � ��������
		lMode = 3
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode ,'FR_Z - ������ ��������� ������ FR_SetMode(,'+ALLTRIM(STR(lMode)))
		EndIF	

		* Z - �����
		lPrint = THIS.FR_Print_Z(lFrObj)
		
		IF lPrint <> 0
			this.FR_error(lPrint ,'FR_Z - ������ FR_Print_Z')
		EndIF	 

		* ����������� ����
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_Z - FR_DeviceEnabled')
		EndIF

	ENDFUNC

	**************************************************
	****����� 
	*!*	������� ������ ������������� ���� �����(lMode)
	*!*	����� ������ ������� ��� �������.
	*!*	2.0 - ReportType = 2,7,8,9 � 11, 42 (������ ��� �������� �����)
	*!*	����� ������ ������� � ��������.
	*!*	3.0 - ReportType = 0,1,34 � 36
	*!*	����� ������� � ��.
	*!*	5.0 - ReportType = 3 � 6
	*!*	����� ������� � ����.
	*!*	6.0 - ReportType = 22 � 33   
	**************************************************

	FUNCTION FR_report
		LPARAMETERS lFrObj,lPassword, lTypeReport , lMode   
		
		LOCAL lDevice, lPrint   
		
		THIS.FR_log('FR_report')
		
		* �������� ����
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_report - FR_DeviceEnabled')
		EndIF

		* ������������� ������
		THIS.FR_Password(lFrObj, lPassword)

		 * ������ � ����� ������� 
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode ,'FR_report - ������ ��������� ������ FR_SetMode(,'+ALLTRIM(STR(lMode)))
		EndIF	

		* ����� � ����������� �� ����
		lPrint = THIS.FR_Print_type(lFrObj,lTypeReport)
		*MESSAGEBOX(lPrint)
		IF lPrint <> 0
			this.FR_error(lPrint,'FR_report - ������ FR_Print_type('+ALLTRIM(STR(lTypeReport)))
		EndIF	 

		* ����������� ����
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_report - FR_DeviceEnabled')
		EndIF

	ENDFUNC


	**************************************************
	**** �������� ����������
	**************************************************

	FUNCTION FR_CashInc
		LPARAMETERS lFrObj,lPassword, lSumm    
		
		LOCAL lDevice, lPrint , lSetMode ,lResult 
		
		THIS.FR_log('FR_CashInc')
		
		* �������� ����
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashInc - FR_DeviceEnabled')
		EndIF

		* ������������� ������
		THIS.FR_Password(lFrObj, lPassword)
		
		 * ������ � ����� �������  � ��������
		lMode = 1
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode,'FR_CashInc - ������ ��������� ������ FR_SetMode(,1)')
		EndIF	

		lResult = THIS.FR_CashIncome(lFrObj, lSumm) 
		IF lResult <> 0
			this.FR_error(lResult,'FR_CashInc - ������ FR_CashIncome')
		EndIF	
		
		* ����������� ����
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashInc - FR_DeviceEnabledFalse')
		EndIF
		
	ENDFUN

	**************************************************
	**** ������ ����������
	**************************************************
	FUNCTION FR_CashOut 
		LPARAMETERS lFrObj,lPassword, lSumm    
		
		LOCAL lDevice, lPrint , lSetMode , lResult  
		
		THIS.FR_log('FR_CashOut')
		
		* �������� ����
		lDevice = THIS.FR_DeviceEnabled(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashOut - FR_DeviceEnabled')
		EndIF

		* ������������� ������
		THIS.FR_Password(lFrObj, lPassword)
		
		 * ������ � ����� �������  � ��������
		lMode = 1
		lSetMode = THIS.FR_SetMode(lFrObj, lMode) 
		IF lSetMode <> 0
			this.FR_error(lSetMode,'FR_CashOut  - ������ ��������� ������ FR_SetMode(,1)')
		ENDIF
			
		lResult  = THIS.FR_CashOutcome(lFrObj, lSumm) 
		IF lResult <> 0
			*ERROR '������ FR_CashIncome' + ALLTRIM(STR(lResult))
			this.FR_error(lResult,'FR_CashOut  - ������ FR_CashIncome')
		EndIF	
		
		* ����������� ����
		lDevice = THIS.FR_DeviceEnabledFalse(lFrObj)
		IF lDevice <> 0
			this.FR_error(lDevice,'FR_CashOut - FR_DeviceEnabledFalse')
		EndIF
		
	ENDFUNC

	**************************************************
	**** ������ ������
	**************************************************
	FUNCTION FR_PrintString
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** ������ �����
	**************************************************
	FUNCTION FR_PrintHeader
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** ������ �������
	**************************************************
	FUNCTION FR_PrintFooter
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** ������ �� 
	**************************************************
	FUNCTION FR_PrintBarcode
		LPARAMETERS lFrObj
	ENDFUNC

	**************************************************
	**** ������ ����������� 
	**************************************************
	FUNCTION FR_PrintImage
		LPARAMETERS lFrObj
	ENDFUNC


	**************************************************
	**** ��������� ������
	**************************************************
	FUNCTION FR_error
		LPARAMETERS lResult, lCaption
		LOCAL lNameError
		
		lNameError = lCaption + ALLTR(STR(lResult))
		THIS.FR_log(lNameError)
		
		ERROR lNameError 
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
	 
		
	ENDFUN

ENDDEFINE