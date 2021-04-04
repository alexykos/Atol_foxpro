* �������� ����
  ECR.DeviceEnabled = .T.
  If ECR.ResultCode <> 0 Then
    Return
  EndIf

* �������� ��������� ���
  If ECR.GetStatus <> 0 Then
    Return
  EndIf

* ��������� �� ������ ������ ��� �� �������������������
  If ECR.Fiscal Then
    If MessageBox("��� ���������������! �� ������������� ������ ����������?", 32 + 4) = 7 Then
      Return
    EndIf
  EndIf

* ���� ���� �������� ���, �� �������� ���
  If ECR.CheckState <> 0 Then
    If ECR.CancelCheck <> 0 Then
      Return
    EndIf
  EndIf

* ���� ����� ������� ������� Z-�����
  If ECR.SessionOpened Then
    * ������������� ������ ���������� �������������� ���
    ECR.Password = "30"
    * ������ � ����� ������� � ��������
    ECR.Mode = 3
    If ECR.SetMode <> 0 Then
      Return
    EndIf
    * ������� �����
    ECR.ReportType = 1
    If ECR.Report <> 0 Then
      Return
    EndIf
  EndIf

* ������ � ����� �����������
  * ������������� ������ �������
  ECR.Password = "1"
  * ������ � ����� �����������
  ECR.Mode = 1
  If ECR.SetMode <> 0 Then
    Return
  EndIf

* ������� ��� �����
  * ����������� �������
  ECR.Name = "������"
  ECR.Price = 10.45
  ECR.Quantity = 1
  ECR.Department = 2
  If ECR.Registration <> 0 Then
    Return
  EndIf
  * ������ ������ �� ���������� �������
  ECR.Percents = 10
  ECR.Destination = 1
  If ECR.PercentsDiscount <> 0 Then
    Return
  EndIf
  * ����������� �������
  ECR.Name = "�����"
  ECR.Price = 25
  ECR.Quantity = 5
  ECR.Department = 1
  If ECR.Registration <> 0 Then
    Return
  EndIf
  * ������ ������ �� ���� ���
  ECR.Summ = 10.4
  ECR.Destination = 0
  If ECR.SummDiscount <> 0 Then
    Return
  EndIf
  * �������� ���� ��������� ��� ����� ���������� �� ������� �����
  ECR.TypeClose = 0
  If ECR.CloseCheck <> 0 Then
    Return
  EndIf

* ������� �� ������
  * ����������� �������
  ECR.Name = "������"
  ECR.Price = 10.45
  ECR.Quantity = 1
  ECR.Department = 2
  If ECR.Registration <> 0 Then
    Return
  EndIf
  * ����������� �������
  ECR.Name = "�����-����"
  ECR.Price = 25
  ECR.Quantity = 5
  ECR.Department = 1
  If ECR.Registration <> 0 Then
    Return
  EndIf
  * ������ ���������� �����������
  If ECR.Storno <> 0 Then
    Return
  EndIf
  * ����������� �������
  ECR.Name = "�����"
  ECR.Price = 25
  ECR.Quantity = 5
  ECR.Department = 1
  If ECR.Registration <> 0 Then
    Return
  EndIf
  * ������ ������ �� ���� ���
  ECR.Summ = 50
  ECR.Destination = 0
  If ECR.SummDiscount <> 0 Then
    Return
  EndIf
  * �������� ���� ��������� � ������ ���������� �� ������� �����
  ECR.Summ = 100
  ECR.TypeClose = 0
  If ECR.Delivery <> 0 Then
    Return
  EndIf

* �������������
  * ����������� �������������
  ECR.Name = "Dirol"
  ECR.Price = 7
  ECR.Quantity = 1
  If ECR.Annulate <> 0 Then
    Return
  EndIf
  * ����������� �������������
  ECR.Name = "Orbit"
  ECR.Price = 8
  ECR.Quantity = 2
  If ECR.Annulate <> 0 Then
    Return
  EndIf
  * �������� ����
  ECR.TypeClose = 0
  If ECR.CloseCheck <> 0 Then
    Return
  EndIf

* �������
  * ����������� ��������
  ECR.Name = "������"
  ECR.Price = 10.45
  ECR.Quantity = 1
  If ECR.Return <> 0 Then
    Return
  EndIf
  * ����������� ��������
  ECR.Name = "�������"
  ECR.Price = 99.99
  ECR.Quantity = 1.235
  If ECR.Return <> 0 Then
    Return
  EndIf
  * ������ ������ �� ���� ���
  ECR.Summ = 50
  ECR.Destination = 0
  If ECR.SummDiscount <> 0 Then
    Return
  EndIf
  * �������� ����
  ECR.TypeClose = 0
  If ECR.CloseCheck <> 0 Then
    Return
  EndIf

* �������� ����������
  ECR.Summ = 400.5
  If ECR.CashIncome <> 0 Then
    Return
  EndIf

* ������� ����������
  ECR.Summ = 121.34
  If ECR.CashOutcome <> 0 Then
    Return
  EndIf

* X - �����
  * ������������� ������ �������������� ���
  ECR.Password = "29"
  * ������ � ����� ������� ��� �������
  ECR.Mode = 2
  If ECR.SetMode <> 0 Then
    Return
  EndIf
  * ������� �����
  ECR.ReportType = 2
  If ECR.Report <> 0 Then
    Return
  EndIf

*!*	* Z - �����
*!*	  * ������������� ������ ���������� �������������� ���
*!*	  ECR.Password = "30"
*!*	  * ������ � ����� ������� � ��������
*!*	  ECR.Mode = 3
*!*	  If ECR.SetMode <> 0 Then
*!*	    Return
*!*	  EndIf
*!*	  * ������� �����
*!*	  ECR.ReportType = 1
*!*	  If ECR.Report <> 0 Then
*!*	    Return
*!*	  EndIf

* ������� � ����� ������, ����� ���-�� ��� ���������� �������� �� ������ ��� ������ ���������
  If ECR.ResetMode <> 0 Then
    Return
  EndIf

* ����������� ����
  ECR.DeviceEnabled = .F.
  If ECR.ResultCode <> 0 Then
    Return
  EndIf