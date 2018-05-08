﻿
Функция ПолучитьСписокЗадач(JQL, РасширеныеДанные = Ложь) Экспорт 
	//Если Не ОбщегоНазначенияСервер.ЗначениеЗаполнено(ОбщегоНазначенияСервер.ПолучитьЗначениеПараметраСеанса("JIRA_Cookies")) Тогда
	//	ВызватьИсключение "Необходимо авторизоваться в JIRA";		
	//КонецЕсли;
	
	// Смотреть коммиты
	// https://jira.bftcom.com/rest/gitplugin/1.0/issues/BU-13644/commits
	
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL"); 
	ДопПараметры = ?(РасширеныеДанные, "&expand=changelog", "");
	
	Ответ = Новый Массив();
	startIndex = 0;
	Пока Истина Цикл
		URL = СтрШаблон("%1/rest/api/2/search?jql=%2&startAt=%3%4", JIRA_URL, JQL, Формат(startIndex, "ЧГ="), ДопПараметры);      
		Результат = ВзаимодействиеC_JIRA_Сервер.ВыполнитьGETЗапрос(URL);	
		Если Не ЗначениеЗаполнено(Результат) Тогда
			Прервать;
		КонецЕсли;
		
		ЧтениеJSON = Новый ЧтениеJSON();
		ЧтениеJSON.УстановитьСтроку(Результат);
		ОтветОбъект = ПрочитатьJSON(ЧтениеJSON, Истина);                            
		ЧтениеJSON.Закрыть();
		МасивЗадач = ОтветОбъект["issues"];
		ЗадачВсего = ОтветОбъект["total"];
		ЗадачНаСтранице = ОтветОбъект["maxResults"];
		startIndex = startIndex + Число(ЗадачНаСтранице);
		
		Если МасивЗадач = Неопределено ИЛИ МасивЗадач.Количество() = 0 Тогда
			Прервать;	
		КонецЕсли;
		
		Для Каждого З Из МасивЗадач Цикл
			Ответ.Добавить(З);	
		КонецЦикла;
		
		Если Ответ.Количество() >= Число(ЗадачВсего) Тогда
			Прервать;	
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ответ;
КонецФункции

Функция ПолучитьКомментарииПоЗадаче(НомерЗадачи) Экспорт 
	#Если Клиент Тогда
		Состояние(СтрШаблон("Запрашиваем комментарии для задачи ""%1""", НомерЗадачи));
	#КонецЕсли

	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL"); 
	Результат = ВзаимодействиеC_JIRA_Сервер.ВыполнитьGETЗапрос(СтрШаблон("%1/rest/api/2/issue/%2/comment", JIRA_URL, НомерЗадачи));	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		ВызватьИсключение СтрШаблон("Не удалось получить комментарии по задаче ""%1""", НомерЗадачи);
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Результат);
	ОтветОбъект = ПрочитатьJSON(ЧтениеJSON, Истина);
	ЧтениеJSON.Закрыть();
	
	Возврат ОтветОбъект["comments"];
КонецФункции

Функция Авторизоваться() Экспорт   	
	Пользователь = Неопределено;
	Пароль = Неопределено;
	Ошибки = ОбщегоНазначенияСервер.ПроверкаЗаполненияНастроекJIRA(Пользователь, Пароль);
	Если ЗначениеЗаполнено(Ошибки) Тогда
		ВызватьИсключение СтрШаблон("При авторизации произошли ошибки:
		|%1", Ошибки);	
	КонецЕсли;
	
	URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL"); 	
	СтруктураТела = Новый Структура("username, password", Пользователь, Пароль);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " ", Истина);  
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	ЗаписатьJSON(ЗаписьJSON, СтруктураТела);           
	ДанныеJSON = ЗаписьJSON.Закрыть();
	
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL");
	URL = СтрШаблон("%1/rest/auth/1/session", JIRA_URL);
	Ответ = ВыполнитьPOSTЗапрос(URL, ДанныеJSON, Истина);
	
	Куки = Ответ.Заголовки["Set-Cookie"];
	ОбщегоНазначенияСервер.УстановитьЗначениеПараметраСеанса("JIRA_Cookies", Куки);
	 	
	Возврат Куки;
КонецФункции

Процедура ПринятьЗадачу(НомерЗадачи, ДанныеЗадачи) Экспорт 
	#Если Клиент Тогда
		Состояние("Устанавливаем статус ""Принят""");
	#КонецЕсли
			
	УстановитьСтатусЗадаче(НомерЗадачи, "Принят", ДанныеЗадачи);	
	
	//#Если Клиент Тогда
	//	Состояние("Устанавливаем статус ""В работе""");
	//#КонецЕсли
	//УстановитьСтатусЗадаче(НомерЗадачи, "В работе", Неопределено);	
КонецПроцедуры

Процедура ОбновитьДанныеСабтасков(РодительскаяЗадача, ДопДанные) Экспорт 
	Перем Оценка, ДатаЗавершения, Бюджет, Исполнитель, Версия;
	
	#Если Клиент Тогда
		Состояние("Устанавливаем время выполнения в сабтасках");
	#КонецЕсли
	
	Сабтаски = ПолучитьСабтаски(РодительскаяЗадача);
	Для Каждого Сабтаск Из Сабтаски Цикл
		ПоляЗадачи = Сабтаск["fields"];
		Тип = ПоляЗадачи["issuetype"]["name"];
		
		Если СтрЧислоВхождений(Тип, "Разработка") > 0 Тогда
			Если ДопДанные.Свойство("ДатыЗавершения") Тогда
				ДатаЗавершения = Формат(ДопДанные.ДатыЗавершения.ДатаЗавершенияРазработка, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300");
			КонецЕсли;
			Если ДопДанные.Свойство("Оценки") Тогда
				Оценка = ДопДанные.Оценки.Разработка;
				Оценка = ?(Оценка = Неопределено, ДопДанные.Оценки.Общая * ОбщегоНазначенияКлиентСервер.КоэффициентРазработки(), Оценка);
			КонецЕсли;
			Если ДопДанные.Свойство("Бюджеты") Тогда
				Бюджет = ДопДанные.Бюджеты.Разработка;
			КонецЕсли;
			Если ДопДанные.Свойство("Исполнители") Тогда
				Исполнитель = ДопДанные.Исполнители.Разработка;
			КонецЕсли;
		ИначеЕсли СтрЧислоВхождений(Тип, "Тестирование") > 0 Тогда
			Если ДопДанные.Свойство("ДатыЗавершения") Тогда
				ДатаЗавершения = Формат(ДопДанные.ДатыЗавершения.ДатаЗавершенияТестирование, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300");
			КонецЕсли;
			Если ДопДанные.Свойство("Оценки") Тогда
				Оценка = ДопДанные.Оценки.Тестирование;
				Оценка = ?(Оценка = Неопределено, ДопДанные.Оценки.Общая * ОбщегоНазначенияКлиентСервер.КоэффициентТестирования(), Оценка);
			КонецЕсли;
			Если ДопДанные.Свойство("Бюджеты") Тогда
				Бюджет = ДопДанные.Бюджеты.Тестирование;
			КонецЕсли;
			Если ДопДанные.Свойство("Исполнители") Тогда
				Исполнитель = ДопДанные.Исполнители.Тестирование;
			КонецЕсли;
		Иначе
			Продолжить;
		КонецЕсли;
		
		ДанныеПолей = Новый Структура();
		Если Оценка <> Неопределено Тогда
			ДанныеПолей.Вставить("timetracking", Новый Структура("originalEstimate", СтрШаблон("%1h", Оценка)));
		КонецЕсли;
		Если ДатаЗавершения <> Неопределено Тогда
			ДанныеПолей.Вставить("duedate", ДатаЗавершения);
		КонецЕсли;
		Если Бюджет <> Неопределено Тогда
			ДанныеПолей.Вставить(БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("Бюджет"), ВзаимодействиеC_JIRA_Сервер.ПолучитьДанныеБюджетаДляОтправки(Бюджет));
		КонецЕсли;
		Если Исполнитель <> Неопределено Тогда
			ДанныеПолей.Вставить("assignee", ВзаимодействиеC_JIRA_Сервер.ПолучитьДанныеПользователяДляОтправки(Исполнитель));
		КонецЕсли;
		
		ДопДанные.Свойство("Версия", Версия);
		Если ЗначениеЗаполнено(Версия) Тогда
			ДанныеПолей.Вставить("fixVersions", Новый Массив());
			id = ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Версия, "Код");
			ДанныеПолей.fixVersions.Добавить(Новый Структура("id", Формат(id, "ЧГ=")));
		КонецЕсли;

		ИзменитьПоляЗадачи(Сабтаск["key"], ДанныеПолей);
		ВзаимодействиеC_JIRA_Сервер.ОбновитьДанныеЗадач(Сабтаск["key"]);
	КонецЦикла;
КонецПроцедуры

Процедура УстановитьОценкуВыполненияИВремяЗадачи(НомерЗадачи, ДопДанные) Экспорт 
	#Если Клиент Тогда
		Состояние("Устанавливаем время выполнения в задаче " + НомерЗадачи);
	#КонецЕсли

	
	Если ДопДанные.Свойство("ДатыЗавершения") Тогда
		ДатаЗавершения = Формат(ДопДанные.ДатыЗавершения.ДатаЗавершенияОбщая, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300");
	КонецЕсли;
	Если ДопДанные.Свойство("Оценки") Тогда
		Оценка = ДопДанные.Оценки.Общая;
	КонецЕсли;
	Если ДопДанные.Свойство("Бюджеты") Тогда
		Бюджет = ДопДанные.Бюджеты.Общий;
	КонецЕсли;
	
	ДанныеПолей = Новый Структура();
	Если Оценка <> Неопределено Тогда
		ДанныеПолей.Вставить("timetracking", Новый Структура("originalEstimate", СтрШаблон("%1h", Оценка)));
	КонецЕсли;
	Если ДатаЗавершения <> Неопределено Тогда
		ДанныеПолей.Вставить("duedate", ДатаЗавершения);
	КонецЕсли;
	Если Бюджет <> Неопределено Тогда
		ДанныеПолей.Вставить(БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("Бюджет"), ВзаимодействиеC_JIRA_Сервер.ПолучитьДанныеБюджетаДляОтправки(Бюджет));
	КонецЕсли;
	
	ИзменитьПоляЗадачи(НомерЗадачи, ДанныеПолей);
	ВзаимодействиеC_JIRA_Сервер.ОбновитьДанныеЗадач(НомерЗадачи);
КонецПроцедуры

Функция ПолучитьСабтаски(НомерРодительскойЗадачи)
	JQL = СтрШаблон("parent = %1", НомерРодительскойЗадачи);
	Возврат ПолучитьСписокЗадач(JQL);
КонецФункции

Процедура ИзменитьДатуЗавершения(НомерЗадачи, НоваяДатаЗавершения, МенятьДатуВСвязанныхЗадачах) Экспорт 
	ДанныеПолей = Новый Структура("duedate", Формат(НоваяДатаЗавершения, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300"));
	ИзменитьПоляЗадачи(НомерЗадачи, ДанныеПолей);	
	Если МенятьДатуВСвязанныхЗадачах Тогда
		
		ДатыЗавершения = Новый Структура("ДатаЗавершенияОбщая,ДатаЗавершенияРазработка,ДатаЗавершенияТестирование");
		ДатыЗавершения.ДатаЗавершенияОбщая = НоваяДатаЗавершения;
		
		Разница = (НоваяДатаЗавершения - ТекущаяДата()); 
		ДатаЗавершенияРазработка = ТекущаяДата() + Разница * ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();

		
		ДатыЗавершения.ДатаЗавершенияРазработка = ДатаЗавершенияРазработка;
		ДатыЗавершения.ДатаЗавершенияТестирование = НоваяДатаЗавершения;
		Данные = Новый Структура("ДатыЗавершения", ДатыЗавершения);
				
		ОбновитьДанныеСабтасков(НомерЗадачи, Данные);
	КонецЕсли;
	
	ВзаимодействиеC_JIRA_Сервер.ОбновитьДанныеЗадач(НомерЗадачи);
КонецПроцедуры

Процедура ОткрытьЗадачуВБраузере(НомерЗадачи) Экспорт
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL"); 
	URL = СтрШаблон("%1/browse/%2", JIRA_URL, НомерЗадачи);
	Если ЗначениеЗаполнено(НомерЗадачи)  Тогда
		#Если Клиент Тогда
			НачатьЗапускПриложения(Новый ОписаниеОповещения("ОткрытьСписокВJIRAЗавершение", ЭтотОбъект), URL);	
		#Иначе
			ЗапуститьПриложение(URL);
		#КонецЕсли
	КонецЕсли;
КонецПроцедуры

Процедура ОткрытьСписокВJIRAЗавершение(КодВозврата, ДополнительныеПараметры) Экспорт
	
	
	
КонецПроцедуры

Функция ПолучитьДанныеПерехода(НомерЗадачи, ИмяСтатусаНазначения) Экспорт 
	#Если Клиент Тогда
		Состояние(СтрШаблон("Запрашиваем доп. данные для перехода в статус ""%1""", ИмяСтатусаНазначения));
	#КонецЕсли

	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL"); 
	Результат = ВзаимодействиеC_JIRA_Сервер.ВыполнитьGETЗапрос(СтрШаблон("%1/rest/api/2/issue/%2/transitions?expand=transitions.fields", JIRA_URL, НомерЗадачи));	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		ВызватьИсключение СтрШаблон("Не удалось получить список разрешенных переходов для задачи ""%1""", НомерЗадачи);
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Результат);
	ОтветОбъект = ПрочитатьJSON(ЧтениеJSON, Истина);
	ЧтениеJSON.Закрыть();
	
	Для Каждого Элемент Из ?(ОтветОбъект["transitions"] <> Неопределено, ОтветОбъект["transitions"], Новый Массив()) Цикл
		Если ВРег(Элемент["to"]["name"]) = ВРег(ИмяСтатусаНазначения) Тогда
			Возврат Элемент;
		КонецЕсли;
	КонецЦикла;
	
	ВызватьИсключение СтрШаблон("Не удалось установить статус ""%1"" для задачи ""%2"".
		|Данный переход не предусмотрен workflow", ИмяСтатусаНазначения, НомерЗадачи); 
КонецФункции

Процедура УстановитьСтатусЗадаче(НомерЗадачи, ИмяСтатуса, ДопДанные) Экспорт 
	Перем Бюджеты, ДопНастройки, Версия;
	
	ДанныеПерехода = ПолучитьДанныеПерехода(НомерЗадачи, ИмяСтатуса);
	СтруктураДанных = Новый Структура("transition", Новый Структура("id", ДанныеПерехода["id"]));
	
	// Пока такой костылек. ToDo, в будущем нужно вынести в настройки	
	Если ВРег(ИмяСтатуса) = "ПРИНЯТ" И ДопДанные <> Неопределено Тогда
		СтруктураДанных.Вставить("fields", Новый Структура("timetracking,duedate"));	// Поля необходимые при переходе в принят	
		СтруктураДанных.fields.Вставить(БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("Бюджет"), Неопределено);
		СтруктураДанных.fields.Вставить(БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("ДопНастройки"), Неопределено);
		СтруктураДанных.fields.timetracking = Новый Структура("originalEstimate", СтрШаблон("%1h", ДопДанные.Оценки.Общая));
		//СтруктураДанныхПолей.fields.timetracking.remainingEstimate = "2h"; 
		
		ДатаЗавершения = Формат(ДопДанные.ДатыЗавершения.ДатаЗавершенияОбщая, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300");
		СтруктураДанных.fields.duedate = ДатаЗавершения;
		
		Если Не ДопДанные.Свойство("Бюджеты", Бюджеты) Или Бюджеты = Неопределено Тогда
			ВызватьИсключение СтрШаблон("Не удалось перевести задачу ""%1"" в ""%2"", необходимо указать бюджет", НомерЗадачи, ИмяСтатуса); 
		КонецЕсли;
		
		Если ДопДанные.Свойство("ДопНастройки", ДопНастройки) И ДопНастройки <> Неопределено Тогда
			Значение = Новый Массив();
			Если ДопНастройки.НеСоздаватьАналитику Тогда
				Значение.Добавить(Новый Структура("value,id", "Аналитика", "22601")); // id - харкод
			КонецЕсли;
			Если ДопНастройки.НеСоздаватьДокументирование Тогда
				Значение.Добавить(Новый Структура("value,id", "Документирование", "22602")); // id - харкод
			КонецЕсли;
			СтруктураДанных.fields[БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("ДопНастройки")] = Значение;
		КонецЕсли;
		
		СтруктураДанных.fields[БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("Бюджет")] = ВзаимодействиеC_JIRA_Сервер.ПолучитьДанныеБюджетаДляОтправки(Бюджеты.Общий);  //Новый Структура("self,value,id", "https://jira.bftcom.com/rest/api/2/customFieldOption/20811", "[5508.АЦК-БУ.Общее сопровождение 2017].[7653] #7653", "20811");
	КонецЕсли;
	// КонецКостыля
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " ", Истина);  
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	ЗаписатьJSON(ЗаписьJSON, СтруктураДанных);           
	ДанныеJSON = ЗаписьJSON.Закрыть();
	
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL");
	URL = СтрШаблон("%1/rest/api/2/issue/%2/transitions", JIRA_URL, НомерЗадачи);
	
	#Если Клиент Тогда
		Состояние(СтрШаблон("Устанавливаем статус ""%1""", ИмяСтатуса));
	#КонецЕсли
	ВыполнитьPOSTЗапрос(URL, ДанныеJSON);
	
	
	#Если Клиент Тогда
		Состояние("Обновляем версию");
	#КонецЕсли

	ДопДанные.Свойство("Версия", Версия);
	Если ЗначениеЗаполнено(Версия) Тогда
		ДанныеВерсии = Новый Структура("fixVersions", Новый Массив());
		id = ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Версия, "Код");
		ДанныеВерсии.fixVersions.Добавить(Новый Структура("id", Формат(id, "ЧГ=")));
		ВзаимодействиеC_JIRA_КлиентСервер.ИзменитьПоляЗадачи(НомерЗадачи, ДанныеВерсии);
	КонецЕсли;

	#Если Клиент Тогда
		Состояние(СтрШаблон("Запрашиваем данные по задаче ""%1""", ИмяСтатуса));
	#КонецЕсли
	ВзаимодействиеC_JIRA_Сервер.ОбновитьДанныеЗадач(НомерЗадачи);
КонецПроцедуры

Функция ПолучитьЗадачиОбновленныеСегодня(РасширеныеДанные) Экспорт 
	СписокЗадач = ПолучитьСписокЗадач("project = BU AND updated >= -8h", РасширеныеДанные);
	Возврат СписокЗадач;
КонецФункции

Функция ПолучитьЛогСписанийПоЗадаче(НомерЗадачи) Экспорт 
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL");	
	URL = СтрШаблон("%1/rest/api/2/issue/%2/worklog", JIRA_URL, НомерЗадачи);      
	Результат = ВзаимодействиеC_JIRA_Сервер.ВыполнитьGETЗапрос(URL);	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		Возврат Новый Массив();
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Результат);
	ОтветОбъект = ПрочитатьJSON(ЧтениеJSON, Истина);                            
	ЧтениеJSON.Закрыть();
	
	Возврат ОтветОбъект["worklogs"];
КонецФункции

Функция ПолучитьЗадачиИСабтаскиСМетками(Метки) Экспорт 
	СписокЗадач = ПолучитьСписокЗадач(СтрШаблон("project = BU AND labels in (%1)", Метки));
	
	НомераЗадач = Новый Массив();
	Для Каждого Задача Из СписокЗадач Цикл
		ПоляЗадачи = Задача["fields"];
		НомераЗадач.Добавить(Задача["key"]);
		Для Каждого Сабтаск Из ПоляЗадачи["subtasks"] Цикл
			НомераЗадач.Добавить(Сабтаск["key"]);
		КонецЦикла;
	КонецЦикла;	
	
	Возврат НомераЗадач;	
КонецФункции


//Функция ПолучитьДатуЗавершения(Оценка)
//	ЧасовВРабДне = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("РабочийДень");
//	КолВоРабочихДней = Окр(Оценка / ЧасовВРабДне, 0, РежимОкругления.Окр15как20) + 1; // 1 это на всякий случай

//	Возврат Формат(ТекущаяДата() + (КолВоРабочихДней * 24 * 60 * 60), "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300");
//КонецФункции

Процедура ИзменитьПоляЗадачи(НомерЗадачи, ДанныеПолей) Экспорт 
	
	#Если Клиент Тогда
		Состояние("Изменяем данные задачи " + НомерЗадачи);
	#КонецЕсли

	
	СтруктураДанных = Новый Структура("fields", ДанныеПолей); 
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " ", Истина);  
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	ЗаписатьJSON(ЗаписьJSON, СтруктураДанных);           
	ДанныеJSON = ЗаписьJSON.Закрыть();

	
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL");
	URL = СтрШаблон("%1/rest/api/2/issue/%2", JIRA_URL, НомерЗадачи);
	ВыполнитьPUTЗапрос(URL, ДанныеJSON);
	
	ВзаимодействиеC_JIRA_Сервер.ОбновитьДанныеЗадач(НомерЗадачи);
КонецПроцедуры

#Область РаботаСВерсиями

Процедура ИзменитьДанныеВерсии(id_версии, ИмяВерсии, ДанныеПолей, ОбновлятьДанныеЗадачи = Истина) Экспорт 
	
	#Если Клиент Тогда
		Состояние("Изменяем данные версии " + ИмяВерсии);
	#КонецЕсли
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " ", Истина);  
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	ЗаписатьJSON(ЗаписьJSON, ДанныеПолей);           
	ДанныеJSON = ЗаписьJSON.Закрыть();

	
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL");
	URL = СтрШаблон("%1/rest/api/2/version/%2?expand", JIRA_URL, id_версии);
	ВыполнитьPUTЗапрос(URL, ДанныеJSON);
	
	Если ОбновлятьДанныеЗадачи Тогда
		ВзаимодействиеC_JIRA_Сервер.ОбновитьВерсию(id_версии);
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьСписокВерсий() Экспорт 
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL"); 
	URL = СтрШаблон("%1/rest/api/2/project/BU/versions", JIRA_URL);      
	
	Результат = ВзаимодействиеC_JIRA_Сервер.ВыполнитьGETЗапрос(URL);
	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Результат);
	ОтветОбъект = ПрочитатьJSON(ЧтениеJSON, Истина);                            
	ЧтениеJSON.Закрыть();
	
	Возврат ОтветОбъект;
КонецФункции

Процедура СоздатьВерсию(ИмяВерсии, ДатаНачала, ДатаОкончания) Экспорт 
	#Если Клиент Тогда
		Состояние("Создаем версию " + ИмяВерсии);
	#КонецЕсли
	
	СтруктураДанных = Новый Структура();
	СтруктураДанных.Вставить("name", ИмяВерсии);
	СтруктураДанных.Вставить("archived", Ложь);
	СтруктураДанных.Вставить("released", Ложь);
	СтруктураДанных.Вставить("releaseDate", Формат(ДатаОкончания, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300"));
	СтруктураДанных.Вставить("startDate", Формат(ДатаНачала, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300"));
	СтруктураДанных.Вставить("project", "BU");
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " ", Истина);  
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	ЗаписатьJSON(ЗаписьJSON, СтруктураДанных);           
	ДанныеJSON = ЗаписьJSON.Закрыть();
	
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL");
	URL = СтрШаблон("%1/rest/api/2/version", JIRA_URL);
	ВыполнитьPOSTЗапрос(URL, ДанныеJSON);
КонецПроцедуры

Функция ПолучитьДанныеВерсии(id) Экспорт 
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL"); 
	URL = СтрШаблон("%1/rest/api/2/version/%2", JIRA_URL, Формат(id, "ЧГ="));      
	
	Результат = ВзаимодействиеC_JIRA_Сервер.ВыполнитьGETЗапрос(URL);
	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Результат);
	ДанныеВерсии = ПрочитатьJSON(ЧтениеJSON, Истина);                            
	ЧтениеJSON.Закрыть();
	
	Возврат ДанныеВерсии;
КонецФункции


#КонецОбласти

Процедура СписатьВремя(НомерЗадачи, ДанныеПолей) Экспорт 
	ЗаписьJSON = Новый ЗаписьJSON;
	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " ", Истина);  
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);
	ЗаписатьJSON(ЗаписьJSON, ДанныеПолей);           
	ДанныеJSON = ЗаписьJSON.Закрыть();
	
	JIRA_URL = ОбщегоНазначенияСервер.ПолучитьЗначениеКонстанты("JIRA_URL");
	
	URL = СтрШаблон("%1/rest/api/2/issue/%2/worklog?adjustEstimate=new&newEstimate=0m", JIRA_URL, НомерЗадачи);
	ВыполнитьPOSTЗапрос(URL, ДанныеJSON);
КонецПроцедуры


#region РаботаС_HTTP

Функция ПолучитьЗаголовки() Экспорт 
	Заголовки = Новый Соответствие();
	//Заголовки.Вставить("Connection", "keep-alive");
	//Заголовки.Вставить("Content-type", "application/x-www-form-urlencoded;charset=utf-8");
	Заголовки.Вставить("Content-type", "application/json;charset=utf-8");
	//Заголовки.Вставить("Accept", "application/json, text/javascript, */*; q=0.01");
	//Заголовки.Вставить("Accept-Language", "Accept-Encoding	gzip, deflate");
	//Заголовки.Вставить("X-Requested-With", "XMLHttpRequest");
	//Заголовки.Вставить("Content-Length", "59");
	
	Возврат Заголовки;
КонецФункции

Функция ПолучитьPOSTЗаголовки()
	Заголовки = Новый Соответствие();
	Заголовки.Вставить("Connection", "keep-alive");
	Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	Заголовки.Вставить("Accept", "text/html, */*; q=0.01");
	Заголовки.Вставить("Accept-Language", "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3");
	Заголовки.Вставить("X-Requested-With", "XMLHttpRequest");
	Заголовки.Вставить("Referer", "https://jira.bftcom.com/browse/BU-9875");
	Заголовки.Вставить("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/54.0");
	Заголовки.Вставить("Accept-Encoding", "gzip, deflate, br");
	
	Возврат Заголовки;
КонецФункции

Процедура ВыполнитьPUTЗапрос(URL, ДанныеJSON)
	Куки =  ОбщегоНазначенияСервер.ПолучитьЗначениеПараметраСеанса("JIRA_Cookies");
	Если Не ЗначениеЗаполнено(Куки) Тогда
		Куки = Авторизоваться();
	КонецЕсли;
	
	Заголовки = ПолучитьЗаголовки();
  Заголовки.Вставить("Cookie", Куки); 
	
	СтруктураURI = ОбщегоНазначенияКлиентСервер.СтруктураURI(URL);
	
	Прокси = Новый ИнтернетПрокси(Истина);
	ssl = Новый ЗащищенноеСоединениеOpenSSL();
	//ssl = Новый ЗащищенноеСоединениеOpenSSL(
	//Новый СертификатКлиентаWindows(СпособВыбораСертификатаWindows.Авто),
	//Новый СертификатыУдостоверяющихЦентровWindows());
	
	HTTPСоединение = Новый HTTPСоединение(СтруктураURI.Хост,,,,,, ssl);
	HTTPЗапрос = Новый HTTPЗапрос(СтруктураURI.ПутьНаСервере, Заголовки);      
	HTTPЗапрос.УстановитьТелоИзСтроки(ДанныеJSON, КодировкаТекста.UTF8, ИспользованиеByteOrderMark.НеИспользовать);
	
	ФайлОтвет = ПолучитьИмяВременногоФайла();
	Попытка
		Ответ = HTTPСоединение.ВызватьHTTPМетод("PUT", HTTPЗапрос, ФайлОтвет); 
		Если Ответ.КодСостояния <> 200 И Ответ.КодСостояния <> 204 Тогда 
			АнализФайлаОтвета(ФайлОтвет, Ответ.КодСостояния);  // Эта пляска из-за ассинхронных методов
		КонецЕсли;	
		
		ОбщегоНазначенияКлиентСервер.УдалитьФайлыКлиентСервер(ФайлОтвет);
	Исключение
		ОбщегоНазначенияКлиентСервер.УдалитьФайлыКлиентСервер(ФайлОтвет);
		ВызватьИсключение;
	КонецПопытки;	
КонецПроцедуры

Функция ВыполнитьPOSTЗапрос(URL, ДанныеJSON, ЭтоЗапросАвторизации = Ложь)
	Куки =  ОбщегоНазначенияСервер.ПолучитьЗначениеПараметраСеанса("JIRA_Cookies");
	Если Не ЗначениеЗаполнено(Куки) И Не ЭтоЗапросАвторизации Тогда
		Куки = Авторизоваться();
	КонецЕсли;
	
	Заголовки = ПолучитьЗаголовки();
  Заголовки.Вставить("Cookie", Куки); 
	
	СтруктураURI = ОбщегоНазначенияКлиентСервер.СтруктураURI(URL);
	
	Прокси = Новый ИнтернетПрокси(Истина);
	ssl = Новый ЗащищенноеСоединениеOpenSSL();
	//ssl = Новый ЗащищенноеСоединениеOpenSSL(
	//Новый СертификатКлиентаWindows(СпособВыбораСертификатаWindows.Авто),
	//Новый СертификатыУдостоверяющихЦентровWindows());
	
	HTTPСоединение = Новый HTTPСоединение(СтруктураURI.Хост,,,,,, ssl);
	HTTPЗапрос = Новый HTTPЗапрос(СтруктураURI.ПутьНаСервере, Заголовки);      
	HTTPЗапрос.УстановитьТелоИзСтроки(ДанныеJSON, КодировкаТекста.UTF8, ИспользованиеByteOrderMark.НеИспользовать);
	
	ФайлОтвет = ПолучитьИмяВременногоФайла();
	Попытка
		Ответ = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос, ФайлОтвет);
		Если Ответ.КодСостояния <> 200 И Ответ.КодСостояния <> 204 И Ответ.КодСостояния <> 201 Тогда 
			// Эта пляска из-за ассинхронных методов
			АнализФайлаОтвета(ФайлОтвет, Ответ.КодСостояния);
		КонецЕсли;	
		
		ОбщегоНазначенияКлиентСервер.УдалитьФайлыКлиентСервер(ФайлОтвет);
		Возврат Ответ;
	Исключение
		ОбщегоНазначенияКлиентСервер.УдалитьФайлыКлиентСервер(ФайлОтвет);
		ВызватьИсключение;
	КонецПопытки;
КонецФункции


#endregion

Процедура АнализФайлаОтвета(ФайлОтвет, КодСостояния)
	#Если Клиент Тогда
		ДД = Новый Структура("КодСостояния", КодСостояния);
		НачатьПомещениеФайла(Новый ОписаниеОповещения("ЗавершениеПомещениеФайла", ЭтотОбъект, ДД), "", ФайлОтвет, Ложь, Новый УникальныйИдентификатор());
	#Иначе
		ВзаимодействиеC_JIRA_Сервер.АнализФайлаОтвета(Неопределено, ФайлОтвет, КодСостояния);
	#КонецЕсли
КонецПроцедуры

Процедура ЗавершениеПомещениеФайла(Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт 
	Если Результат Тогда
		ВзаимодействиеC_JIRA_Сервер.АнализФайлаОтвета(Адрес, Неопределено, ДополнительныеПараметры.КодСостояния);	
	КонецЕсли;
КонецПроцедуры

Функция ПреобразоватьВДату(Знач ДатаСтрокой) Экспорт 
	ПозицияТочки = СтрНайти(ДатаСтрокой, ".");
	Если ПозицияТочки > 0 Тогда
		ДатаСтрокой = Лев(ДатаСтрокой, СтрНайти(ДатаСтрокой, ".")-1)
	КонецЕсли;
	
	Возврат ?(ДатаСтрокой = Неопределено, Дата("00010101"), XMLЗначение(Тип("Дата"), ДатаСтрокой));
КонецФункции


