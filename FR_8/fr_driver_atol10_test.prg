fptr = CreateObject('AddIn.Fptr10')
*version = fptr.version()
SET STEP ON 

*!*	fptr.Open 
*!*	*'����������� � ����� 
*!*	MESSAGEBOX( fptr.errorDescription())

*!*	fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_X) 
*!*	fptr.Report 
*!*	fptr.Close 



*!*	****z-����� �������� �����
*!*	fptr.Open 
*!*	    fptr.setParam(1021, '������ ������ �.')
*!*	    fptr.setParam(1203, '123456789047')
*!*	    IF fptr.operatorLogin = -1
*!*	    	MESSAGEBOX( fptr.errorDescription())
*!*	    EndIF		

*!*	    fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_CLOSE_SHIFT)
*!*	    IF fptr.report = -1
*!*	    	MESSAGEBOX( fptr.errorDescription())
*!*	    EndIF	

*!*	    fptr.checkDocumentClosed
*!*		

*!*	return
***������������ ���� ������� �� ��������� ��������:
***    �������� ���� � �������� ���������� ����
***    ����������� �������, ������ ������������ ������ (�����, ���������, �����������)
***    ����������� ����� (�������������� ����� - ���� ����������� ����� �� ��������, �� ������������� ����������� �� ����� ���� �������)
***    ����������� ������� �� ��� (�������������� ����� - ������ ����� ���� ��������� �� ������� � �����������)
***    ����������� �����
***    �������� ����
***    �������� ��������� ����


******��������
fptr.Open 
isOpened = fptr.isOpened()
fptr.beep()
***#������
fptr.setParam(1021, "������� �.�.")
fptr.operatorLogin()
***#�������� ��������� ����
***#��� ����:������
fptr.setParam(fptr.LIBFPTR_PARAM_RECEIPT_TYPE, fptr.LIBFPTR_RT_SELL)
fptr.openReceipt()
***#����������� ������� ��� �������� ����� ������
fptr.setParam(fptr.LIBFPTR_PARAM_COMMODITY_NAME, "������ ���.�������")
fptr.setParam(fptr.LIBFPTR_PARAM_PRICE, 10)
fptr.setParam(fptr.LIBFPTR_PARAM_QUANTITY, 1)
fptr.setParam(fptr.LIBFPTR_PARAM_TAX_TYPE, fptr.LIBFPTR_TAX_VAT110)
fptr.setParam(fptr.LIBFPTR_PARAM_DEPARTMENT , 3 )
fptr.registration()
****#������ ����
fptr.setParam(fptr.LIBFPTR_PARAM_PAYMENT_TYPE, fptr.LIBFPTR_PT_CASH)
fptr.payment()
***#����������� ������ �� ���
fptr.setParam(fptr.LIBFPTR_PARAM_TAX_TYPE, fptr.LIBFPTR_TAX_VAT110)
fptr.receiptTax()
****#����������� ����� ����
fptr.receiptTotal()
***#�������� ��������� ����������� ����
fptr.closeReceipt()
***#���
fptr.beep()
***#���������� ���������� � ���
fptr.close()










***������
*!*	fptr.Open 
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_SUM, [�����] * 1) 
*!*	fptr.cashOutcome
*!*	fptr.Close 

**��������
*!*	fptr.Open 
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_SUM, [�����] * 1) 
*!*	fptr.cashIncome 
*!*	fptr.Close

*!*	fptr.Open
*!*	 fptr.setParam(1021, '������ ������ �.')
*!*	    fptr.setParam(1203, '123456789047')
*!*	    fptr.operatorLogin

****z-����� �������� �����
*!*	fptr.Open 
*!*	    fptr.setParam(1021, '������ ������ �.')
*!*	    fptr.setParam(1203, '123456789047')
*!*	    IF fptr.operatorLogin = -1
*!*	    	MESSAGEBOX( fptr.errorDescription())
*!*	    EndIF		

*!*	    fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_CLOSE_SHIFT)
*!*	    IF fptr.report = -1
*!*	    	MESSAGEBOX( fptr.errorDescription())
*!*	    EndIF	

*!*	    fptr.checkDocumentClosed
	

***�������
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_SUM, 100.00)
*!*	fptr.cashOutcome
***  X-�����
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_X)
*!*	fptr.reportfptr.report

*MESSAGEBOX( version)

*fptr.close

*MESSAGEBOX( fptr.errorCode())