﻿
#region РаботаС_HTTP


Функция ВыполнитьGETЗапрос(URL, ВернутьДвоичныеДанные = Ложь)  Экспорт 
	Перем ssl;
	
	СтруктураURI = ОбщегоНазначенияКлиентСервер.СтруктураURI(URL);
	Куки =  ОбщегоНазначенияСервер.ПолучитьЗначениеПараметраСеанса("JIRA_Cookies");
	Если Не ЗначениеЗаполнено(Куки) Тогда
		Куки = ВзаимодействиеC_JIRA_КлиентСервер.Авторизоваться();
	КонецЕсли;
	
	Заголовки = ВзаимодействиеC_JIRA_КлиентСервер.ПолучитьЗаголовки();
	Заголовки.Вставить("Cookie", Куки);
	
	Если ВРег(СтруктураURI.Схема) = "HTTPS" Тогда
		ssl = Новый ЗащищенноеСоединениеOpenSSL();
	КонецЕсли;
	
	Тело = "";
	ДД = Неопределено;
	ФайлОтвет = ПолучитьИмяВременногоФайла();
	Попытка                                                             
		HTTPСоединение = Новый HTTPСоединение(СтруктураURI.ИмяСервера,,,,,, ssl);
		HTTPЗапрос = Новый HTTPЗапрос(СтруктураURI.ПутьНаСервере, Заголовки);
		Ответ = HTTPСоединение.Получить(HTTPЗапрос, ФайлОтвет);  
		
		Если Ответ.КодСостояния = 200 Тогда 
			Если Не ВернутьДвоичныеДанные Тогда
				HTMLФайл = Новый ТекстовыйДокумент();
				HTMLФайл.Прочитать(ФайлОтвет, КодировкаТекста.UTF8);			
				Тело = HTMLФайл.ПолучитьТекст(); 
			Иначе
				ДД = Новый ДвоичныеДанные(ФайлОтвет);
			КонецЕсли;
		Иначе
			АнализФайлаОтвета(Неопределено, ФайлОтвет, Ответ.КодСостояния);
		КонецЕсли;
		
		УдалитьФайлы(ФайлОтвет);
	Исключение
		УдалитьФайлы(ФайлОтвет);
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат ?(ВернутьДвоичныеДанные, ДД, Тело);
КонецФункции

#endregion


Процедура АнализФайлаОтвета(АдресХранилища, ПутьНаСервере, КодСостояния) Экспорт 
	ФайлОтвет = ?(ПутьНаСервере = Неопределено, ПолучитьИмяВременногоФайла(), ПутьНаСервере);
	Попытка
		Если АдресХранилища <> Неопределено Тогда
			ДД = ПолучитьИзВременногоХранилища(АдресХранилища);
			ДД.Записать(ФайлОтвет);
		КонецЕсли;
		
		ТекстовыйДокумент = Новый ТекстовыйДокумент();
		ТекстовыйДокумент.Прочитать(ФайлОтвет, КодировкаТекста.UTF8);
		Тело = ТекстовыйДокумент.ПолучитьТекст(); 
		Если Не ЗначениеЗаполнено(Тело) Тогда
			ВызватьИсключение СтрШаблон("Код ответа ""%1"". Не удалось определить ошибку, файл ответа пуст.", КодСостояния);	
		КонецЕсли;
		
		ЧтениеJSON = Новый ЧтениеJSON();
		ЧтениеJSON.УстановитьСтроку(Тело);
		ОтветОбъект = ПрочитатьJSON(ЧтениеJSON, Истина);
		ЧтениеJSON.Закрыть();
		
		МассивОшибок = ОтветОбъект["errorMessages"];
		Если МассивОшибок <> Неопределено Тогда
			ВызватьИсключение СтрШаблон("Код ответа ""%1"". Ошибки:
			|%2", КодСостояния, СтрСоединить(МассивОшибок, Символы.ПС));
		Иначе
			ВызватьИсключение СтрШаблон("Код ответа ""%1"". Не удалось определить ошибку.", КодСостояния);
		КонецЕсли;
		
		УдалитьФайлы(ФайлОтвет);
	Исключение
		УдалитьФайлы(ФайлОтвет);
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Процедура ОбновитьДанныеЗадач(НомераЗадачСтрокой) Экспорт 
	РегистрыСведений.Задачи.ОбновитьЗадачи(НомераЗадачСтрокой);
КонецПроцедуры

Функция ПолучитьДанныеБюджетаДляОтправки(БюджетСсылка) Экспорт 
	
	Возврат Новый Структура("value,id", БюджетСсылка.Наименование, БюджетСсылка.Код);

КонецФункции

Функция ПолучитьДанныеПользователяДляОтправки(ПользовательСсылка) Экспорт 
	
	Возврат Новый Структура("key,name", ПользовательСсылка.Наименование, ПользовательСсылка.Наименование);

КонецФункции
