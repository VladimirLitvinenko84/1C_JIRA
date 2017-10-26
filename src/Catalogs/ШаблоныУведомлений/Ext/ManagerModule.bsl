﻿Функция ПолучитьВремТаблГрафика(УчитыватьКонечныеСтатусы) Экспорт 
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц();
	Запрос.Текст = "ВЫБРАТЬ
	               |	ИсторияИзмененияСтатусов.НомерЗадачи КАК НомерЗадачи,
	               |	ИсторияИзмененияСтатусов.ИсходныйСтатус КАК ИсходныйСтатус,
	               |	ИсторияИзмененияСтатусов.КонечныйСтатус КАК КонечныйСтатус,
	               |	ИсторияИзмененияСтатусов.ДатаСобытия КАК ДатаПереходаВКонечныйСтатус,
	               |	ДОБАВИТЬКДАТЕ(ИсторияИзмененияСтатусов.ДатаСобытия, МИНУТА, -ИсторияИзмененияСтатусов.МинутПробылВИсходномСтатусе) КАК ДатаПереходаВИсходныйСтатус,
	               |	Задачи.Исполнитель КАК Исполнитель,
	               |	Задачи.Статус КАК СтатусЗадачи
	               |ПОМЕСТИТЬ ДанныеИстории
	               |ИЗ
	               |	РегистрСведений.ИсторияИзмененияСтатусов КАК ИсторияИзмененияСтатусов
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Задачи КАК Задачи
	               |		ПО ИсторияИзмененияСтатусов.НомерЗадачи = Задачи.Номер
	               |ГДЕ
	               |	(НЕ &УчитыватьКонечныеСтатусы
	               |				И НЕ Задачи.Статус В (&КонечныеСтатусы)
	               |			ИЛИ &УчитыватьКонечныеСтатусы)
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	НомерЗадачи,
	               |	Исполнитель
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ЕСТЬNULL(ДанныеИстории.НомерЗадачи, Тмп.НомерЗадачи) КАК НомерЗадачи,
	               |	ЕСТЬNULL(ДанныеИстории.Исполнитель, Тмп.Исполнитель) КАК Исполнитель,
	               |	ВЫБОР
	               |		КОГДА ЕСТЬNULL(ДанныеИстории.КонечныйСтатус, Тмп.КонечныйСтатус) В (&КонечныеСтатусы)
	               |			ТОГДА ЕСТЬNULL(ДанныеИстории.ДатаПереходаВКонечныйСтатус, Тмп.ДатаПереходаВКонечныйСтатус)
	               |		ИНАЧЕ &ТекДата
	               |	КОНЕЦ КАК ДатаПереходаВКонечныйСтатус,
	               |	ВЫБОР
	               |		КОГДА ЕСТЬNULL(ДанныеИстории.КонечныйСтатус, Тмп.КонечныйСтатус) В (&КонечныеСтатусы)
	               |			ТОГДА ЕСТЬNULL(ДанныеИстории.ДатаПереходаВИсходныйСтатус, Тмп.ДатаПереходаВИсходныйСтатус)
	               |		ИНАЧЕ ЕСТЬNULL(ДанныеИстории.ДатаПереходаВКонечныйСтатус, Тмп.ДатаПереходаВКонечныйСтатус)
	               |	КОНЕЦ КАК ДатаПереходаВИсходныйСтатус,
	               |	ЕСТЬNULL(ДанныеИстории.ИсходныйСтатус, Тмп.ИсходныйСтатус) КАК ИсходныйСтатус,
	               |	ЕСТЬNULL(ДанныеИстории.КонечныйСтатус, Тмп.КонечныйСтатус) КАК КонечныйСтатус
	               |ПОМЕСТИТЬ ПослЗапись
	               |ИЗ
	               |	ДанныеИстории КАК Тмп
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	               |			МАКСИМУМ(гр.ДатаПереходаВКонечныйСтатус) КАК ДатаПереходаВКонечныйСтатус,
	               |			гр.НомерЗадачи КАК НомерЗадачи,
	               |			NULL КАК Исполнитель,
	               |			NULL КАК ИсходныйСтатус,
	               |			NULL КАК КонечныйСтатус,
	               |			ДАТАВРЕМЯ(1, 1, 1) КАК ДатаПереходаВИсходныйСтатус
	               |		ИЗ
	               |			ДанныеИстории КАК гр
	               |		
	               |		СГРУППИРОВАТЬ ПО
	               |			гр.НомерЗадачи) КАК ДанныеИстории
	               |		ПО Тмп.НомерЗадачи = ДанныеИстории.НомерЗадачи
	               |			И Тмп.ДатаПереходаВКонечныйСтатус = ДанныеИстории.ДатаПереходаВКонечныйСтатус
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ЕСТЬNULL(ДанныеИстории.НомерЗадачи, ПослЗапись.НомерЗадачи) КАК НомерЗадачи,
	               |	ЕСТЬNULL(ДанныеИстории.Исполнитель, ПослЗапись.Исполнитель) КАК Исполнитель,
	               |	ДанныеИстории.ИсходныйСтатус КАК ИсходныйСтатус,
	               |	ДанныеИстории.КонечныйСтатус КАК КонечныйСтатус,
	               |	ЕСТЬNULL(ДанныеИстории.ДатаПереходаВИсходныйСтатус, ПослЗапись.ДатаПереходаВИсходныйСтатус) КАК ДатаПереходаВИсходныйСтатус,
	               |	ЕСТЬNULL(ДанныеИстории.ДатаПереходаВКонечныйСтатус, ПослЗапись.ДатаПереходаВКонечныйСтатус) КАК ДатаПереходаВКонечныйСтатус
	               |ПОМЕСТИТЬ ДанныеИсторииОбработкаДатыЗакрытия
	               |ИЗ
	               |	ДанныеИстории КАК ДанныеИстории
	               |		ПОЛНОЕ СОЕДИНЕНИЕ ПослЗапись КАК ПослЗапись
	               |		ПО (ПослЗапись.НомерЗадачи = ДанныеИстории.НомерЗадачи)
	               |			И (ДанныеИстории.СтатусЗадачи В (&КонечныеСтатусы))
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ДанныеИстории.НомерЗадачи КАК НомерЗадачи,
	               |	ВЫБОР
	               |		КОГДА НАЧАЛОПЕРИОДА(ДанныеИстории.ДатаПереходаВИсходныйСтатус, ДЕНЬ) = НАЧАЛОПЕРИОДА(ДанныеИстории.ДатаПереходаВКонечныйСтатус, ДЕНЬ)
	               |			ТОГДА РАЗНОСТЬДАТ(ДанныеИстории.ДатаПереходаВИсходныйСтатус, ДанныеИстории.ДатаПереходаВКонечныйСтатус, МИНУТА) / 60
	               |		ИНАЧЕ ВЫБОР
	               |				КОГДА НАЧАЛОПЕРИОДА(ДанныеИстории.ДатаПереходаВИсходныйСтатус, ДЕНЬ) = ГрафикРаботы.Дата
	               |					ТОГДА ВЫБОР
	               |							КОГДА ДанныеИстории.ДатаПереходаВИсходныйСтатус < ДОБАВИТЬКДАТЕ(ГрафикРаботы.Дата, МИНУТА, (&СмещениеНаНачалаДня + &РабЧасов) * 60)
	               |								ТОГДА РАЗНОСТЬДАТ(ДанныеИстории.ДатаПереходаВИсходныйСтатус, ДОБАВИТЬКДАТЕ(ГрафикРаботы.Дата, МИНУТА, (&СмещениеНаНачалаДня + &РабЧасов) * 60), МИНУТА) / 60
	               |							ИНАЧЕ 0
	               |						КОНЕЦ
	               |				КОГДА НАЧАЛОПЕРИОДА(ДанныеИстории.ДатаПереходаВКонечныйСтатус, ДЕНЬ) = ГрафикРаботы.Дата
	               |					ТОГДА ВЫБОР
	               |							КОГДА ДанныеИстории.ДатаПереходаВКонечныйСтатус > ДОБАВИТЬКДАТЕ(ГрафикРаботы.Дата, МИНУТА, &СмещениеНаНачалаДня * 60)
	               |								ТОГДА РАЗНОСТЬДАТ(ДОБАВИТЬКДАТЕ(ГрафикРаботы.Дата, МИНУТА, &СмещениеНаНачалаДня * 60), ДанныеИстории.ДатаПереходаВКонечныйСтатус, МИНУТА) / 60
	               |							ИНАЧЕ 0
	               |						КОНЕЦ
	               |				ИНАЧЕ ГрафикРаботы.РабочихЧасов
	               |			КОНЕЦ
	               |	КОНЕЦ КАК РабЧасовВРаботе,
	               |	ДанныеИстории.ИсходныйСтатус КАК ИсходныйСтатус,
	               |	ДанныеИстории.КонечныйСтатус КАК КонечныйСтатус,
	               |	ДанныеИстории.ДатаПереходаВИсходныйСтатус КАК ДатаПереходаВИсходныйСтатус,
	               |	ДанныеИстории.ДатаПереходаВКонечныйСтатус КАК ДатаПереходаВКонечныйСтатус
	               |ПОМЕСТИТЬ ГруппировкаПоСтатусам
	               |ИЗ
	               |	ДанныеИсторииОбработкаДатыЗакрытия КАК ДанныеИстории
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ГрафикРаботы КАК ГрафикРаботы
	               |		ПО (НАЧАЛОПЕРИОДА(ДанныеИстории.ДатаПереходаВИсходныйСтатус, ДЕНЬ) <= ГрафикРаботы.Дата)
	               |			И ДанныеИстории.ДатаПереходаВКонечныйСтатус >= ГрафикРаботы.Дата
	               |			И ДанныеИстории.Исполнитель = ГрафикРаботы.Пользователь
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ГруппировкаПоСтатусам.НомерЗадачи КАК НомерЗадачи,
	               |	СУММА(ГруппировкаПоСтатусам.РабЧасовВРаботе) КАК РабЧасовВРаботе
	               |ПОМЕСТИТЬ График
	               |ИЗ
	               |	ГруппировкаПоСтатусам КАК ГруппировкаПоСтатусам
	               |ГДЕ
	               |	НЕ ЕСТЬNULL(ГруппировкаПоСтатусам.ИсходныйСтатус, """") В (&СтатусыИсключения)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ГруппировкаПоСтатусам.НомерЗадачи
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	ГруппировкаПоСтатусам.НомерЗадачи";
	
	РабЧасов = Константы.РабочийДень.Получить();
	РабЧасов = ?(РабЧасов = 0, 8, РабЧасов);
	Запрос.УстановитьПараметр("РабЧасов", РабЧасов + 1); // +1 - это с обедом

	Запрос.УстановитьПараметр("КонечныеСтатусы", СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ","));   
	Запрос.УстановитьПараметр("СтатусыИсключения", СтрРазделить("Закрыт,Сделан,Предоставлено ПР,Новый", ","));   
	Запрос.УстановитьПараметр("СмещениеНаНачалаДня", 9.5);
	Запрос.УстановитьПараметр("УчитыватьКонечныеСтатусы", УчитыватьКонечныеСтатусы);
	Запрос.УстановитьПараметр("ТекДата", ТекущаяДатаСеанса());
	
	Запрос.Выполнить();
	Возврат Запрос.МенеджерВременныхТаблиц;
КонецФункции


Функция ПолучитьЗадачиСрокВыполненияКоторыхБольшеЗапланированого() Экспорт 
	МВТ = ПолучитьВремТаблГрафика(Ложь);
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МВТ;
	Запрос.Текст = "ВЫБРАТЬ
	               |	График.РабЧасовВРаботе КАК ЧасовПробылВРаботе,
	               |	Задачи.Номер КАК Номер,
	               |	Задачи.НомерРодительскойЗадачи КАК НомерРодительскойЗадачи,
	               |	Задачи.Оценка КАК Оценка,
	               |	Задачи.ПлановаяДатаЗавершения КАК ПлановаяДатаЗавершения,
	               |	Задачи.Приоритет КАК Приоритет,
	               |	Задачи.ДатаСоздания КАК ДатаСоздания,
	               |	Задачи.Автор КАК Автор,
	               |	Задачи.Исполнитель КАК Исполнитель,
	               |	Задачи.Статус КАК Статус,
	               |	Задачи.Тип КАК Тип,
	               |	Задачи.ЭтоНовая КАК ЭтоНовая,
	               |	Задачи.Заголовок КАК Заголовок,
	               |	Задачи.Бюджет КАК Бюджет,
	               |	Задачи.ДатуЗавершенияУстановилАвтор КАК ДатуЗавершенияУстановилАвтор
	               |ИЗ
	               |	РегистрСведений.Задачи КАК Задачи
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ График КАК График
	               |		ПО Задачи.Номер = График.НомерЗадачи
	               |			И (Задачи.Оценка > 0)
	               |			И (График.РабЧасовВРаботе > Задачи.Оценка)
	               |		ПОЛНОЕ СОЕДИНЕНИЕ РегистрСведений.ЖурналОтправкиУведомлений КАК ЖурналОтправкиУведомлений
	               |		ПО Задачи.Номер = ЖурналОтправкиУведомлений.НомерЗадачи
	               |			И Задачи.Исполнитель = ЖурналОтправкиУведомлений.Получатель
	               |			И (ЖурналОтправкиУведомлений.ШаблонУведомления = ЗНАЧЕНИЕ(Справочник.ШаблоныУведомлений.ПривышенияВремениРаботыНадЗадачей))
	               |ГДЕ
	               |	ЖурналОтправкиУведомлений.НомерЗадачи ЕСТЬ NULL
	               |ИТОГИ ПО
	               |	Исполнитель";
		
 	Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
КонецФункции

Функция СписаноВремениБольшеЧемЗатрачено() Экспорт 
	МВТ = ПолучитьВремТаблГрафика(Ложь);

	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МВТ;
	Запрос.Текст = "ВЫБРАТЬ
	               |	СписаниеВремени.НомерЗадачи КАК НомерЗадачи,
	               |	СУММА(СписаниеВремени.Часы) КАК Часы
	               |ПОМЕСТИТЬ Табель
	               |ИЗ
	               |	РегистрСведений.СписаниеВремени КАК СписаниеВремени
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	СписаниеВремени.НомерЗадачи
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Табель.НомерЗадачи КАК НомерЗадачи,
	               |	Табель.Часы КАК Часы,
	               |	График.РабЧасовВРаботе КАК РабЧасовВРаботе
	               |ПОМЕСТИТЬ ИсторияИТабель
	               |ИЗ
	               |	График КАК График
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Табель КАК Табель
	               |		ПО График.НомерЗадачи = Табель.НомерЗадачи
	               |			И График.РабЧасовВРаботе < Табель.Часы
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	Задачи.Номер КАК Номер,
	               |	Задачи.НомерРодительскойЗадачи КАК НомерРодительскойЗадачи,
	               |	Задачи.Оценка КАК Оценка,
	               |	Задачи.ПлановаяДатаЗавершения КАК ПлановаяДатаЗавершения,
	               |	Задачи.Приоритет КАК Приоритет,
	               |	Задачи.ДатаСоздания КАК ДатаСоздания,
	               |	Задачи.Автор КАК Автор,
	               |	Задачи.Исполнитель КАК Исполнитель,
	               |	Задачи.Статус КАК Статус,
	               |	Задачи.Тип КАК Тип,
	               |	Задачи.ЭтоНовая КАК ЭтоНовая,
	               |	Задачи.Заголовок КАК Заголовок,
	               |	ИсторияИТабель.Часы КАК ЧасыТабеля,
	               |	ИсторияИТабель.РабЧасовВРаботе КАК ЧасовПробылВРаботе
	               |ИЗ
	               |	ИсторияИТабель КАК ИсторияИТабель
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.Задачи КАК Задачи
	               |			ПОЛНОЕ СОЕДИНЕНИЕ РегистрСведений.ЖурналОтправкиУведомлений КАК ЖурналОтправкиУведомлений
	               |			ПО Задачи.Номер = ЖурналОтправкиУведомлений.НомерЗадачи
	               |				И Задачи.Исполнитель = ЖурналОтправкиУведомлений.Получатель
	               |				И (ЖурналОтправкиУведомлений.ШаблонУведомления = ЗНАЧЕНИЕ(Справочник.ШаблоныУведомлений.СписаноВремениБольшеЧемЗатрачено))
	               |		ПО ИсторияИТабель.НомерЗадачи = Задачи.Номер
	               |ГДЕ
	               |	ЖурналОтправкиУведомлений.НомерЗадачи ЕСТЬ NULL
	               |ИТОГИ ПО
	               |	Исполнитель";	
	
	Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
КонецФункции

Функция СрокРешениеПоЗадачеИстек() Экспорт 
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Задачи.Номер КАК Номер,
	|	Задачи.НомерРодительскойЗадачи КАК НомерРодительскойЗадачи,
	|	Задачи.Оценка КАК Оценка,
	|	Задачи.ПлановаяДатаЗавершения КАК ПлановаяДатаЗавершения,
	|	Задачи.Приоритет КАК Приоритет,
	|	Задачи.ДатаСоздания КАК ДатаСоздания,
	|	Задачи.Автор КАК Автор,
	|	Задачи.Исполнитель КАК Исполнитель,
	|	Задачи.Статус КАК Статус,
	|	Задачи.Тип КАК Тип,
	|	Задачи.ЭтоНовая КАК ЭтоНовая,
	|	Задачи.Заголовок КАК Заголовок
	|ИЗ
	|	РегистрСведений.Задачи КАК Задачи
	|		ПОЛНОЕ СОЕДИНЕНИЕ РегистрСведений.ЖурналОтправкиУведомлений КАК ЖурналОтправкиУведомлений
	|		ПО Задачи.Номер = ЖурналОтправкиУведомлений.НомерЗадачи
	|			И Задачи.Автор = ЖурналОтправкиУведомлений.Получатель
	|			И (ЖурналОтправкиУведомлений.ШаблонУведомления = ЗНАЧЕНИЕ(Справочник.ШаблоныУведомлений.СрокРешениеПоЗадачеИстек))
	|ГДЕ
	|	Задачи.ПлановаяДатаЗавершения > ДАТАВРЕМЯ(1, 1, 1)
	|	И Задачи.ПлановаяДатаЗавершения < &ТекДата
	|	И НЕ Задачи.Статус В (&КонечныеСтатусы)
	|	И ЖурналОтправкиУведомлений.НомерЗадачи ЕСТЬ NULL
	|ИТОГИ ПО
	|	Автор";
	
	
	Запрос.УстановитьПараметр("ТекДата", ТекущаяДатаСеанса());
	Запрос.УстановитьПараметр("КонечныеСтатусы", СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ","));
	
	Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
КонецФункции
