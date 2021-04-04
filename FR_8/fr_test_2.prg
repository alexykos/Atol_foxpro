

lcQPay = SYS(2015)
CREATE CURSOR (lcQPay) (type i,summ Y)

INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(1, NTOM(50))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(2, NTOM(40))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(3, NTOM(20))
INSERT INTO (lcQPay)(type ,summ ) ;
VALUES(4, NTOM(10))



  ECR = CreateObject("AddIn.FprnM45") 
  
* �������� ����
  ECR.DeviceEnabled = .T.
  If ECR.ResultCode <> 0 Then
    Return
  ENDIF
  
  * ���� ���� �������� ���, �� �������� ���
  If ECR.CheckState <> 0 Then
    If ECR.CancelCheck <> 0 Then
      Return
    EndIf
  ENDIF
  
  ECR.NewDocument() 

* ������ � ����� �����������
  * ������������� ������ �������
  ECR.Password = "1"
  * ������ � ����� �����������
  ECR.Mode = 1
  If ECR.SetMode <> 0 Then
    Return
  EndIf


  ECR.AttrNumber = 1021  
  ECR.AttrValue = "����� ������� �� �� ������ �.�."  
  ECR.WriteAttribute()  

ECR.CheckType = 1  
  *!*	  // CheckMode - ����� ������������ ����:  
  *!*	  // 	0 - ������ � ����������� ���� ��� ������ �� ������� �����  
  *!*	  // 	1 - �������� �� ������� �����  
  ECR.CheckMode = 1  
  ECR.OpenCheck()  
    
  *!*	  // ����������� ������� ��������������� � ����:  
  *!*	  // 	��� - 1  
  *!*	  // 	��� ����� - 2  
  *!*	  // 	��� �����-������ - 4  
  *!*	  // 	���� - 8  
  *!*	  // 	��� - 16  
  *!*	  // 	��� - 32  
  ECR.AttrNumber = 1055  
  ECR.AttrValue = 4  
  ECR.WriteAttribute()  



* ������� ��� �����
  * ����������� �������
  ECR.Name = "������"
  ECR.Price = 20
  ECR.Quantity = 1
  ECR.Department = 2
  If ECR.Registration <> 0 Then
    Return
  EndIf





 ECR.AttrNumber = 1055  
  ECR.AttrValue = 1  
  ECR.WriteAttribute()  
  
  * ����������� �������
  ECR.Name = "�����"
  ECR.Price = 20
  ECR.Quantity = 5
  ECR.Department = 1
  If ECR.Registration <> 0 Then
    Return
  EndIf

 ECR.AttrNumber = 1055  
  ECR.AttrValue = 4  
  ECR.WriteAttribute()  

  * �������� ���� ��������� ��� ����� ���������� �� ������� �����
 
 SELECT (lcQPay)
 GO TOP 
 DO WHILE !EOF(lcQPay)
 	ECR.SUMM 		= EVALUATE(lcQPay + '.summ')
	ECR.TypeClose 	= EVALUATE(lcQPay + '.type')
	ECR.PAYMENT()
 SKIP IN (lcQPay)
 ENDDO 
  
  
  If ECR.CloseCheck <> 0 Then
    Return
  ENDIF
  
  * ������� � ����� ������, ����� ���-�� ��� ���������� �������� �� ������ ��� ������ ���������
  If ECR.ResetMode <> 0 Then
    Return
  EndIf
  
  * ����������� ����
  ECR.DeviceEnabled = .F.
  If ECR.ResultCode <> 0 Then
    Return
  EndIf