﻿&НаКлиенте
Перем БылоИзменениеПорядкаСтрок;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОтобратьЗадачиПроизводства = Истина;
	
	СоздатьВкладкиБыстрогоФильтра();
	ОбновитьДевевьяНаСервере();
	УстановитьПараметрыДинСписка();
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыДинСписка()
	НовыеЗадачи.Параметры.УстановитьЗначениеПараметра("ОтборЗадачПроизводства", ОтобратьЗадачиПроизводства);	
	НовыеЗадачи.Параметры.УстановитьЗначениеПараметра("ГруппаРазработки", Справочники.Пользователи.Разработка);
	НовыеЗадачи.Параметры.УстановитьЗначениеПараметра("ГруппаАналитики", Справочники.Пользователи.Аналитика);
КонецПроцедуры

&НаСервере
Процедура СоздатьВкладкиБыстрогоФильтра()
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Пользователи.ФИО КАК ФИО,
		|	Пользователи.Наименование КАК Наименование
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.ОтслеживатьЗадачиНаРабочемСтоле";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Количество() = 0 Тогда
		Элементы.Вкладки.ОтображениеСтраниц = ОтображениеСтраницФормы.Нет 
	Иначе
		Элементы.Вкладки.ОтображениеСтраниц = ОтображениеСтраницФормы.ЗакладкиСверху; 
	КонецЕсли;
	
	Для Каждого Страница Из Элементы.Вкладки.ПодчиненныеЭлементы Цикл
		Если ТРег(Страница.Заголовок) = "Основная" Тогда
			Продолжить;
		КонецЕсли;
		Страница.Видимость = Ложь;
	КонецЦикла;
	
	Пока Выборка.Следующий() Цикл
		Имя = СтрЗаменить(Выборка.Наименование, ".", "_");
		СуществующийЭлемент = ЭтаФорма.Элементы.Найти(Имя);
		Если СуществующийЭлемент <> Неопределено Тогда
			СуществующийЭлемент.Видимость = Истина;
			Продолжить;	
		КонецЕсли;
		
		Вкладка = ЭтаФорма.Элементы.Добавить(Имя, Тип("ГруппаФормы"), Элементы.Вкладки);
		Вкладка.Вид = ВидГруппыФормы.Страница;
		Вкладка.Заголовок = СтрРазделить(Выборка.ФИО, " ")[0];
		
		СкопироватьЭлемент(Элементы.ИтогОценки, Вкладка.Заголовок, Вкладка);
		СкопироватьЭлемент(Элементы.ДеревоЗадачВРаботе, Вкладка.Заголовок, Вкладка);
		
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура СкопироватьЭлемент(ИсходныйЭлемент, Префикс, НовыйРодитель) Экспорт 
	Если ИсходныйЭлемент = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	
	НовыйЭлемент = ЭтаФорма.Элементы.Добавить(СтрШаблон("%1_%2", Префикс, ИсходныйЭлемент.Имя), ТипЗнч(ИсходныйЭлемент), НовыйРодитель);
	НовыйЭлемент.Заголовок = ИсходныйЭлемент.Заголовок;
	Если ТипЗнч(ИсходныйЭлемент) = Тип("ПолеФормы") ИЛИ ТипЗнч(ИсходныйЭлемент) = Тип("ТаблицаФормы") Тогда
		ЗаполнитьЗначенияСвойств(НовыйЭлемент, ИсходныйЭлемент, "ПутьКДанным,Заголовок,ШрифтЗаголовка,Шрифт");
	КонецЕсли;
	Если ТипЗнч(ИсходныйЭлемент) = Тип("ТаблицаФормы") Тогда
		ЗаполнитьЗначенияСвойств(НовыйЭлемент, ИсходныйЭлемент, "РежимВыделения,ТолькоПросмотр,ПутьКДаннымКартинкиСтроки,КартинкаСтрок,ИзменятьСоставСтрок,ИзменятьПорядокСтрок");
		НовыйЭлемент.УстановитьДействие("Выбор", "Подключаемый_ДеревоЗадачВРаботеВыбор"); 
	КонецЕсли;
	
	
	Если ТипЗнч(ИсходныйЭлемент) <> Тип("ПолеФормы") Тогда
		Для Каждого ПодЭлемент Из ИсходныйЭлемент.ПодчиненныеЭлементы Цикл
			СкопироватьЭлемент(ПодЭлемент, Префикс, НовыйЭлемент);	
		КонецЦикла;
		//Если ОбщегоНазначенияКлиентСервер.НаличиеСвойстваУОбъекта(ИсходныйЭлемент, "КоманднаяПанель") Тогда
		//	Для Каждого ПодЭлемент Из ИсходныйЭлемент.КоманднаяПанель.ПодчиненныеЭлементы Цикл
		//		СкопироватьЭлемент(ПодЭлемент, Префикс, НовыйЭлемент);	
		//	КонецЦикла;
		//КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ОбновитьДевевьяНаСервере()

	Дерево = РеквизитФормыВЗначение("ДеревоЗадачВРаботе");
	ЗаполнитьДерево(Дерево, "Принят,В работе");
	ЗначениеВРеквизитФормы(Дерево, "ДеревоЗадачВРаботе");
	
	ИтогОценки = Дерево.Строки.Итог("Оценка");
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	БылоИзменениеПорядкаСтрок = Ложь;
	УправлениеВидимостьюЭлементов();
	ПроверкаСтатусаРегЗадания();
	ЭтаФорма.ПодключитьОбработчикОжидания("ПроверкаСтатусаРегЗадания", 2, Ложь); 
КонецПроцедуры

&НаКлиенте
Процедура ПроверкаСтатусаРегЗадания()
	Элементы.ДекорацияИнфоРегЗадания.Заголовок = ПроверкаСтатусаРегЗаданияНаСервере();	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПроверкаСтатусаРегЗаданияНаСервере()
	Ответ = "";
	РЗ = РегламентныеЗадания.НайтиПредопределенное(Метаданные.РегламентныеЗадания.ПолучениеЗадач);
	Если РЗ <> Неопределено И РЗ.ПоследнееЗадание <> Неопределено Тогда
		Если РЗ.ПоследнееЗадание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
			Ответ = "Задание выполняется";	
		Иначе
			КонецПоследнегоЗадания = РЗ.ПоследнееЗадание.Конец;
			СлВыполнение = КонецПоследнегоЗадания + РЗ.Расписание.ПериодПовтораВТечениеДня;
			СостояниеВыполнения = РЗ.ПоследнееЗадание.Состояние;
			
			Ответ = СтрШаблон("%1
			|Следующие выполнение в ""%2""", СостояниеВыполнения, СлВыполнение);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Ответ;
КонецФункции


&НаКлиенте
Процедура УправлениеВидимостьюЭлементов()
	// Проверка корректности заполнения настроек подключения к JIRA
	Элементы.ДекорацияПредупреждение.Видимость = ЗначениеЗаполнено(ОбщегоНазначенияСервер.ПроверкаЗаполненияНастроекJIRA());
	Элементы.ДекорацияПредупреждениеГрафик.Видимость = Не НастройкиГрафикаЗаполнены();
	Элементы.ДекорацияПредупреждениеПочта.Видимость = Не НастройкиСервераРассылокЗаполнены();
	
	КоличествоКонфликтующихДат = ОбщегоНазначенияСервер.КоличествоКонфликтующихДат();
	Если КоличествоКонфликтующихДат > 0 Тогда
		Элементы.ОткрытьФормуКонфликтов.Заголовок = СтрШаблон("Открыть форму конфликтов (конфликтов %1)", КоличествоКонфликтующихДат);
		Элементы.ОткрытьФормуКонфликтов.ЦветТекста = Новый Цвет(255, 0, 0);
	Иначе
		Элементы.ОткрытьФормуКонфликтов.Заголовок = "Открыть форму конфликтов";
		Элементы.ОткрытьФормуКонфликтов.ЦветТекста = Новый Цвет(28, 85, 174);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НастройкиГрафикаЗаполнены()
	Возврат Константы.РабочаяНеделя.Получить() > 0 И Константы.РабочийДень.Получить() > 0;	
КонецФункции

&НаСервереБезКонтекста
Функция НастройкиСервераРассылокЗаполнены()
	Возврат ЗначениеЗаполнено(Константы.СерверИсходящейПочтыSMTP.Получить()) И	
	ЗначениеЗаполнено(Константы.ПользовательИсходящейПочты.Получить()) И
	ЗначениеЗаполнено(Константы.ПарольЭлектроннойПочты.Получить()) И
	ЗначениеЗаполнено(Константы.ПортSMTP.Получить()) И
	ЗначениеЗаполнено(Константы.ИмяОтправителя.Получить()) И
	ЗначениеЗаполнено(Константы.АдресЭлектроннойПочты.Получить());
КонецФункции

&НаКлиенте
Процедура ОткрытьНастройкиJIRA(Команда)
	ОткрытьФорму("ОбщаяФорма.ФормаНастроекJIRA",,,,,, Новый ОписаниеОповещения("ОткрытьФормуКонстантЗавершение", ЭтотОбъект), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьНастройкиГрафика(Команда)
	ОткрытьФорму("ОбщаяФорма.ФормаНастроекГрафикаРаботы",,,,,, Новый ОписаниеОповещения("ОткрытьФормуКонстантЗавершение", ЭтотОбъект), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры


&НаКлиенте
Процедура ОткрытьНастройкиЭлектроннойПочты(Команда)
	ОткрытьФорму("ОбщаяФорма.ФормаНастроекЭлектроннойПочты",,,,,, Новый ОписаниеОповещения("ОткрытьФормуКонстантЗавершение", ЭтотОбъект), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуКонстантЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
КонецПроцедуры


&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ИмяСобытия = "НастройкиИзменены" ИЛИ ИмяСобытия = "ИзмененияДатСохранено" Тогда
		УправлениеВидимостьюЭлементов();	
	КонецЕсли;
	Если ИмяСобытия = "ОбновитьВкладки" Тогда
		СоздатьВкладкиБыстрогоФильтра();	
	КонецЕсли;
КонецПроцедуры


&НаСервере
Процедура ЗаполнитьДерево(Дерево, Статусы)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Задачи.Номер КАК Номер,
		|	Задачи.Заголовок КАК Заголовок,
		|	Задачи.НомерРодительскойЗадачи КАК НомерРодительскойЗадачи,
		|	Задачи.Оценка КАК Оценка,
		|	Задачи.ПлановаяДатаЗавершения КАК ПлановаяДатаЗавершения,
		|	Задачи.Приоритет КАК Приоритет,
		|	Задачи.ДатаСоздания КАК ДатаСоздания,
		|	Задачи.Автор КАК Автор,
		|	Задачи.Исполнитель КАК Исполнитель,
		|	-(Приоритеты.Код - 5) КАК Картинка,
		|	Задачи.Статус КАК Статус,
		|	Задачи.Бюджет КАК БюджетПУ,
		|	Задачи.ДатуЗавершенияУстановилАвтор КАК ДатуЗавершенияУстановилАвтор,
		|	Задачи.Тип КАК Тип
		|ИЗ
		|	РегистрСведений.Задачи КАК Задачи
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Приоритеты КАК Приоритеты
		|		ПО Задачи.Приоритет = Приоритеты.Ссылка
		|ГДЕ
		|	(Задачи.Статус В (&Статусы)
		|				И Задачи.НомерРодительскойЗадачи = """"
		|			ИЛИ Задачи.НомерРодительскойЗадачи <> """")
		|	И (НЕ &ОтборПоРазработке
		|			ИЛИ Задачи.Тип В ИЕРАРХИИ (&ТипРазработка)
		|			ИЛИ Задачи.Исполнитель В ИЕРАРХИИ (&ГруппаРазработка))
		|	И (НЕ &ОтборПоТестированию
		|			ИЛИ Задачи.Тип В ИЕРАРХИИ (&ТипТестирование)
		|			ИЛИ Задачи.Исполнитель В ИЕРАРХИИ (&ГруппаТестирования, &ГруппаРазработка))
		|	И НЕ Задачи.Статус В (&СтатусыИсключения)
		|	И (&Исполнитель = НЕОПРЕДЕЛЕНО
		|			ИЛИ Задачи.Исполнитель = &Исполнитель)
		|
		|УПОРЯДОЧИТЬ ПО
		|	НомерРодительскойЗадачи";
	
	Запрос.УстановитьПараметр("Статусы", СтрРазделить(Статусы, ","));
	Запрос.УстановитьПараметр("СтатусыИсключения", СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ","));
	Запрос.УстановитьПараметр("ГруппаРазработка", Справочники.Пользователи.Разработка);
	Запрос.УстановитьПараметр("ГруппаТестирования", Справочники.Пользователи.Тестирование);
	Запрос.УстановитьПараметр("ОтборПоРазработке", БФильтр_Разработка);
	Запрос.УстановитьПараметр("ОтборПоТестированию", БФильтр_Тестирование);
	
	Запрос.УстановитьПараметр("ТипРазработка", Справочники.ТипыЗадач.Разработка);
	Запрос.УстановитьПараметр("ТипТестирование", Справочники.ТипыЗадач.Тестирование);
	
	Исполнитель = Справочники.Пользователи.НайтиПоНаименованию(СтрЗаменить(Элементы.Вкладки.ТекущаяСтраница.Имя, "_", "."));
	Запрос.УстановитьПараметр("Исполнитель", ?(ЗначениеЗаполнено(Исполнитель), Исполнитель, Неопределено));	
	//Если Элементы.Вкладки.ТекущаяСтраница = Элементы.МоиЗадачи Тогда
	//	Запрос.УстановитьПараметр("Исполнитель", Справочники.Пользователи.НайтиПоНаименованию("a.lazarenko"));	
	//Иначе 
	//	Запрос.УстановитьПараметр("Исполнитель", Неопределено);	
	//КонецЕсли;
	
	Выгрузка = Запрос.Выполнить().Выгрузить();
	Выгрузка.Индексы.Добавить("Номер");
	
	Дерево = РеквизитФормыВЗначение("ДеревоЗадачВРаботе");
	Дерево.Строки.Очистить();
	Для Каждого Стр Из Выгрузка Цикл
		Если Не ЗначениеЗаполнено(Исполнитель) И ЗначениеЗаполнено(Стр.НомерРодительскойЗадачи) Тогда
			Строка = Дерево.Строки.Найти(Стр.НомерРодительскойЗадачи, "Номер");
			Если Строка <> Неопределено Тогда
				НоваяСтрока = Строка.Строки.Добавить();
			Иначе
				Продолжить;
			КонецЕсли;
		Иначе
			НоваяСтрока = Дерево.Строки.Добавить();
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Стр);
	КонецЦикла;
	
	Дерево.Строки.Сортировать("Картинка Убыв, ПлановаяДатаЗавершения");
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЗадачВРаботеНачалоПеретаскивания(Элемент, ПараметрыПеретаскивания, Выполнение)
	Выполнение = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЗадачВРаботеОкончаниеПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЗадачВРаботеПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЗадачВРаботеПриИзменении(Элемент)
	//БылоИзменениеПорядкаСтрок = Истина;
	//ВизуализироватьИзменение();
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЗадачВРаботеПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	// Вставить содержимое обработчика.
КонецПроцедуры       

&НаКлиенте
Процедура ВизуализироватьИзменение()
	Если БылоИзменениеПорядкаСтрок Тогда
		ЦветРамки	= Новый Цвет(255, 0, 0); 
		Элементы.Сохранить.КнопкаПоУмолчанию = Истина;
	Иначе
		ЦветРамки	= Новый Цвет(160, 160, 160); 
		Элементы.Обновить.КнопкаПоУмолчанию = Истина;
	КонецЕсли;
	
	Элементы.ДеревоЗадачВРаботе.ЦветРамки = ЦветРамки;
КонецПроцедуры


&НаКлиенте
Процедура ОткрытьСписокВJIRA(Команда)
	Задачи = Новый Массив();
	Для Каждого Стр Из ДеревоЗадачВРаботе.ПолучитьЭлементы() Цикл
		Задачи.Добавить(Стр.Номер);	
	КонецЦикла;
	Если Задачи.Количество() > 0 Тогда
		НачатьЗапускПриложения(Новый ОписаниеОповещения("ОткрытьСписокВJIRAЗавершение", ЭтотОбъект), СтрШаблон("https://jira.bftcom.com/issues/?jql=key in(%1)", СтрСоединить(Задачи, ",")));
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ОткрытьСписокВJIRA_Новые(Команда)
	Номера = ПолучитьНомераНаСервере();
	
	Если Номера.Количество() > 0 Тогда
		Блок = ОбщегоНазначенияКлиентСервер.РазбитьМассив(Номера, 100);
		Для Каждого НомераБлока Из Блок Цикл
			НачатьЗапускПриложения(Новый ОписаниеОповещения("ОткрытьСписокВJIRAЗавершение", ЭтотОбъект), СтрШаблон("https://jira.bftcom.com/issues/?jql=key in(%1)", СтрСоединить(НомераБлока, ",")));
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьНомераНаСервере()
	Запрос = Новый Запрос();
	Запрос.Текст = НовыеЗадачи.ТекстЗапроса;
	Запрос.Параметры.Вставить("ОтборЗадачПроизводства", ОтобратьЗадачиПроизводства);	
	Запрос.Параметры.Вставить("ГруппаРазработки", Справочники.Пользователи.Разработка);
	Запрос.Параметры.Вставить("ГруппаАналитики", Справочники.Пользователи.Аналитика);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Номер");
КонецФункции

Процедура ОткрытьСписокВJIRAЗавершение(КодВозврата, ДополнительныеПараметры) Экспорт 
	
КонецПроцедуры


&НаКлиенте
Процедура Обновить(Команда)
	Если БылоИзменениеПорядкаСтрок Тогда
		Сообщить("Был изменен порядок строк, необходимо сохранить");
		Возврат;
	КонецЕсли;
	
	//Состояние("Запрашиваем задачи с JIRA");
	//ПолучитьЗадачиНаСервере();
	//Состояние("Обновляем дерево");
	ОбновитьДевевьяНаСервере();
	УправлениеВидимостьюЭлементов();
КонецПроцедуры


&НаКлиенте
Процедура ДеревоЗадачВРаботеПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЗадачВРаботеПередНачаломИзменения(Элемент, Отказ)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	ПроверитьПоследовательностьПриоритетов();
	
	БылоИзменениеПорядкаСтрок = Ложь;
	ВизуализироватьИзменение();
КонецПроцедуры

&НаСервере
Процедура ПроверитьПоследовательностьПриоритетов()
	// Нам нужно определить, что порядок приоритетов не нарушен, по этому сравниваем список пользователя и отсортированый по приоритетам список 
	ДеревоИзмененное = РеквизитФормыВЗначение("ДеревоЗадачВРаботе");
	ДеревоЭталонное = РеквизитФормыВЗначение("ДеревоЗадачВРаботе");
	ДеревоЭталонное.Строки.Сортировать("Картинка Убыв");
	
	ОшибкиПоследовательности = Новый Массив();
	Для а = 0 По ДеревоИзмененное.Строки.Количество()-1 Цикл
		Если ДеревоИзмененное.Строки[а].Приоритет	<> ДеревоЭталонное.Строки[а].Приоритет Тогда
			ОшибкиПоследовательности.Добавить(СтрШаблон("Номер строки ""%1"" (задача ""%2"")", а+1, ДеревоИзмененное.Строки[а].Номер));	
		КонецЕсли;
	КонецЦикла;
	Если ОшибкиПоследовательности.Количество() > 0 Тогда
		ВызватьИсключение СтрШаблон("Нарушена последовательность приоритетов в строках:
		|%1", СтрСоединить(ОшибкиПоследовательности, Символы.ПС));	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоЗадачВРаботеВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ОткрытьВБраузере(Элемент, ВыбраннаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ДеревоЗадачВРаботеВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ОткрытьВБраузере(Элемент, ВыбраннаяСтрока);
КонецПроцедуры


&НаКлиенте
Процедура ДеревоЗадачНовыеВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ОткрытьВБраузере(Элемент, ВыбраннаяСтрока);
КонецПроцедуры


&НаКлиенте
Процедура ОткрытьВБраузере(Элемент, ВыбраннаяСтрока)
	ТекСтрока = Элемент.ДанныеСтроки(ВыбраннаяСтрока);
	Если ТекСтрока <> Неопределено Тогда
		ВзаимодействиеC_JIRA_КлиентСервер.ОткрытьЗадачуВБраузере(ТекСтрока.Номер);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПринятьЗадачу(Команда)
	Если Элементы.НовыеЗадачи.ТекущиеДанные <> Неопределено Тогда
		ДП = Новый Структура("ТекущиеДанные", Элементы.НовыеЗадачи.ТекущиеДанные);
		Парам = Новый Структура("Приоритет,Задача,БюджетПУ,ДатуЗавершенияУстановилАвтор", ДП.ТекущиеДанные.Приоритет, ДП.ТекущиеДанные.Номер, ДП.ТекущиеДанные.БюджетПУ, ДП.ТекущиеДанные.ДатуЗавершенияУстановилАвтор);
		Парам.Вставить("ДатаЗавершения",  ДП.ТекущиеДанные.ПлановаяДатаЗавершения);
		ОткрытьФорму("ОбщаяФорма.ФормаВводаИсходнойОценкиПоЗадаче", Парам,,,,, Новый ОписаниеОповещения("ПринятьЗадачуЗавершение", ЭтотОбъект, ДП), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПринятьЗадачуЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Перем ТекущиеДанные;
	
	Если ЗначениеЗаполнено(Результат) И ДополнительныеПараметры.Свойство("ТекущиеДанные", ТекущиеДанные) И ТекущиеДанные <> Неопределено Тогда
		ВзаимодействиеC_JIRA_КлиентСервер.ПринятьЗадачу(ТекущиеДанные.Номер, Результат);
		ВзаимодействиеC_JIRA_КлиентСервер.ОбновитьДанныеСабтасков(ТекущиеДанные.Номер, Результат);
		
		ОбновитьДевевьяНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВРаботеУРазработки(Команда)
	БФильтр_Разработка = Не БФильтр_Разработка;
	ОбновитьДевевьяНаСервере();	
КонецПроцедуры

&НаКлиенте
Процедура ВРаботеУТестирования(Команда)
	БФильтр_Тестирование = Не БФильтр_Тестирование;
	ОбновитьДевевьяНаСервере();
КонецПроцедуры



&НаСервере
Функция ПроверитьФильтр(Строка)
	Возврат (БФильтр_Тестирование И ПолучитьРодителя(Строка.Исполнитель) = ПредопределенноеЗначение("Справочник.Пользователи.Тестирование")
						ИЛИ БФильтр_Разработка И ПолучитьРодителя(Строка.Исполнитель) = ПредопределенноеЗначение("Справочник.Пользователи.Разработка")) 
				И СтрРазделить("ЗАКРЫТ,СДЕЛАН,ПРЕДОСТАВЛЕНО ПР", ",").Найти(Врег(Строка.Статус)) = Неопределено;	
КонецФункции


&НаСервереБезКонтекста
Функция ПолучитьРодителя(Ссылка)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Пользователи.Родитель КАК Родитель
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Родитель;	
	КонецЕсли;
	 
КонецФункции

&НаКлиенте
Процедура ОткрытьФормуКонфликтов(Команда)
	ОткрытьФорму("ОбщаяФорма.ФормаПревышениеСроков");
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьДиаграммы(Команда)
	МассивЗадач = Новый Массив();
	Для Каждого Стр Из ДеревоЗадачВРаботе.ПолучитьЭлементы() Цикл
		МассивЗадач.Добавить(Стр.Номер);	
		Для Каждого Стр2 Из Стр.ПолучитьЭлементы() Цикл
			МассивЗадач.Добавить(Стр2.Номер);	
		КонецЦикла;
	КонецЦикла;
	
	Парам = Новый Структура("Задачи", СтрСоединить(МассивЗадач, ","));
	Парам.Вставить("ТолькоСабтаски", Истина);
	ОткрытьФорму("ОбщаяФорма.ФормаДиаграмм", Парам, ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьРегЗаданиеСейчас(Команда)
	ВыполнитьРегЗаданиеНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВыполнитьРегЗаданиеНаСервере()
	ОбработкаРегламентныхЗаданий.ВыполнитьРегЗаданиеНаСервере("ПолучениеЗадач");	
КонецПроцедуры


&НаКлиенте
Процедура ИзменитьДанныеЗадачи(Команда)
	Префикс = Элементы.Вкладки.ТекущаяСтраница.Заголовок;
	Префикс = ?(Префикс = "Основная", "", Префикс + "_");
	
	ЭлементДерево = Элементы[Префикс + Элементы.ДеревоЗадачВРаботе.Имя];
	Если ЭлементДерево.ТекущиеДанные <> Неопределено Тогда
		ДП = Новый Структура("ТекущиеДанные", ЭлементДерево.ТекущиеДанные);
		Парам = Новый Структура("Приоритет", ДП.ТекущиеДанные.Приоритет);
		Парам.Вставить("ДатаЗавершения",  ДП.ТекущиеДанные.ПлановаяДатаЗавершения);
		Парам.Вставить("ОбновитьТолькоОценку", Истина);
		Парам.Вставить("БюджетПУ", ДП.ТекущиеДанные.БюджетПУ);
		Парам.Вставить("ДатуЗавершенияУстановилАвтор", ДП.ТекущиеДанные.ДатуЗавершенияУстановилАвтор);

		ОткрытьФорму("ОбщаяФорма.ФормаВводаИсходнойОценкиПоЗадаче", Парам,,,,, Новый ОписаниеОповещения("ИзменитьДатуЗавершения_Завершение", ЭтотОбъект, ДП), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьДатуЗавершения_Завершение(Результат, ДополнительныеПараметры) Экспорт
	Перем ТекущиеДанные;
	
	Если ЗначениеЗаполнено(Результат) И ДополнительныеПараметры.Свойство("ТекущиеДанные", ТекущиеДанные) И ТекущиеДанные <> Неопределено Тогда
		ВзаимодействиеC_JIRA_КлиентСервер.УстановитьОценкуВыполненияИВремяЗадачи(ТекущиеДанные.Номер, Результат);
		ВзаимодействиеC_JIRA_КлиентСервер.ОбновитьДанныеСабтасков(ТекущиеДанные.Номер, Результат);
		
		ОбновитьДевевьяНаСервере();
		РаботаСПочтовымиСообщениямиКлиентСервер.ОтправитьУведомлениеОСменеДаты(ТекущиеДанные.Номер);
	КонецЕсли;
	
КонецПроцедуры


&НаСервереБезКонтекста
Процедура ПолучитьЗадачиНаСервере()
	РегистрыСведений.Задачи.ОбновитьЗадачи();	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСПолучениемИзменений(Команда)
	ПолучитьЗадачиНаСервере();
	ОбновитьДевевьяНаСервере();
КонецПроцедуры


&НаКлиенте
Процедура НовыеЗадачиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьВБраузере(Элемент, ВыбраннаяСтрока);
КонецПроцедуры


&НаКлиенте
Процедура ОтобратьЗадачиПроизводстваПриИзменении(Элемент)
	УстановитьПараметрыДинСписка();
КонецПроцедуры


&НаКлиенте
Процедура ВкладкиПриСменеСтраницы(Элемент, ТекущаяСтраница)
	ОбновитьДевевьяНаСервере();
КонецПроцедуры

