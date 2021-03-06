﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ИмяИБ = СтрокаСоединенияИнформационнойБазы();
	НаборКонстант.СВ_Сервер = "wss://1cdialog.com:443";
КонецПроцедуры

&НаКлиенте
Процедура НаборКонстантСВ_АдресЭлектроннойПочтыПриИзменении(Элемент)
	Элементы.Декорация1.Заголовок = СтрШаблон("Код придет на email ""%1""", НаборКонстант.СВ_АдресЭлектроннойПочты);
КонецПроцедуры

&НаКлиенте
Процедура Активировать(Команда)
	Записать();
	
	Если Не ЗначениеЗаполнено(КодАктивации) Тогда
		Пояснение = "Посте того как придет код активации на email " + НаборКонстант.СВ_АдресЭлектроннойПочты + " 
		|заполните поле ""Код активации"" и повторно нажмите кнопку ""Активировать""";
		ПоказатьПредупреждение(Новый ОписаниеОповещения("ПредупреждениеЗавершение", ЭтотОбъект), Пояснение,, "Информация");	
	КонецЕсли;
		
	Парам = Новый ПараметрыРегистрацииИнформационнойБазыСистемыВзаимодействия();
	Парам.ИмяИнформационнойБазы = СтрокаСоединенияИнформационнойБазы();
	Парам.АдресСервера = НаборКонстант.СВ_Сервер;
	Парам.АдресЭлектроннойПочты = НаборКонстант.СВ_АдресЭлектроннойПочты;
	Парам.КодАктивации = КодАктивации;
	
	ОО = Новый ОписаниеОповещения("ЗавершениеРегистрациюИнформационнойБазы", ЭтотОбъект);
	СистемаВзаимодействия.НачатьРегистрациюИнформационнойБазы(ОО, Парам);
КонецПроцедуры

&НаКлиенте
Процедура ПредупреждениеЗавершение(ДополнительныеПараметры) Экспорт

КонецПроцедуры

&НаКлиенте
Процедура Закрыть_(Команда)
	Оповестить("ОбновитьЭлементы");
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ОтменаАктивации(Команда)
	ОО = Новый ОписаниеОповещения("ЗавершениеОтменыРегистрацииИнформационнойБазы", ЭтотОбъект);
	СистемаВзаимодействия.НачатьОтменуРегистрацииИнформационнойБазы(ОО);
КонецПроцедуры

&НаКлиенте
Процедура ЗавершениеРегистрациюИнформационнойБазы(РегистрацияВыполнена, ТекстСообщения, ДополнительныеПараметры) Экспорт 
	ОбновитьЭлементы();
	Если РегистрацияВыполнена Тогда
		Оповестить("ОбновитьЭлементы");
		Закрыть();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗавершениеОтменыРегистрацииИнформационнойБазы(ДополнительныеПараметры) Экспорт 
	ОбновитьЭлементы();	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЭлементы()
	Элементы.ФормаАктивировать.Доступность = Не СистемаВзаимодействия.ИнформационнаяБазаЗарегистрирована();
	Элементы.ФормаОтменаАктивации.Доступность = Не Элементы.ФормаАктивировать.Доступность;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ОбновитьЭлементы()
КонецПроцедуры

