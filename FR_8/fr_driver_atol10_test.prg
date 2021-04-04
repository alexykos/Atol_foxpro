fptr = CreateObject('AddIn.Fptr10')
*version = fptr.version()
SET STEP ON 

*!*	fptr.Open 
*!*	*'подключение к кассе 
*!*	MESSAGEBOX( fptr.errorDescription())

*!*	fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_X) 
*!*	fptr.Report 
*!*	fptr.Close 



*!*	****z-отчет Закрытие смены
*!*	fptr.Open 
*!*	    fptr.setParam(1021, 'Кассир Иванов И.')
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
***Формирование чека состоит из следующих операций:
***    открытие чека и передача реквизитов чека
***    регистрация позиций, печать нефискальных данных (текст, штрихкоды, изображения)
***    регистрация итога (необязательный пункт - если регистрацию итога не провести, он автоматически расчитается из суммы всех позиций)
***    регистрация налогов на чек (необязательный пункт - налоги могут быть подтянуты из позиций и суммированы)
***    регистрация оплат
***    закрытие чека
***    проверка состояния чека


******документ
fptr.Open 
isOpened = fptr.isOpened()
fptr.beep()
***#Кассир
fptr.setParam(1021, "Иванова И.И.")
fptr.operatorLogin()
***#Открытие печатного чека
***#Тип чека:Приход
fptr.setParam(fptr.LIBFPTR_PARAM_RECEIPT_TYPE, fptr.LIBFPTR_RT_SELL)
fptr.openReceipt()
***#Регистрация позиции без указания суммы налога
fptr.setParam(fptr.LIBFPTR_PARAM_COMMODITY_NAME, "Услуги общ.туалета")
fptr.setParam(fptr.LIBFPTR_PARAM_PRICE, 10)
fptr.setParam(fptr.LIBFPTR_PARAM_QUANTITY, 1)
fptr.setParam(fptr.LIBFPTR_PARAM_TAX_TYPE, fptr.LIBFPTR_TAX_VAT110)
fptr.setParam(fptr.LIBFPTR_PARAM_DEPARTMENT , 3 )
fptr.registration()
****#Оплата чека
fptr.setParam(fptr.LIBFPTR_PARAM_PAYMENT_TYPE, fptr.LIBFPTR_PT_CASH)
fptr.payment()
***#Регистрация налога на чек
fptr.setParam(fptr.LIBFPTR_PARAM_TAX_TYPE, fptr.LIBFPTR_TAX_VAT110)
fptr.receiptTax()
****#Регистрация итога чека
fptr.receiptTotal()
***#Закрытие полностью оплаченного чека
fptr.closeReceipt()
***#Бип
fptr.beep()
***#Завершение соединения с ККТ
fptr.close()










***Иъятие
*!*	fptr.Open 
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_SUM, [Сумма] * 1) 
*!*	fptr.cashOutcome
*!*	fptr.Close 

**Внесение
*!*	fptr.Open 
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_SUM, [Сумма] * 1) 
*!*	fptr.cashIncome 
*!*	fptr.Close

*!*	fptr.Open
*!*	 fptr.setParam(1021, 'Кассир Иванов И.')
*!*	    fptr.setParam(1203, '123456789047')
*!*	    fptr.operatorLogin

****z-отчет Закрытие смены
*!*	fptr.Open 
*!*	    fptr.setParam(1021, 'Кассир Иванов И.')
*!*	    fptr.setParam(1203, '123456789047')
*!*	    IF fptr.operatorLogin = -1
*!*	    	MESSAGEBOX( fptr.errorDescription())
*!*	    EndIF		

*!*	    fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_CLOSE_SHIFT)
*!*	    IF fptr.report = -1
*!*	    	MESSAGEBOX( fptr.errorDescription())
*!*	    EndIF	

*!*	    fptr.checkDocumentClosed
	

***Изъятие
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_SUM, 100.00)
*!*	fptr.cashOutcome
***  X-отчет
*!*	fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_X)
*!*	fptr.reportfptr.report

*MESSAGEBOX( version)

*fptr.close

*MESSAGEBOX( fptr.errorCode())