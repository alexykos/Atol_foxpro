LOCAL lFrObj, lFrPrint, lPassword ,lSumm, lDevice, lMode, lSetMode, lPrint, lcQ
*SET STEP ON 

SET PROCEDURE TO FR_action_atol.prg additive

lPassword  = '30'
lSumm = 300


lFrPrint = createobject("FR_action_ATOL")



lFrObj = lFrPrint.FR_CreateObj()
IF VARTYPE(lFrObj) <> ''
	ERROR '������ ���������� ������ FR_CreateObj()'
EndIF	



lcQ = SYS(2015)
CREATE CURSOR (lcQ) (name c(200),price Y, quantity Y, Department I)

INSERT INTO (lcQ)(name ,price , quantity , Department) ;
VALUES('tovar 1', NTOM(100),NTOM(3),0)
INSERT INTO (lcQ)(name ,price , quantity , Department) ;
VALUES('tovar 2', NTOM(150),NTOM(2),0)

SELECT (lcQ)
*BROWSE norm


*MESSAGEBOX(lFrObj.SessionOpened)
*lFrPrint.FR_X(lFrPrint,lFrObj,lPassword)

*lFrPrint.FR_CHEK(lFrPrint,lFrObj,lPassword,lcQ,700)

*lFrPrint.FR_CashInc(lFrPrint,lFrObj,lPassword,lSumm ) 
*lFrPrint.FR_CashOut(lFrPrint,lFrObj,lPassword,lSumm ) 

*lFrPrint.FR_Z(lFrPrint,lFrObj,lPassword)

lFrObj = 0
RELEASE lFrPrint,lFrObj

