# Алгоритм транслитерации фамилий, имён и отчеств

## Предложенный и реализованный на SQL подход

1. Очистка ФИО от точек, табуляций, лишних пробелов
2. Определение перепутанных местами ФИО и расстановка по местам
3. Подбор справочной транслитерации (согласованной с Отделом переводов - ОП)
4. При отсутствии справочной транслитерации подстановка частотной транслитерации (самая часто указываемая пользователями, если она была указана более 3 раз). По факту все частотные транслитерации покрываются справочными.
5. При отсутствии частотной используется побуквенная транслитерация

## FAQ

<details>
  <summary>Чем плохо просто взять ГОСТ Р 7.0.34-2014?</summary>

Возникнет сразу несколько проблем, [ГОСТ Р 7.0.34-2014](https://docs.cntd.ru/document/1200113788):

1.  не учтёт самые распространённые устоявшиеся и корректные транслитерации, например Александр как Alexand**e**r. Более того, такой случай не учёт ни один стандарт, эта проблема решается только таблицей справочных транслитераций.
2.  использует замену Ц на C (или TZ,CZ). Пользователи предпочитают используемую в других распространённых действующих стандартах замену ц на ts. Пример: Kazantsev (Казанцев). ОП подтверждает допустимость этой практики.
3.  не заменяет окончания -ИЙ/-ЫЙ на Y, как это предпочитают пользователи. Например, Evgeny (Евгений), Kashnitsky (Кашницкий). ОП подтверждает допустимость этой практики.
4.  использует замену Щ на SHH, эта замена не используется ни пользователями, ни в других стандартах

Сравнение работы алгоритма и ГОСТ

| **Элемент** | **Результат алгоритма** | **ГОСТ**         | **Количество использований** | **Количество пользовательских транслитераций** | **Выбор алгоритма** | **Справочный** | **Частотный** | **Транслитерация алгоритма (мосметро)** |
|-------------|-------------------------|------------------|------------------------------|------------------------------------------------|---------------------|----------------|---------------|-----------------------------------------|
| Сергей      | Serge**y**              | Serge**i**       | 2280                         | 187                                            | Справочный          | Sergey         | Sergey        | Sergey                                  |
| Николаевич  | Nikolaevich             | Nikolaevich      | 1970                         | 83                                             | Справочный          | Nikolaevich    | Nikolaevich   | Nikolaevich                             |
| Александр   | Ale**x**and**e**r       | Ale**ks**andr    | 4616                         | 193                                            | Справочный          | Alexander      | Alexander     | Aleksandr                               |
| Михайлович  | Mikha**i**lovich        | Mikha**j**lovich | 2222                         | 38                                             | Справочный          | Mikhailovich   | Mikhailovich  | Mikhaylovich                            |
| Владимир    | Vladimir                | Vladimir         | 1615                         | 136                                            | Справочный          | Vladimir       | Vladimir      | Vladimir                                |
| Викторович  | Viktorovich             | Viktorovich      | 1564                         | 58                                             | Справочный          | Viktorovich    | Viktorovich   | Viktorovich                             |
| Олег        | Oleg                    | Oleg             | 800                          | 55                                             | Справочный          | Oleg           | Oleg          | Oleg                                    |
</details>

<details>
  <summary>Какой стандарт побуквенной транслитерации использован в алгоритме и почему?</summary>

Обзор подходов и стандартов есть в [этой статье](https://habr.com/ru/post/499574/).

Из действующих стандартов без апострофов и диакритики есть только [ГОСТ Р 7.0.34-2014](https://dangry.ru/iuliia/gost-7034/) , [Инструкция для телеграмм](https://dangry.ru/iuliia/telegram/), [ICAO DOC 9303](https://dangry.ru/iuliia/icao-doc-9303/), транслитерации [Википедии](https://dangry.ru/iuliia/wikipedia/), [Московского метро](https://dangry.ru/iuliia/mosmetro/), [Яндекс.Денег](https://dangry.ru/iuliia/yandex-money/) и [Яндекс-карт](https://dangry.ru/iuliia/yandex-maps/).

Был выбран подход Московского метро. Ниже обоснование с основными проблемами.

[**Инструкция для телеграмм**](https://dangry.ru/iuliia/telegram/)**:**

<details>
  <summary>5 проблем</summary>

-   использует замену Ц на C (или TZ,CZ). Пользователи предпочитают используемую в других распространённых действующих стандартах замену ц на ts. Пример: Kazantsev (Казанцев). ОП подтверждает допустимость этой практики.
-   заменяет й на i. Этот подход редко используется в стандартах и используется пользователями только в отчествах. Например пользователи предпочитают Sergey (Сергей) а не (Sergei).
-   заменяет Ю и Я на IU, IA. Этот подход используется всего двумя стандартами и искажает ФИО, например Tiuliaev (Тюляев). Пользователи предпочитают заменять Ю на Yu (Tyulyaev).
-   не заменяет окончания -ИЙ/-ЫЙ на Y, как это предпочитают пользователи. Например, Evgeny (Евгений), Kashnitsky (Кашницкий). ОП подтверждает допустимость этой практики.
-   Спорный подход в замене Ж на J не используемый пользователями и в других стандарта
</details>
  
[**ICAO DOC 9303**](https://dangry.ru/iuliia/icao-doc-9303/) **(для водительских удостоверений и загранпаспортов):**

3 проблемы

-   заменяет й на i. Этот подход редко используется в стандартах и используется пользователями только в отчествах. Например пользователи предпочитают Sergey (Сергей) а не (Sergei).
-   заменяет Ю и Я на IU, IA. Этот подход используется всего двумя стандартами и искажает ФИО, например Tiuliaev (Тюляев), Iuliia (Юлия). Пользователи предпочитают заменять Ю на YU, Я на YA (Tyulyaev). ОП подтверждает допустимость этой практики.
-   не заменяет окончания -ИЙ/-ЫЙ на Y, как это предпочитают пользователи. Например, Evgeny (Евгений), Kashnitsky (Кашницкий). ОП подтверждает допустимость этой практики.

[**ГОСТ Р 7.0.34-2014**](https://docs.cntd.ru/document/1200113788)**:**

3 проблемы

-   использует замену Ц на C (или TZ,CZ). Пользователи предпочитают используемую в других распространённых действующих стандартах замену ц на ts. Пример: Kazantsev (Казанцев), Kadochnikov (Кадочников). ОП подтверждает допустимость этой практики.
-   не заменяет окончания -ИЙ/-ЫЙ на Y, как это предпочитают пользователи. Например, Evgeny (Евгений), Kashnitsky (Кашницкий). ОП подтверждает допустимость этой практики.
-   использует замену Щ на SHH, эта замена не используется ни пользователями, ни в других стандартах

[**Яндекс.Деньги**](https://dangry.ru/iuliia/yandex-money/)**:**

2 проблемы

1.  заменяет й на i. Этот подход редко используется в стандартах и используется пользователями только в отчествах. Например пользователи предпочитают Sergey (Сергей) а не (Sergei).
2.  не заменяет окончания -ИЙ/-ЫЙ на Y, как это предпочитают пользователи. Например, Evgeny (Евгений), Kashnitsky (Кашницкий). ОП подтверждает допустимость этой практики.

Транслитерации [Википедии](https://dangry.ru/iuliia/wikipedia/), [Московского метро](https://dangry.ru/iuliia/mosmetro/), и [Яндекс-карт](https://dangry.ru/iuliia/yandex-maps/) не имеют этих недостатков и больше всего соответствуют задаче. Однако подход википедии требует большей фонетической точности и замены е на ye в некоторых случаях, в том числе в начале слова, что не соответствует использованию пользователями (редкая Елена готова стать Yelena) и не подтверждается ОП. Схема яндекс-карт не заменяет окончание -ий на y и обязывает менять ё на yo.

Создавать ещё один стандарт при наличии 14 действующих неблагоразумно: высока вероятность что-то упустить.

Транслитерация Московского метро в 408 случаях из 460 совпадает с самым популярным вариантом у пользователей (89% случаев).
</details>

<details>
  <summary>Можно ли использовать автоматизированный сервис?</summary>

[Dadata](https://dadata.ru/api/clean/name/) предназначен для вычистки данных и предполагает обратную транслитерацию, о прямой транслитерации ничего не пишут.

Переводчики (Google, Яндекс и Deepl) иногда будут подбирать аналоги имён (например, Paul для Павла), а не транслитерировать.

Возможно, существуют другие сервисы или Dadata могут реализовать транслитерацию.
</details>

<details>
  <summary>Можно ли все значения транслитерировать по справочнику?</summary>

Можно, но нужен надёжный источник. Таким источником мог бы быть парсинг Википедии и/или реферативной базы вроде Scopus из привязанных аккаунтов ВШЭ. Готовых объёмных надёжных источников найти не удалось.

Текущий справочник сформирован из 491 слова, покрывающих 62% случаев (380 000 использований из всех 612 000), но может быть сколь угодно большим. Транслиты в справочнике подобраны на основе самых используемых пользователями транслитераций и верифицированы ОП.

Покрытие справочником настолько обширно, что частотный транслит по факту использован всего для 4 сущностей, остальные либо покрыты справочными, либо транслитерировались менее 4 раз и их нельзя использовать.

<details>
  <summary>Справочник</summary>


| Элемент        | Справочный транслит | Тип | Количество использований | Количество частотных транслитов | Частотный       | Транслит мосметро | Подстановка для скрипта                  |
|----------------|---------------------|-----|--------------------------|---------------------------------|-----------------|-------------------|------------------------------------------|
| сергеевна      | Sergeyevna          | o   | 12389                    | 218                             | Sergeevna       | Sergeevna         | (N'сергеевна', N'Sergeyevna'),           |
| александровна  | Aleksandrovna       | o   | 12325                    | 137                             | Aleksandrovna   | Aleksandrovna     | (N'александровна', N'Aleksandrovna'),    |
| анастасия      | Anastasia           | i   | 9560                     | 126                             | Anastasia       | Anastasiya        | (N'анастасия', N'Anastasia'),            |
| андреевна      | Andreevna           | o   | 8001                     | 108                             | Andreevna       | Andreevna         | (N'андреевна', N'Andreevna'),            |
| алексеевна     | Alekseevna          | o   | 7871                     | 79                              | Alekseevna      | Alekseevna        | (N'алексеевна', N'Alekseevna'),          |
| владимировна   | Vladimirovna        | o   | 7186                     | 215                             | Vladimirovna    | Vladimirovna      | (N'владимировна', N'Vladimirovna'),      |
| екатерина      | Ekaterina           | i   | 7083                     | 268                             | Ekaterina       | Ekaterina         | (N'екатерина', N'Ekaterina'),            |
| мария          | Maria               | i   | 7054                     | 183                             | Maria           | Mariya            | (N'мария', N'Maria'),                    |
| анна           | Anna                | i   | 6941                     | 279                             | Anna            | Anna              | (N'анна', N'Anna'),                      |
| дарья          | Daria               | i   | 6687                     | 112                             | Daria           | Darya             | (N'дарья', N'Daria'),                    |
| александрович  | Aleksandrovich      | o   | 6598                     | 116                             | Aleksandrovich  | Aleksandrovich    | (N'александрович', N'Aleksandrovich'),   |
| сергеевич      | Sergeyevich         | o   | 6496                     | 150                             | Sergeevich      | Sergeevich        | (N'сергеевич', N'Sergeyevich'),          |
| дмитриевна     | Dmitrievna          | o   | 6089                     | 64                              | Dmitrievna      | Dmitrievna        | (N'дмитриевна', N'Dmitrievna'),          |
| елизавета      | Elizaveta           | i   | 4792                     | 66                              | Elizaveta       | Elizaveta         | (N'елизавета', N'Elizaveta'),            |
| александр      | Alexander           | i   | 4618                     | 193                             | Alexander       | Aleksandr         | (N'александр', N'Alexander'),            |
| полина         | Polina              | i   | 4547                     | 67                              | Polina          | Polina            | (N'полина', N'Polina'),                  |
| андреевич      | Andreevich          | o   | 4236                     | 84                              | Andreevich      | Andreevich        | (N'андреевич', N'Andreevich'),           |
| алексеевич     | Alekseevich         | o   | 4090                     | 45                              | Alekseevich     | Alekseevich       | (N'алексеевич', N'Alekseevich'),         |
| игоревна       | Igorevna            | o   | 4080                     | 97                              | Igorevna        | Igorevna          | (N'игоревна', N'Igorevna'),              |
| владимирович   | Vladimirovich       | o   | 4025                     | 175                             | Vladimirovich   | Vladimirovich     | (N'владимирович', N'Vladimirovich'),     |
| евгеньевна     | Evgenievna          | o   | 3982                     | 30                              | Evgenievna      | Evgenyevna        | (N'евгеньевна', N'Evgenievna'),          |
| михайловна     | Mikhailovna         | o   | 3773                     | 57                              | Mikhailovna     | Mikhaylovna       | (N'михайловна', N'Mikhailovna'),         |
| александра     | Alexandra           | i   | 3760                     | 71                              | Alexandra       | Aleksandra        | (N'александра', N'Alexandra'),           |
| николаевна     | Nikolaevna          | o   | 3730                     | 105                             | Nikolaevna      | Nikolaevna        | (N'николаевна', N'Nikolaevna'),          |
| юрьевна        | Yurievna            | o   | 3615                     | 54                              | Yurievna        | Yuryevna          | (N'юрьевна', N'Yurievna'),               |
| олеговна       | Olegovna            | o   | 3579                     | 69                              | Olegovna        | Olegovna          | (N'олеговна', N'Olegovna'),              |
| юлия           | Yulia               | i   | 3551                     | 73                              | Yulia           | Yuliya            | (N'юлия', N'Yulia'),                     |
| дмитриевич     | Dmitrievich         | o   | 3395                     | 50                              | Dmitrievich     | Dmitrievich       | (N'дмитриевич', N'Dmitrievich'),         |
| ксения         | Ksenia              | i   | 3351                     | 55                              | Ksenia          | Kseniya           | (N'ксения', N'Ksenia'),                  |
| елена          | Elena               | i   | 3295                     | 338                             | Elena           | Elena             | (N'елена', N'Elena'),                    |
| ольга          | Olga                | i   | 3216                     | 265                             | Olga            | Olga              | (N'ольга', N'Olga'),                     |
| дмитрий        | Dmitry              | i   | 3139                     | 117                             | Dmitry          | Dmitry            | (N'дмитрий', N'Dmitry'),                 |
| алина          | Alina               | i   | 3019                     | 53                              | Alina           | Alina             | (N'алина', N'Alina'),                    |
| виктория       | Victoria            | i   | 2977                     | 37                              | Victoria        | Viktoriya         | (N'виктория', N'Victoria'),              |
| софья          | Sofya               | i   | 2954                     | 21                              | Sofya           | Sofya             | (N'софья', N'Sofya'),                    |
| никита         | Nikita              | i   | 2888                     | 61                              | Nikita          | Nikita            | (N'никита', N'Nikita'),                  |
| андрей         | Andrey              | i   | 2869                     | 136                             | Andrey          | Andrey            | (N'андрей', N'Andrey'),                  |
| викторовна     | Viktorovna          | o   | 2844                     | 84                              | Viktorovna      | Viktorovna        | (N'викторовна', N'Viktorovna'),          |
| татьяна        | Tatiana             | i   | 2835                     | 133                             | Tatiana         | Tatyana           | (N'татьяна', N'Tatiana'),                |
| ирина          | Irina               | i   | 2612                     | 168                             | Irina           | Irina             | (N'ирина', N'Irina'),                    |
| алексей        | Alexey              | i   | 2574                     | 120                             | Alexey          | Aleksey           | (N'алексей', N'Alexey'),                 |
| иван           | Ivan                | i   | 2546                     | 98                              | Ivan            | Ivan              | (N'иван', N'Ivan'),                      |
| валерия        | Valeria             | i   | 2512                     | 26                              | Valeriya        | Valeriya          | (N'валерия', N'Valeria'),                |
| михаил         | Mikhail             | i   | 2466                     | 138                             | Mikhail         | Mikhail           | (N'михаил', N'Mikhail'),                 |
| максим         | Maksim              | i   | 2464                     | 58                              | Maxim           | Maksim            | (N'максим', N'Maksim'),                  |
| игоревич       | Igorevich           | o   | 2320                     | 79                              | Igorevich       | Igorevich         | (N'игоревич', N'Igorevich'),             |
| сергей         | Sergey              | i   | 2282                     | 187                             | Sergey          | Sergey            | (N'сергей', N'Sergey'),                  |
| наталья        | Natalia             | i   | 2243                     | 125                             | Natalia         | Natalya           | (N'наталья', N'Natalia'),                |
| михайлович     | Mikhailovich        | o   | 2224                     | 38                              | Mikhailovich    | Mikhaylovich      | (N'михайлович', N'Mikhailovich'),        |
| валерьевна     | Valerievna          | o   | 2070                     | 27                              | Valerievna      | Valeryevna        | (N'валерьевна', N'Valerievna'),          |
| павловна       | Pavlovna            | o   | 2018                     | 30                              | Pavlovna        | Pavlovna          | (N'павловна', N'Pavlovna'),              |
| олегович       | Olegovich           | o   | 2011                     | 41                              | Olegovich       | Olegovich         | (N'олегович', N'Olegovich'),             |
| юрьевич        | Yurievich           | o   | 2011                     | 25                              | Yurievich       | Yuryevich         | (N'юрьевич', N'Yurievich'),              |
| николаевич     | Nikolaevich         | o   | 1972                     | 83                              | Nikolaevich     | Nikolaevich       | (N'николаевич', N'Nikolaevich'),         |
| арина          | Arina               | i   | 1971                     | 12                              | Arina           | Arina             | (N'арина', N'Arina'),                    |
| евгеньевич     | Evgenievich         | o   | 1903                     | 23                              | Evgenievich     | Evgenyevich       | (N'евгеньевич', N'Evgenievich'),         |
| илья           | Ilya                | i   | 1890                     | 65                              | Ilya            | Ilya              | (N'илья', N'Ilya'),                      |
| анатольевна    | Anatolievna         | o   | 1882                     | 38                              | Anatolievna     | Anatolyevna       | (N'анатольевна', N'Anatolievna'),        |
| вячеславовна   | Vyacheslavovna      | o   | 1861                     | 31                              | Vyacheslavovna  | Vyacheslavovna    | (N'вячеславовна', N'Vyacheslavovna'),    |
| константиновна | Konstantinovna      | o   | 1840                     | 31                              | Konstantinovna  | Konstantinovna    | (N'константиновна', N'Konstantinovna'),  |
| даниил         | Daniil              | i   | 1747                     | 34                              | Daniil          | Daniil            | (N'даниил', N'Daniil'),                  |
| светлана       | Svetlana            | i   | 1730                     | 141                             | Svetlana        | Svetlana          | (N'светлана', N'Svetlana'),              |
| марина         | Marina              | i   | 1696                     | 108                             | Marina          | Marina            | (N'марина', N'Marina'),                  |
| романовна      | Romanovna           | o   | 1688                     | 9                               | Romanovna       | Romanovna         | (N'романовна', N'Romanovna'),            |
| витальевна     | Vitalievna          | o   | 1678                     | 12                              | Vitalievna      | Vitalyevna        | (N'витальевна', N'Vitalievna'),          |
| кирилл         | Kirill              | i   | 1667                     | 58                              | Kirill          | Kirill            | (N'кирилл', N'Kirill'),                  |
| кристина       | Kristina            | i   | 1623                     | 25                              | Kristina        | Kristina          | (N'кристина', N'Kristina'),              |
| владимир       | Vladimir            | i   | 1616                     | 136                             | Vladimir        | Vladimir          | (N'владимир', N'Vladimir'),              |
| викторович     | Viktorovich         | o   | 1566                     | 58                              | Viktorovich     | Viktorovich       | (N'викторович', N'Viktorovich'),         |
| егор           | Egor                | i   | 1535                     | 20                              | Egor            | Egor              | (N'егор', N'Egor'),                      |
| ивановна       | Ivanovna            | o   | 1531                     | 37                              | Ivanovna        | Ivanovna          | (N'ивановна', N'Ivanovna'),              |
| денисовна      | Denisovna           | o   | 1518                     | 4                               | Denisovna       | Denisovna         | (N'денисовна', N'Denisovna'),            |
| владислав      | Vladislav           | i   | 1489                     | 44                              | Vladislav       | Vladislav         | (N'владислав', N'Vladislav'),            |
| васильевна     | Vasilievna          | o   | 1483                     | 16                              | Vasilevna       | Vasilyevna        | (N'васильевна', N'Vasilievna'),          |
| диана          | Diana               | i   | 1429                     | 16                              | Diana           | Diana             | (N'диана', N'Diana'),                    |
| вероника       | Veronika            | i   | 1364                     | 32                              | Veronika        | Veronika          | (N'вероника', N'Veronika'),              |
| вадимовна      | Vadimovna           | o   | 1335                     | 25                              | Vadimovna       | Vadimovna         | (N'вадимовна', N'Vadimovna'),            |
| софия          | Sofia               | i   | 1330                     | 6                               | Sofia           | Sofiya            | (N'софия', N'Sofia'),                    |
| евгения        | Evgeniya            | i   | 1298                     | 39                              | Evgeniya        | Evgeniya          | (N'евгения', N'Evgeniya'),               |
| павел          | Pavel               | i   | 1274                     | 84                              | Pavel           | Pavel             | (N'павел', N'Pavel'),                    |
| артём          | Artyom              | i   | 1265                     | 13                              | Artem           | Artem             | (N'артём', N'Artyom'),                   |
| евгений        | Evgeny              | i   | 1220                     | 38                              | Evgeny          | Evgeny            | (N'евгений', N'Evgeny'),                 |
| антон          | Anton               | i   | 1192                     | 87                              | Anton           | Anton             | (N'антон', N'Anton'),                    |
| яна            | Yana                | i   | 1186                     | 32                              | Yana            | Yana              | (N'яна', N'Yana'),                       |
| валерьевич     | Valerievich         | o   | 1152                     | 17                              | Valerievich     | Valeryevich       | (N'валерьевич', N'Valerievich'),         |
| денис          | Denis               | i   | 1136                     | 69                              | Denis           | Denis             | (N'денис', N'Denis'),                    |
| роман          | Roman               | i   | 1118                     | 57                              | Roman           | Roman             | (N'роман', N'Roman'),                    |
| павлович       | Pavlovich           | o   | 1114                     | 30                              | Pavlovich       | Pavlovich         | (N'павлович', N'Pavlovich'),             |
| алиса          | Alisa               | i   | 1080                     | 12                              | Alisa           | Alisa             | (N'алиса', N'Alisa'),                    |
| артем          | Artyom              | i   | 1070                     | 35                              | Artem           | Artem             | (N'артем', N'Artyom'),                   |
| анатольевич    | Anatolievich        | o   | 1052                     | 23                              | Anatolievich    | Anatolyevich      | (N'анатольевич', N'Anatolievich'),       |
| варвара        | Varvara             | i   | 1037                     | 18                              | Varvara         | Varvara           | (N'варвара', N'Varvara'),                |
| николай        | Nikolay             | i   | 1027                     | 35                              | Nikolay         | Nikolay           | (N'николай', N'Nikolay'),                |
| константинович | Konstantinovich     | o   | 1013                     | 12                              | Konstantinovich | Konstantinovich   | (N'константинович', N'Konstantinovich'), |
| алёна          | Alyona              | i   | 988                      | 9                               | Alena           | Alena             | (N'алёна', N'Alyona'),                   |
| геннадьевна    | Gennadievna         | o   | 985                      | 14                              | Gennadievna     | Gennadyevna       | (N'геннадьевна', N'Gennadievna'),        |
| надежда        | Nadezhda            | i   | 979                      | 59                              | Nadezhda        | Nadezhda          | (N'надежда', N'Nadezhda'),               |
| вячеславович   | Vyacheslavovich     | o   | 976                      | 15                              | Vyacheslavovich | Vyacheslavovich   | (N'вячеславович', N'Vyacheslavovich'),   |
| маргарита      | Margarita           | i   | 961                      | 33                              | Margarita       | Margarita         | (N'маргарита', N'Margarita'),            |
| борисовна      | Borisovna           | o   | 931                      | 37                              | Borisovna       | Borisovna         | (N'борисовна', N'Borisovna'),            |
| ульяна         | Uliana              | i   | 924                      | 4                               | Ulyana          | Ulyana            | (N'ульяна', N'Uliana'),                  |
| игорь          | Igor                | i   | 922                      | 89                              | Igor            | Igor              | (N'игорь', N'Igor'),                     |
| ангелина       | Angelina            | i   | 900                      | 7                               | Angelina        | Angelina          | (N'ангелина', N'Angelina'),              |
| иванова        | Ivanova             | f   | 891                      | 35                              | Ivanova         | Ivanova           | (N'иванова', N'Ivanova'),                |
| витальевич     | Vitalievich         | o   | 880                      | 14                              | Vitalievich     | Vitalyevich       | (N'витальевич', N'Vitalievich'),         |
| максимович     | Maksimovich         | o   | 864                      | 5                               | Maksimovich     | Maksimovich       | (N'максимович', N'Maksimovich'),         |
| романович      | Romanovich          | o   | 856                      | 8                               | Romanovich      | Romanovich        | (N'романович', N'Romanovich'),           |
| иванович       | Ivanovich           | o   | 849                      | 23                              | Ivanovich       | Ivanovich         | (N'иванович', N'Ivanovich'),             |
| карина         | Karina              | i   | 824                      | 14                              | Karina          | Karina            | (N'карина', N'Karina'),                  |
| георгий        | Georgy              | i   | 822                      | 11                              | Georgii         | Georgy            | (N'георгий', N'Georgy'),                 |
| константин     | Konstantin          | i   | 819                      | 52                              | Konstantin      | Konstantin        | (N'константин', N'Konstantin'),          |
| денисович      | Denisovich          | o   | 817                      | 8                               | Denisovich      | Denisovich        | (N'денисович', N'Denisovich'),           |
| владиславовна  | Vladislavovna       | o   | 804                      | 15                              | Vladislavovna   | Vladislavovna     | (N'владиславовна', N'Vladislavovna'),    |
| олег           | Oleg                | i   | 800                      | 55                              | Oleg            | Oleg              | (N'олег', N'Oleg'),                      |
| васильевич     | Vasilievich         | o   | 777                      | 9                               | Vasilievich     | Vasilyevich       | (N'васильевич', N'Vasilievich'),         |
| эдуардовна     | Eduardovna          | o   | 767                      | 16                              | Eduardovna      | Eduardovna        | (N'эдуардовна', N'Eduardovna'),          |
| ильинична      | Ilinichna           | o   | 763                      | 5                               | Ilinichna       | Ilyinichna        | (N'ильинична', N'Ilinichna'),            |
| петровна       | Petrovna            | o   | 732                      | 27                              | Petrovna        | Petrovna          | (N'петровна', N'Petrovna'),              |
| антоновна      | Antonovna           | o   | 728                      | 8                               | Antonovna       | Antonovna         | (N'антоновна', N'Antonovna'),            |
| леонидовна     | Leonidovna          | o   | 726                      | 33                              | Leonidovna      | Leonidovna        | (N'леонидовна', N'Leonidovna'),          |
| станиславовна  | Stanislavovna       | o   | 695                      | 14                              | Stanislavovna   | Stanislavovna     | (N'станиславовна', N'Stanislavovna'),    |
| наталия        | Natalia             | i   | 671                      | 27                              | Natalia         | Nataliya          | (N'наталия', N'Natalia'),                |
| вадимович      | Vadimovich          | o   | 660                      | 14                              | Vadimovich      | Vadimovich        | (N'вадимович', N'Vadimovich'),           |
| глеб           | Gleb                | i   | 659                      | 18                              | Gleb            | Gleb              | (N'глеб', N'Gleb'),                      |
| юрий           | Yury                | i   | 657                      | 23                              | Yury            | Yury              | (N'юрий', N'Yury'),                      |
| олеся          | Olesya              | i   | 601                      | 7                               | Olesya          | Olesya            | (N'олеся', N'Olesya'),                   |
| алена          | Alyona              | i   | 600                      | 24                              | Alena           | Alena             | (N'алена', N'Alyona'),                   |
| борисович      | Borisovich          | o   | 594                      | 44                              | Borisovich      | Borisovich        | (N'борисович', N'Borisovich'),           |
| кузнецова      | Kuznetsova          | f   | 568                      | 24                              | Kuznetsova      | Kuznetsova        | (N'кузнецова', N'Kuznetsova'),           |
| вера           | Vera                | i   | 564                      | 44                              | Vera            | Vera              | (N'вера', N'Vera'),                      |
| григорий       | Grigory             | i   | 560                      | 10                              | Grigory         | Grigory           | (N'григорий', N'Grigory'),               |
| виктор         | Victor              | i   | 551                      | 27                              | Victor          | Viktor            | (N'виктор', N'Victor'),                  |
| оксана         | Oksana              | i   | 541                      | 25                              | Oksana          | Oksana            | (N'оксана', N'Oksana'),                  |
| вадим          | Vadim               | i   | 539                      | 33                              | Vadim           | Vadim             | (N'вадим', N'Vadim'),                    |
| матвей         | Matvey              | i   | 534                      | 2                               | Matvey          | Matvey            | (N'матвей', N'Matvey'),                  |
| смирнова       | Smirnova            | f   | 531                      | 23                              | Smirnova        | Smirnova          | (N'смирнова', N'Smirnova'),              |
| геннадьевич    | Gennadievich        | o   | 527                      | 15                              | Gennadievich    | Gennadyevich      | (N'геннадьевич', N'Gennadievich'),       |
| данила         | Danila              | i   | 526                      | 3                               | Danila          | Danila            | (N'данила', N'Danila'),                  |
| попова         | Popova              | f   | 522                      | 21                              | Popova          | Popova            | (N'попова', N'Popova'),                  |
| тимур          | Timur               | i   | 518                      | 15                              | Timur           | Timur             | (N'тимур', N'Timur'),                    |
| данил          | Danil               | i   | 515                      | 7                               | Danil           | Danil             | (N'данил', N'Danil'),                    |
| тимофей        | Timofey             | i   | 492                      | 9                               | Timofey         | Timofey           | (N'тимофей', N'Timofey'),                |
| руслан         | Ruslan              | i   | 488                      | 19                              | Ruslan          | Ruslan            | (N'руслан', N'Ruslan'),                  |
| арсений        | Arseny              | i   | 486                      | 5                               | Arsenii         | Arseny            | (N'арсений', N'Arseny'),                 |
| людмила        | Liudmila            | i   | 480                      | 20                              | Liudmila        | Lyudmila          | (N'людмила', N'Liudmila'),               |
| галина         | Galina              | i   | 478                      | 37                              | Galina          | Galina            | (N'галина', N'Galina'),                  |
| георгиевна     | Georgievna          | o   | 475                      | 11                              | Georgievna      | Georgievna        | (N'георгиевна', N'Georgievna'),          |
| степан         | Stepan              | i   | 469                      | 7                               | Stepan          | Stepan            | (N'степан', N'Stepan'),                  |
| иванов         | Ivanov              | f   | 464                      | 17                              | Ivanov          | Ivanov            | (N'иванов', N'Ivanov'),                  |
| валентина      | Valentina           | i   | 461                      | 32                              | Valentina       | Valentina         | (N'валентина', N'Valentina'),            |
| вячеслав       | Vyacheslav          | i   | 449                      | 16                              | Vyacheslav      | Vyacheslav        | (N'вячеслав', N'Vyacheslav'),            |
| любовь         | Liubov              | i   | 444                      | 13                              | Liubov          | Lyubov            | (N'любовь', N'Liubov'),                  |
| василий        | Vasily              | i   | 441                      | 18                              | Vasily          | Vasily            | (N'василий', N'Vasily'),                 |
| кирилловна     | Kirillovna          | o   | 439                      | 8                               | Kirillovna      | Kirillovna        | (N'кирилловна', N'Kirillovna'),          |
| элина          | Elina               | i   | 434                      | 6                               | Elina           | Elina             | (N'элина', N'Elina'),                    |
| васильева      | Vasilieva           | f   | 433                      | 7                               | Vasileva        | Vasilyeva         | (N'васильева', N'Vasilieva'),            |
| владиславович  | Vladislavovich      | o   | 433                      | 9                               | Vladislavovich  | Vladislavovich    | (N'владиславович', N'Vladislavovich'),   |
| григорьевна    | Grigorievna         | o   | 431                      | 4                               | Grigorievna     | Grigoryevna       | (N'григорьевна', N'Grigorievna'),        |
| ярослав        | Yaroslav            | i   | 429                      | 11                              | Yaroslav        | Yaroslav          | (N'ярослав', N'Yaroslav'),               |
| петрович       | Petrovich           | o   | 418                      | 20                              | Petrovich       | Petrovich         | (N'петрович', N'Petrovich'),             |
| валентиновна   | Valentinovna        | o   | 417                      | 18                              | Valentinovna    | Valentinovna      | (N'валентиновна', N'Valentinovna'),      |
| петрова        | Petrova             | f   | 416                      | 13                              | Petrova         | Petrova           | (N'петрова', N'Petrova'),                |
| ильич          | Ilyich              | o   | 405                      | 7                               | Ilyich          | Ilyich            | (N'ильич', N'Ilyich'),                   |
| леонидович     | Leonidovich         | o   | 403                      | 23                              | Leonidovich     | Leonidovich       | (N'леонидович', N'Leonidovich'),         |
| антонович      | Antonovich          | o   | 394                      | 5                               | Antonovich      | Antonovich        | (N'антонович', N'Antonovich'),           |
| артур          | Artur               | i   | 388                      | 10                              | Artur           | Artur             | (N'артур', N'Artur'),                    |
| эдуардович     | Eduardovich         | o   | 385                      | 10                              | Eduardovich     | Eduardovich       | (N'эдуардович', N'Eduardovich'),         |
| леонид         | Leonid              | i   | 374                      | 26                              | Leonid          | Leonid            | (N'леонид', N'Leonid'),                  |
| станислав      | Stanislav           | i   | 372                      | 28                              | Stanislav       | Stanislav         | (N'станислав', N'Stanislav'),            |
| лилия          | Lilia               | i   | 369                      | 8                               | Liliya          | Liliya            | (N'лилия', N'Lilia'),                    |
| ева            | Eva                 | i   | 365                      | 1                               | Eva             | Eva               | (N'ева', N'Eva'),                        |
| маратовна      | Maratovna           | o   | 361                      | 2                               | Maratovna       | Maratovna         | (N'маратовна', N'Maratovna'),            |
| русланович     | Ruslanovich         | o   | 360                      | 8                               | Ruslanovich     | Ruslanovich       | (N'русланович', N'Ruslanovich'),         |
| виталий        | Vitaly              | i   | 355                      | 18                              | Vitaliy         | Vitaly            | (N'виталий', N'Vitaly'),                 |
| нина           | Nina                | i   | 349                      | 25                              | Nina            | Nina              | (N'нина', N'Nina'),                      |
| валерий        | Valery              | i   | 345                      | 11                              | Valeriy         | Valery            | (N'валерий', N'Valery'),                 |
| артуровна      | Arturovna           | o   | 342                      | 3                               | Arturovna       | Arturovna         | (N'артуровна', N'Arturovna'),            |
| станиславович  | Stanislavovich      | o   | 340                      | 10                              | Stanislavovich  | Stanislavovich    | (N'станиславович', N'Stanislavovich'),   |
| кузнецов       | Kuznetsov           | f   | 334                      | 16                              | Kuznetsov       | Kuznetsov         | (N'кузнецов', N'Kuznetsov'),             |
| волкова        | Volkova             | f   | 332                      | 17                              | Volkova         | Volkova           | (N'волкова', N'Volkova'),                |
| артемовна      | Artyomovna          | o   | 330                      | 0                               |                 | Artemovna         | (N'артемовна', N'Artyomovna'),           |
| соколова       | Sokolova            | f   | 318                      | 12                              | Sokolova        | Sokolova          | (N'соколова', N'Sokolova'),              |
| милана         | Milana              | i   | 316                      | 2                               | Milana          | Milana            | (N'милана', N'Milana'),                  |
| георгиевич     | Georgievich         | o   | 312                      | 16                              | Georgievich     | Georgievich       | (N'георгиевич', N'Georgievich'),         |
| таисия         | Taisia              | i   | 311                      | 2                               | Taisiia         | Taisiya           | (N'таисия', N'Taisia'),                  |
| козлова        | Kozlova             | f   | 307                      | 9                               | Kozlova         | Kozlova           | (N'козлова', N'Kozlova'),                |
| михайлова      | Mikhailova          | f   | 306                      | 6                               | Mikhailova      | Mikhaylova        | (N'михайлова', N'Mikhailova'),           |
| морозова       | Morozova            | f   | 304                      | 10                              | Morozova        | Morozova          | (N'морозова', N'Morozova'),              |
| марк           | Mark                | i   | 303                      | 5                               | Mark            | Mark              | (N'марк', N'Mark'),                      |
| смирнов        | Smirnov             | f   | 302                      | 18                              | Smirnov         | Smirnov           | (N'смирнов', N'Smirnov'),                |
| новикова       | Novikova            | f   | 296                      | 10                              | Novikova        | Novikova          | (N'новикова', N'Novikova'),              |
| алексеева      | Alekseeva           | f   | 296                      | 12                              | Alekseeva       | Alekseeva         | (N'алексеева', N'Alekseeva'),            |
| василиса       | Vasilisa            | i   | 292                      | 5                               | Vasilisa        | Vasilisa          | (N'василиса', N'Vasilisa'),              |
| борис          | Boris               | i   | 285                      | 38                              | Boris           | Boris             | (N'борис', N'Boris'),                    |
| захарова       | Zakharova           | f   | 284                      | 11                              | Zakharova       | Zakharova         | (N'захарова', N'Zakharova'),             |
| павлова        | Pavlova             | f   | 283                      | 12                              | Pavlova         | Pavlova           | (N'павлова', N'Pavlova'),                |
| влада          | Vlada               | i   | 280                      | 4                               | Vlada           | Vlada             | (N'влада', N'Vlada'),                    |
| лидия          | Lidia               | i   | 278                      | 8                               | Lidia           | Lidiya            | (N'лидия', N'Lidia'),                    |
| егорова        | Egorova             | f   | 277                      | 6                               | Egorova         | Egorova           | (N'егорова', N'Egorova'),                |
| инна           | Inna                | i   | 277                      | 20                              | Inna            | Inna              | (N'инна', N'Inna'),                      |
| фёдор          | Fyodor              | i   | 275                      | 2                               | Fedor           | Fedor             | (N'фёдор', N'Fyodor'),                   |
| петр           | Petr                | i   | 272                      | 15                              | Petr            | Petr              | (N'петр', N'Petr'),                      |
| лев            | Lev                 | i   | 272                      | 17                              | Lev             | Lev               | (N'лев', N'Lev'),                        |
| григорьевич    | Grigorievich        | o   | 272                      | 3                               | Grigorievich    | Grigoryevich      | (N'григорьевич', N'Grigorievich'),       |
| богдан         | Bogdan              | i   | 270                      | 8                               | Bogdan          | Bogdan            | (N'богдан', N'Bogdan'),                  |
| милена         | Milena              | i   | 269                      | 3                               | Milena          | Milena            | (N'милена', N'Milena'),                  |
| макарова       | Makarova            | f   | 262                      | 15                              | Makarova        | Makarova          | (N'макарова', N'Makarova'),              |
| федор          | Fedor               | i   | 261                      | 13                              | Fedor           | Fedor             | (N'федор', N'Fedor'),                    |
| альбертовна    | Albertovna          | o   | 261                      | 9                               | Albertovna      | Albertovna        | (N'альбертовна', N'Albertovna'),         |
| семён          | Semyon              | i   | 260                      | 3                               | Semyon          | Semen             | (N'семён', N'Semyon'),                   |
| анатолий       | Anatoly             | i   | 259                      | 16                              | Anatoly         | Anatoly           | (N'анатолий', N'Anatoly'),               |
| ким            | Kim                 | f   | 259                      | 11                              | Kim             | Kim               | (N'ким', N'Kim'),                        |
| лариса         | Larisa              | i   | 256                      | 19                              | Larisa          | Larisa            | (N'лариса', N'Larisa'),                  |
| андреева       | Andreeva            | f   | 255                      | 6                               | Andreeva        | Andreeva          | (N'андреева', N'Andreeva'),              |
| алла           | Alla                | i   | 250                      | 23                              | Alla            | Alla              | (N'алла', N'Alla'),                      |
| давид          | David               | i   | 250                      | 8                               | David           | David             | (N'давид', N'David'),                    |
| никитина       | Nikitina            | f   | 250                      | 10                              | Nikitina        | Nikitina          | (N'никитина', N'Nikitina'),              |
| сергеева       | Sergeyeva           | f   | 248                      | 11                              | Sergeeva        | Sergeeva          | (N'сергеева', N'Sergeyeva'),             |
| попов          | Popov               | f   | 248                      | 16                              | Popov           | Popov             | (N'попов', N'Popov'),                    |
| дарина         | Darina              | i   | 248                      | 1                               | Darina          | Darina            | (N'дарина', N'Darina'),                  |
| федоровна      | Fyodorovna          | o   | 247                      | 9                               | Fedorovna       | Fedorovna         | (N'федоровна', N'Fyodorovna'),           |
| виолетта       | Violetta            | i   | 240                      | 2                               | Violetta        | Violetta          | (N'виолетта', N'Violetta'),              |
| артурович      | Arturovich          | o   | 238                      | 3                               | Arturovich      | Arturovich        | (N'артурович', N'Arturovich'),           |
| степанова      | Stepanova           | f   | 238                      | 8                               | Stepanova       | Stepanova         | (N'степанова', N'Stepanova'),            |
| федорова       | Fyodorova           | f   | 237                      | 6                               | Fedorova        | Fedorova          | (N'федорова', N'Fyodorova'),             |
| романова       | Romanova            | f   | 234                      | 8                               | Romanova        | Romanova          | (N'романова', N'Romanova'),              |
| кириллович     | Kirillovich         | o   | 232                      | 4                               | Kirillovich     | Kirillovich       | (N'кириллович', N'Kirillovich'),         |
| фролова        | Frolova             | f   | 230                      | 4                               | Frolova         | Frolova           | (N'фролова', N'Frolova'),                |
| семенова       | Semenova            | f   | 227                      | 5                               | Semenova        | Semenova          | (N'семенова', N'Semenova'),              |
| анжелика       | Angelika            | i   | 227                      | 1                               | Anzelika        | Anzhelika         | (N'анжелика', N'Angelika'),              |
| зайцева        | Zaitseva            | f   | 225                      | 2                               | Zaitseva        | Zaytseva          | (N'зайцева', N'Zaitseva'),               |
| николаева      | Nikolaeva           | f   | 223                      | 7                               | Nikolaeva       | Nikolaeva         | (N'николаева', N'Nikolaeva'),            |
| яковлева       | Yakovleva           | f   | 222                      | 5                               | Yakovleva       | Yakovleva         | (N'яковлева', N'Yakovleva'),             |
| маратович      | Maratovich          | o   | 220                      | 4                               | Maratovich      | Maratovich        | (N'маратович', N'Maratovich'),           |
| альбина        | Albina              | i   | 220                      | 8                               | Albina          | Albina            | (N'альбина', N'Albina'),                 |
| орлова         | Orlova              | f   | 219                      | 9                               | Orlova          | Orlova            | (N'орлова', N'Orlova'),                  |
| петров         | Petrov              | f   | 216                      | 5                               | Petrov          | Petrov            | (N'петров', N'Petrov'),                  |
| лебедева       | Lebedeva            | f   | 215                      | 7                               | Lebedeva        | Lebedeva          | (N'лебедева', N'Lebedeva'),              |
| тамара         | Tamara              | i   | 208                      | 18                              | Tamara          | Tamara            | (N'тамара', N'Tamara'),                  |
| аркадьевна     | Arkadievna          | o   | 205                      | 5                               | Arkadievna      | Arkadyevna        | (N'аркадьевна', N'Arkadievna'),          |
| александрова   | Aleksandrova        | f   | 204                      | 6                               | Aleksandrova    | Aleksandrova      | (N'александрова', N'Aleksandrova'),      |
| камилла        | Kamilla             | i   | 202                      | 1                               | Kamila          | Kamilla           | (N'камилла', N'Kamilla'),                |
| борисова       | Borisova            | f   | 201                      | 6                               | Borisova        | Borisova          | (N'борисова', N'Borisova'),              |
| эвелина        | Evelina             | i   | 201                      | 1                               | Evelina         | Evelina           | (N'эвелина', N'Evelina'),                |
| валентинович   | Valentinovich       | o   | 200                      | 17                              | Valentinovich   | Valentinovich     | (N'валентинович', N'Valentinovich'),     |
| всеволод       | Vsevolod            | i   | 198                      | 5                               | Vsevolod        | Vsevolod          | (N'всеволод', N'Vsevolod'),              |
| максимова      | Maksimova           | f   | 197                      | 5                               | Maksimova       | Maksimova         | (N'максимова', N'Maksimova'),            |
| новиков        | Novikov             | f   | 193                      | 13                              | Novikov         | Novikov           | (N'новиков', N'Novikov'),                |
| григорьева     | Grigorieva          | f   | 193                      | 3                               | Grigoreva       | Grigoryeva        | (N'григорьева', N'Grigorieva'),          |
| белова         | Belova              | f   | 192                      | 5                               | Belova          | Belova            | (N'белова', N'Belova'),                  |
| злата          | Zlata               | i   | 190                      | 1                               | Zlata           | Zlata             | (N'злата', N'Zlata'),                    |
| ринатовна      | Rinatovna           | o   | 190                      | 2                               | Rinatovna       | Rinatovna         | (N'ринатовна', N'Rinatovna'),            |
| тарасова       | Tarasova            | f   | 190                      | 8                               | Tarasova        | Tarasova          | (N'тарасова', N'Tarasova'),              |
| киселева       | Kiseleva            | f   | 189                      | 6                               | Kiseleva        | Kiseleva          | (N'киселева', N'Kiseleva'),              |
| шевченко       | Shevchenko          | f   | 188                      | 8                               | Shevchenko      | Shevchenko        | (N'шевченко', N'Shevchenko'),            |
| сабина         | Sabina              | i   | 188                      | 3                               | Sabina          | Sabina            | (N'сабина', N'Sabina'),                  |
| сорокина       | Sorokina            | f   | 186                      | 3                               | Sorokina        | Sorokina          | (N'сорокина', N'Sorokina'),              |
| кузьмина       | Kuzmina             | f   | 185                      | 5                               | Kuzmina         | Kuzmina           | (N'кузьмина', N'Kuzmina'),               |
| кира           | Kira                | i   | 183                      | 6                               | Kira            | Kira              | (N'кира', N'Kira'),                      |
| тимуровна      | Timurovna           | o   | 182                      | 1                               | Timurovna       | Timurovna         | (N'тимуровна', N'Timurovna'),            |
| семен          | Semyon              | i   | 181                      | 4                               | Semyon          | Semen             | (N'семен', N'Semyon'),                   |
| лада           | Lada                | i   | 180                      | 6                               | Lada            | Lada              | (N'лада', N'Lada'),                      |
| дмитриева      | Dmitrieva           | f   | 179                      | 4                               | Dmitrieva       | Dmitrieva         | (N'дмитриева', N'Dmitrieva'),            |
| соловьева      | Solovyova           | f   | 176                      | 2                               | Solovyeva       | Solovyeva         | (N'соловьева', N'Solovyova'),            |
| майя           | Maya                | i   | 175                      | 3                               | Maya            | Mayya             | (N'майя', N'Maya'),                      |
| медведева      | Medvedeva           | f   | 174                      | 5                               | Medvedeva       | Medvedeva         | (N'медведева', N'Medvedeva'),            |
| эльвира        | Elvira              | i   | 174                      | 6                               | Elvira          | Elvira            | (N'эльвира', N'Elvira'),                 |
| филиппова      | Filippova           | f   | 174                      | 3                               | Filippova       | Filippova         | (N'филиппова', N'Filippova'),            |
| соколов        | Sokolov             | f   | 172                      | 13                              | Sokolov         | Sokolov           | (N'соколов', N'Sokolov'),                |
| пётр           | Pyotr               | i   | 172                      | 1                               | Petr            | Petr              | (N'пётр', N'Pyotr'),                     |
| власова        | Vlasova             | f   | 169                      | 5                               | Vlasova         | Vlasova           | (N'власова', N'Vlasova'),                |
| морозов        | Morozov             | f   | 167                      | 11                              | Morozov         | Morozov           | (N'морозов', N'Morozov'),                |
| эдуард         | Eduard              | i   | 167                      | 7                               | Eduard          | Eduard            | (N'эдуард', N'Eduard'),                  |
| герман         | German              | i   | 166                      | 2                               | German          | German            | (N'герман', N'German'),                  |
| жанна          | Zhanna              | i   | 163                      | 8                               | Zhanna          | Zhanna            | (N'жанна', N'Zhanna'),                   |
| филипп         | Filipp              | i   | 163                      | 5                               | Philipp         | Filipp            | (N'филипп', N'Filipp'),                  |
| ильдаровна     | Ildarovna           | o   | 162                      | 4                               | Ildarovna       | Ildarovna         | (N'ильдаровна', N'Ildarovna'),           |
| мельникова     | Melnikova           | f   | 160                      | 6                               | Melnikova       | Melnikova         | (N'мельникова', N'Melnikova'),           |
| львовна        | Lvovna              | o   | 160                      | 13                              | Lvovna          | Lvovna            | (N'львовна', N'Lvovna'),                 |
| волков         | Volkov              | f   | 159                      | 8                               | Volkov          | Volkov            | (N'волков', N'Volkov'),                  |
| гусева         | Guseva              | f   | 158                      | 9                               | Guseva          | Guseva            | (N'гусева', N'Guseva'),                  |
| королева       | Koroleva            | f   | 158                      | 8                               | Koroleva        | Koroleva          | (N'королева', N'Koroleva'),              |
| бондаренко     | Bondarenko          | f   | 157                      | 4                               | Bondarenko      | Bondarenko        | (N'бондаренко', N'Bondarenko'),          |
| львович        | Lvovich             | o   | 157                      | 12                              | Lvovich         | Lvovich           | (N'львович', N'Lvovich'),                |
| степанов       | Stepanov            | f   | 155                      | 5                               | Stepanov        | Stepanov          | (N'степанов', N'Stepanov'),              |
| баранова       | Baranova            | f   | 155                      | 5                               | Baranova        | Baranova          | (N'баранова', N'Baranova'),              |
| жукова         | Zhukova             | f   | 155                      | 8                               | Zhukova         | Zhukova           | (N'жукова', N'Zhukova'),                 |
| макаров        | Makarov             | f   | 153                      | 10                              | Makarov         | Makarov           | (N'макаров', N'Makarov'),                |
| миронова       | Mironova            | f   | 153                      | 8                               | Mironova        | Mironova          | (N'миронова', N'Mironova'),              |
| карпова        | Karpova             | f   | 151                      | 6                               | Karpova         | Karpova           | (N'карпова', N'Karpova'),                |
| альбертович    | Albertovich         | o   | 151                      | 4                               | Albertovich     | Albertovich       | (N'альбертович', N'Albertovich'),        |
| антонина       | Antonina            | i   | 150                      | 5                               | Antonina        | Antonina          | (N'антонина', N'Antonina'),              |
| михайлов       | Mikhaylov           | f   | 149                      | 6                               | Mikhaylov       | Mikhaylov         | (N'михайлов', N'Mikhaylov'),             |
| ли             | Li                  | f   | 148                      | 4                               | Li              | Li                | (N'ли', N'Li'),                          |
| валентин       | Valentin            | i   | 148                      | 9                               | Valentin        | Valentin          | (N'валентин', N'Valentin'),              |
| ян             | Ian                 | i   | 147                      | 5                               | Jan             | Yan               | (N'ян', N'Ian'),                         |
| регина         | Regina              | i   | 146                      | 5                               | Regina          | Regina            | (N'регина', N'Regina'),                  |
| ковалева       | Kovaleva            | f   | 146                      | 5                               | Kovaleva        | Kovaleva          | (N'ковалева', N'Kovaleva'),              |
| павлов         | Pavlov              | f   | 145                      | 8                               | Pavlov          | Pavlov            | (N'павлов', N'Pavlov'),                  |
| динара         | Dinara              | i   | 141                      | 5                               | Dinara          | Dinara            | (N'динара', N'Dinara'),                  |
| казакова       | Kazakova            | f   | 140                      | 8                               | Kazakova        | Kazakova          | (N'казакова', N'Kazakova'),              |
| козлов         | Kozlov              | f   | 139                      | 6                               | Kozlov          | Kozlov            | (N'козлов', N'Kozlov'),                  |
| федотова       | Fedotova            | f   | 139                      | 4                               | Fedotova        | Fedotova          | (N'федотова', N'Fedotova'),              |
| романов        | Romanov             | f   | 138                      | 11                              | Romanov         | Romanov           | (N'романов', N'Romanov'),                |
| комарова       | Komarova            | f   | 138                      | 4                               | Komarova        | Komarova          | (N'комарова', N'Komarova'),              |
| захаров        | Zakharov            | f   | 138                      | 8                               | Zakharov        | Zakharov          | (N'захаров', N'Zakharov'),               |
| гаврилова      | Gavrilova           | f   | 137                      | 6                               | Gavrilova       | Gavrilova         | (N'гаврилова', N'Gavrilova'),            |
| сидорова       | Sidorova            | f   | 137                      | 4                               | Sidorova        | Sidorova          | (N'сидорова', N'Sidorova'),              |
| исаева         | Isaeva              | f   | 136                      | 8                               | Isaeva          | Isaeva            | (N'исаева', N'Isaeva'),                  |
| осипова        | Osipova             | f   | 135                      | 6                               | Osipova         | Osipova           | (N'осипова', N'Osipova'),                |
| дина           | Dina                | i   | 134                      | 8                               | Dina            | Dina              | (N'дина', N'Dina'),                      |
| андреев        | Andreev             | f   | 132                      | 8                               | Andreev         | Andreev           | (N'андреев', N'Andreev'),                |
| аркадьевич     | Arkadievich         | o   | 131                      | 5                               | Arkadievich     | Arkadyevich       | (N'аркадьевич', N'Arkadievich'),         |
| рената         | Renata              | i   | 131                      | 4                               | Renata          | Renata            | (N'рената', N'Renata'),                  |
| семенов        | Semenov             | f   | 129                      | 5                               | Semenov         | Semenov           | (N'семенов', N'Semenov'),                |
| назарова       | Nazarova            | f   | 128                      | 6                               | Nazarova        | Nazarova          | (N'назарова', N'Nazarova'),              |
| калинина       | Kalinina            | f   | 127                      | 6                               | Kalinina        | Kalinina          | (N'калинина', N'Kalinina'),              |
| коновалова     | Konovalova          | f   | 126                      | 4                               | Konovalova      | Konovalova        | (N'коновалова', N'Konovalova'),          |
| федоров        | Fedorov             | f   | 126                      | 6                               | Fedorov         | Fedorov           | (N'федоров', N'Fedorov'),                |
| лебедев        | Lebedev             | f   | 125                      | 11                              | Lebedev         | Lebedev           | (N'лебедев', N'Lebedev'),                |
| антонова       | Antonova            | f   | 125                      | 10                              | Antonova        | Antonova          | (N'антонова', N'Antonova'),              |
| пономарева     | Ponomareva          | f   | 124                      | 6                               | Ponomareva      | Ponomareva        | (N'пономарева', N'Ponomareva'),          |
| марат          | Marat               | i   | 123                      | 4                               | Marat           | Marat             | (N'марат', N'Marat'),                    |
| алексеев       | Alekseev            | f   | 123                      | 4                               | Alekseev        | Alekseev          | (N'алексеев', N'Alekseev'),              |
| колесникова    | Kolesnikova         | f   | 122                      | 4                               | Kolesnikova     | Kolesnikova       | (N'колесникова', N'Kolesnikova'),        |
| коваленко      | Kovalenko           | f   | 118                      | 6                               | Kovalenko       | Kovalenko         | (N'коваленко', N'Kovalenko'),            |
| ткаченко       | Tkachenko           | f   | 118                      | 4                               | Tkachenko       | Tkachenko         | (N'ткаченко', N'Tkachenko'),             |
| горбунова      | Gorbunova           | f   | 117                      | 4                               | Gorbunova       | Gorbunova         | (N'горбунова', N'Gorbunova'),            |
| виноградова    | Vinogradova         | f   | 117                      | 6                               | Vinogradova     | Vinogradova       | (N'виноградова', N'Vinogradova'),        |
| кравченко      | Kravchenko          | f   | 116                      | 9                               | Kravchenko      | Kravchenko        | (N'кравченко', N'Kravchenko'),           |
| яковлев        | Yakovlev            | f   | 116                      | 6                               | Yakovlev        | Yakovlev          | (N'яковлев', N'Yakovlev'),               |
| орлов          | Orlov               | f   | 116                      | 9                               | Orlov           | Orlov             | (N'орлов', N'Orlov'),                    |
| сергеев        | Sergeev             | f   | 115                      | 4                               | Sergeev         | Sergeev           | (N'сергеев', N'Sergeev'),                |
| герасимова     | Gerasimova          | f   | 115                      | 6                               | Gerasimova      | Gerasimova        | (N'герасимова', N'Gerasimova'),          |
| мадина         | Madina              | i   | 114                      | 4                               | Madina          | Madina            | (N'мадина', N'Madina'),                  |
| щербакова      | Shcherbakova        | f   | 114                      | 4                               | Scherbakova     | Scherbakova       | (N'щербакова', N'Shcherbakova'),         |
| рустам         | Rustam              | i   | 113                      | 6                               | Rustam          | Rustam            | (N'рустам', N'Rustam'),                  |
| тихонова       | Tikhonova           | f   | 112                      | 9                               | Tikhonova       | Tikhonova         | (N'тихонова', N'Tikhonova'),             |
| геннадий       | Gennady             | i   | 112                      | 6                               | Gennady         | Gennady           | (N'геннадий', N'Gennady'),               |
| денисова       | Denisova            | f   | 112                      | 5                               | Denisova        | Denisova          | (N'денисова', N'Denisova'),              |
| егоровна       | Egorovna            | o   | 111                      | 4                               | Egorovna        | Egorovna          | (N'егоровна', N'Egorovna'),              |
| кузьмин        | Kuzmin              | f   | 111                      | 4                               | Kuzmin          | Kuzmin            | (N'кузьмин', N'Kuzmin'),                 |
| альберт        | Albert              | i   | 108                      | 5                               | Albert          | Albert            | (N'альберт', N'Albert'),                 |
| елисеева       | Eliseeva            | f   | 107                      | 8                               | Eliseeva        | Eliseeva          | (N'елисеева', N'Eliseeva'),              |
| мартынова      | Martynova           | f   | 107                      | 4                               | Martynova       | Martynova         | (N'мартынова', N'Martynova'),            |
| матвеева       | Matveeva            | f   | 107                      | 6                               | Matveeva        | Matveeva          | (N'матвеева', N'Matveeva'),              |
| абрамова       | Abramova            | f   | 106                      | 4                               | Abramova        | Abramova          | (N'абрамова', N'Abramova'),              |
| григорьев      | Grigorev            | f   | 105                      | 4                               | Grigorev        | Grigoryev         | (N'григорьев', N'Grigorev'),             |
| ковалев        | Kovalev             | f   | 104                      | 4                               | Kovalev         | Kovalev           | (N'ковалев', N'Kovalev'),                |
| баранов        | Baranov             | f   | 104                      | 4                               | Baranov         | Baranov           | (N'баранов', N'Baranov'),                |
| савина         | Savina              | f   | 104                      | 5                               | Savina          | Savina            | (N'савина', N'Savina'),                  |
| наумова        | Naumova             | f   | 103                      | 4                               | Naumova         | Naumova           | (N'наумова', N'Naumova'),                |
| филатова       | Filatova            | f   | 102                      | 4                               | Filatova        | Filatova          | (N'филатова', N'Filatova'),              |
| тарасов        | Tarasov             | f   | 99                       | 6                               | Tarasov         | Tarasov           | (N'тарасов', N'Tarasov'),                |
| соболева       | Soboleva            | f   | 97                       | 7                               | Soboleva        | Soboleva          | (N'соболева', N'Soboleva'),              |
| афанасьев      | Afanasev            | f   | 97                       | 4                               | Afanasev        | Afanasyev         | (N'афанасьев', N'Afanasev'),             |
| котова         | Kotova              | f   | 97                       | 6                               | Kotova          | Kotova            | (N'котова', N'Kotova'),                  |
| сорокин        | Sorokin             | f   | 96                       | 5                               | Sorokin         | Sorokin           | (N'сорокин', N'Sorokin'),                |
| родионова      | Rodionova           | f   | 95                       | 5                               | Rodionova       | Rodionova         | (N'родионова', N'Rodionova'),            |
| мальцева       | Maltseva            | f   | 94                       | 7                               | Maltseva        | Maltseva          | (N'мальцева', N'Maltseva'),              |
| зоя            | Zoya                | i   | 94                       | 3                               | Zoya            | Zoya              | (N'зоя', N'Zoya'),                       |
| абрамов        | Abramov             | f   | 93                       | 6                               | Abramov         | Abramov           | (N'абрамов', N'Abramov'),                |
| поляков        | Polyakov            | f   | 93                       | 5                               | Polyakov        | Polyakov          | (N'поляков', N'Polyakov'),               |
| алиева         | Alieva              | f   | 92                       | 4                               | Alieva          | Alieva            | (N'алиева', N'Alieva'),                  |
| литвинова      | Litvinova           | f   | 90                       | 6                               | Litvinova       | Litvinova         | (N'литвинова', N'Litvinova'),            |
| филиппов       | Filippov            | f   | 89                       | 7                               | Filippov        | Filippov          | (N'филиппов', N'Filippov'),              |
| кудряшова      | Kudryashova         | f   | 89                       | 4                               | Kudryashova     | Kudryashova       | (N'кудряшова', N'Kudryashova'),          |
| бирюкова       | Biryukova           | f   | 88                       | 4                               | Biryukova       | Biryukova         | (N'бирюкова', N'Biryukova'),             |
| антонов        | Antonov             | f   | 87                       | 4                               | Antonov         | Antonov           | (N'антонов', N'Antonov'),                |
| жуков          | Zhukov              | f   | 86                       | 7                               | Zhukov          | Zhukov            | (N'жуков', N'Zhukov'),                   |
| геннадиевна    | Gennadievna         | o   | 85                       | 4                               | Gennadievna     | Gennadievna       | (N'геннадиевна', N'Gennadievna'),        |
| климова        | Klimova             | f   | 84                       | 5                               | Klimova         | Klimova           | (N'климова', N'Klimova'),                |
| прохорова      | Prokhorova          | f   | 84                       | 4                               | Prokhorova      | Prokhorova        | (N'прохорова', N'Prokhorova'),           |
| катерина       | Katerina            | i   | 83                       | 5                               | Katerina        | Katerina          | (N'катерина', N'Katerina'),              |
| дмитриев       | Dmitriev            | f   | 83                       | 10                              | Dmitriev        | Dmitriev          | (N'дмитриев', N'Dmitriev'),              |
| маркович       | Markovich           | o   | 82                       | 6                               | Markovich       | Markovich         | (N'маркович', N'Markovich'),             |
| савченко       | Savchenko           | f   | 81                       | 4                               | Savchenko       | Savchenko         | (N'савченко', N'Savchenko'),             |
| никулина       | Nikulina            | f   | 81                       | 5                               | Nikulina        | Nikulina          | (N'никулина', N'Nikulina'),              |
| тимофеев       | Timofeev            | f   | 81                       | 5                               | Timofeev        | Timofeev          | (N'тимофеев', N'Timofeev'),              |
| фадеева        | Fadeeva             | f   | 81                       | 6                               | Fadeeva         | Fadeeva           | (N'фадеева', N'Fadeeva'),                |
| давыдов        | Davydov             | f   | 81                       | 5                               | Davydov         | Davydov           | (N'давыдов', N'Davydov'),                |
| карпов         | Karpov              | f   | 80                       | 5                               | Karpov          | Karpov            | (N'карпов', N'Karpov'),                  |
| архипова       | Arkhipova           | f   | 80                       | 4                               | Arkhipova       | Arkhipova         | (N'архипова', N'Arkhipova'),             |
| максимов       | Maksimov            | f   | 80                       | 5                               | Maksimov        | Maksimov          | (N'максимов', N'Maksimov'),              |
| лысенко        | Lysenko             | f   | 80                       | 5                               | Lysenko         | Lysenko           | (N'лысенко', N'Lysenko'),                |
| медведев       | Medvedev            | f   | 80                       | 10                              | Medvedev        | Medvedev          | (N'медведев', N'Medvedev'),              |
| назаров        | Nazarov             | f   | 79                       | 5                               | Nazarov         | Nazarov           | (N'назаров', N'Nazarov'),                |
| михеева        | Mikheeva            | f   | 79                       | 5                               | Mikheeva        | Mikheeva          | (N'михеева', N'Mikheeva'),               |
| яков           | Yakov               | i   | 78                       | 5                               | Yakov           | Yakov             | (N'яков', N'Yakov'),                     |
| белоусова      | Belousova           | f   | 78                       | 4                               | Belousova       | Belousova         | (N'белоусова', N'Belousova'),            |
| казаков        | Kazakov             | f   | 78                       | 7                               | Kazakov         | Kazakov           | (N'казаков', N'Kazakov'),                |
| алевтина       | Alevtina            | i   | 77                       | 4                               | Alevtina        | Alevtina          | (N'алевтина', N'Alevtina'),              |
| марковна       | Markovna            | o   | 77                       | 4                               | Markovna        | Markovna          | (N'марковна', N'Markovna'),              |
| зотова         | Zotova              | f   | 76                       | 1                               | Zotova          | Zotova            | (N'зотова', N'Zotova'),                  |
| демидова       | Demidova            | f   | 75                       | 7                               | Demidova        | Demidova          | (N'демидова', N'Demidova'),              |
| яковлевич      | Yakovlevich         | o   | 75                       | 8                               | Yakovlevich     | Yakovlevich       | (N'яковлевич', N'Yakovlevich'),          |
| тихонов        | Tikhonov            | f   | 74                       | 6                               | Tikhonov        | Tikhonov          | (N'тихонов', N'Tikhonov'),               |
| эльмира        | Elmira              | i   | 73                       | 6                               | Elmira          | Elmira            | (N'эльмира', N'Elmira'),                 |
| галкина        | Galkina             | f   | 73                       | 7                               | Galkina         | Galkina           | (N'галкина', N'Galkina'),                |
| гордеева       | Gordeeva            | f   | 73                       | 4                               | Gordeeva        | Gordeeva          | (N'гордеева', N'Gordeeva'),              |
| калинин        | Kalinin             | f   | 71                       | 5                               | Kalinin         | Kalinin           | (N'калинин', N'Kalinin'),                |
| исаев          | Isaev               | f   | 71                       | 7                               | Isaev           | Isaev             | (N'исаев', N'Isaev'),                    |
| громова        | Gromova             | f   | 68                       | 5                               | Gromova         | Gromova           | (N'громова', N'Gromova'),                |
| куликов        | Kulikov             | f   | 67                       | 5                               | Kulikov         | Kulikov           | (N'куликов', N'Kulikov'),                |
| германович     | Germanovich         | o   | 67                       | 6                               | Germanovich     | Germanovich       | (N'германович', N'Germanovich'),         |
| марианна       | Marianna            | i   | 66                       | 4                               | Marianna        | Marianna          | (N'марианна', N'Marianna'),              |
| павленко       | Pavlenko            | f   | 65                       | 4                               | Pavlenko        | Pavlenko          | (N'павленко', N'Pavlenko'),              |
| левина         | Levina              | f   | 65                       | 4                               | Levina          | Levina            | (N'левина', N'Levina'),                  |
| левченко       | Levchenko           | f   | 64                       | 4                               | Levchenko       | Levchenko         | (N'левченко', N'Levchenko'),             |
| денисов        | Denisov             | f   | 63                       | 5                               | Denisov         | Denisov           | (N'денисов', N'Denisov'),                |
| зуева          | Zueva               | f   | 63                       | 4                               | Zueva           | Zueva             | (N'зуева', N'Zueva'),                    |
| фокина         | Fokina              | f   | 63                       | 4                               | Fokina          | Fokina            | (N'фокина', N'Fokina'),                  |
| романенко      | Romanenko           | f   | 62                       | 4                               | Romanenko       | Romanenko         | (N'романенко', N'Romanenko'),            |
| федотов        | Fedotov             | f   | 61                       | 5                               | Fedotov         | Fedotov           | (N'федотов', N'Fedotov'),                |
| шилова         | Shilova             | f   | 60                       | 5                               | Shilova         | Shilova           | (N'шилова', N'Shilova'),                 |
| майорова       | Mayorova            | f   | 60                       | 4                               | Mayorova        | Mayorova          | (N'майорова', N'Mayorova'),              |
| ларионова      | Larionova           | f   | 60                       | 4                               | Larionova       | Larionova         | (N'ларионова', N'Larionova'),            |
| горбунов       | Gorbunov            | f   | 60                       | 5                               | Gorbunov        | Gorbunov          | (N'горбунов', N'Gorbunov'),              |
| бочарова       | Bocharova           | f   | 59                       | 6                               | Bocharova       | Bocharova         | (N'бочарова', N'Bocharova'),             |
| авдеева        | Avdeeva             | f   | 59                       | 4                               | Avdeeva         | Avdeeva           | (N'авдеева', N'Avdeeva'),                |
| зорина         | Zorina              | f   | 59                       | 2                               | Zorina          | Zorina            | (N'зорина', N'Zorina'),                  |
| шабанова       | Shabanova           | f   | 58                       | 6                               | Shabanova       | Shabanova         | (N'шабанова', N'Shabanova'),             |
| федоренко      | Fedorenko           | f   | 58                       | 5                               | Fedorenko       | Fedorenko         | (N'федоренко', N'Fedorenko'),            |
| тарасенко      | Tarasenko           | f   | 57                       | 5                               | Tarasenko       | Tarasenko         | (N'тарасенко', N'Tarasenko'),            |
| пономарев      | Ponomarev           | f   | 57                       | 5                               | Ponomarev       | Ponomarev         | (N'пономарев', N'Ponomarev'),            |
| крылов         | Krylov              | f   | 57                       | 4                               | Krylov          | Krylov            | (N'крылов', N'Krylov'),                  |
| котов          | Kotov               | f   | 57                       | 6                               | Kotov           | Kotov             | (N'котов', N'Kotov'),                    |
| молчанова      | Molchanova          | f   | 56                       | 5                               | Molchanova      | Molchanova        | (N'молчанова', N'Molchanova'),           |
| логинов        | Loginov             | f   | 55                       | 4                               | Loginov         | Loginov           | (N'логинов', N'Loginov'),                |
| серова         | Serova              | f   | 54                       | 5                               | Serova          | Serova            | (N'серова', N'Serova'),                  |
| шестакова      | Shestakova          | f   | 54                       | 4                               | Shestakova      | Shestakova        | (N'шестакова', N'Shestakova'),           |
| еременко       | Eremenko            | f   | 54                       | 4                               | Eremenko        | Eremenko          | (N'еременко', N'Eremenko'),              |
| клименко       | Klimenko            | f   | 53                       | 6                               | Klimenko        | Klimenko          | (N'клименко', N'Klimenko'),              |
| ася            | Asya                | i   | 53                       | 2                               | Asya            | Asya              | (N'ася', N'Asya'),                       |
| митрофанова    | Mitrofanova         | f   | 53                       | 4                               | Mitrofanova     | Mitrofanova       | (N'митрофанова', N'Mitrofanova'),        |
| мирошниченко   | Miroshnichenko      | f   | 52                       | 4                               | Miroshnichenko  | Miroshnichenko    | (N'мирошниченко', N'Miroshnichenko'),    |
| инга           | Inga                | i   | 52                       | 5                               | Inga            | Inga              | (N'инга', N'Inga'),                      |
| кузина         | Kuzina              | f   | 52                       | 5                               | Kuzina          | Kuzina            | (N'кузина', N'Kuzina'),                  |
| левин          | Levin               | f   | 52                       | 4                               | Levin           | Levin             | (N'левин', N'Levin'),                    |
| кулакова       | Kulakova            | f   | 52                       | 4                               | Kulakova        | Kulakova          | (N'кулакова', N'Kulakova'),              |
| зверева        | Zvereva             | f   | 52                       | 5                               | Zvereva         | Zvereva           | (N'зверева', N'Zvereva'),                |
| зубкова        | Zubkova             | f   | 51                       | 4                               | Zubkova         | Zubkova           | (N'зубкова', N'Zubkova'),                |
| хохлов         | Khokhlov            | f   | 51                       | 4                               | Khokhlov        | Khokhlov          | (N'хохлов', N'Khokhlov'),                |
| соболев        | Sobolev             | f   | 51                       | 5                               | Sobolev         | Sobolev           | (N'соболев', N'Sobolev'),                |
| устинова       | Ustinova            | f   | 50                       | 4                               | Ustinova        | Ustinova          | (N'устинова', N'Ustinova'),              |
| платонова      | Platonova           | f   | 50                       | 4                               | Platonova       | Platonova         | (N'платонова', N'Platonova'),            |
| андрианова     | Andrianova          | f   | 49                       | 5                               | Andrianova      | Andrianova        | (N'андрианова', N'Andrianova'),          |
| горбачева      | Gorbacheva          | f   | 48                       | 5                               | Gorbacheva      | Gorbacheva        | (N'горбачева', N'Gorbacheva'),           |
| шишкин         | Shishkin            | f   | 48                       | 4                               | Shishkin        | Shishkin          | (N'шишкин', N'Shishkin'),                |
| гузель         | Guzel               | i   | 47                       | 4                               | Guzel           | Guzel             | (N'гузель', N'Guzel'),                   |
| комаров        | Komarov             | f   | 47                       | 5                               | Komarov         | Komarov           | (N'комаров', N'Komarov'),                |
| панов          | Panov               | f   | 45                       | 7                               | Panov           | Panov             | (N'панов', N'Panov'),                    |
| сафронов       | Safronov            | f   | 45                       | 4                               | Safronov        | Safronov          | (N'сафронов', N'Safronov'),              |
| красильникова  | Krasilnikova        | f   | 44                       | 4                               | Krasilnikova    | Krasilnikova      | (N'красильникова', N'Krasilnikova'),     |
| грачева        | Gracheva            | f   | 44                       | 5                               | Gracheva        | Gracheva          | (N'грачева', N'Gracheva'),               |
| галкин         | Galkin              | f   | 42                       | 4                               | Galkin          | Galkin            | (N'галкин', N'Galkin'),                  |
| громов         | Gromov              | f   | 41                       | 5                               | Gromov          | Gromov            | (N'громов', N'Gromov'),                  |
| ренат          | Renat               | i   | 40                       | 4                               | Renat           | Renat             | (N'ренат', N'Renat'),                    |
| вишнякова      | Vishnyakova         | f   | 39                       | 4                               | Vishnyakova     | Vishnyakova       | (N'вишнякова', N'Vishnyakova'),          |
| казанцев       | Kazantsev           | f   | 38                       | 5                               | Kazantsev       | Kazantsev         | (N'казанцев', N'Kazantsev'),             |
| минина         | Minina              | f   | 38                       | 5                               | Minina          | Minina            | (N'минина', N'Minina'),                  |
| харитонов      | Kharitonov          | f   | 38                       | 5                               | Kharitonov      | Kharitonov        | (N'харитонов', N'Kharitonov'),           |
| зинченко       | Zinchenko           | f   | 37                       | 5                               | Zinchenko       | Zinchenko         | (N'зинченко', N'Zinchenko'),             |
| богомолова     | Bogomolova          | f   | 36                       | 4                               | Bogomolova      | Bogomolova        | (N'богомолова', N'Bogomolova'),          |
| сизова         | Sizova              | f   | 36                       | 4                               | Sizova          | Sizova            | (N'сизова', N'Sizova'),                  |
| ахмедова       | Akhmedova           | f   | 35                       | 5                               | Akhmedova       | Akhmedova         | (N'ахмедова', N'Akhmedova'),             |
| мироненко      | Mironenko           | f   | 34                       | 4                               | Mironenko       | Mironenko         | (N'мироненко', N'Mironenko'),            |
| рубцов         | Rubtsov             | f   | 32                       | 4                               | Rubtsov         | Rubtsov           | (N'рубцов', N'Rubtsov'),                 |
| ефим           | Efim                | i   | 29                       | 4                               | Efim            | Efim              | (N'ефим', N'Efim'),                      |
| кабанов        | Kabanov             | f   | 29                       | 6                               | Kabanov         | Kabanov           | (N'кабанов', N'Kabanov'),                |
| мясникова      | Myasnikova          | f   | 28                       | 4                               | Myasnikova      | Myasnikova        | (N'мясникова', N'Myasnikova'),           |
| стрельникова   | Strelnikova         | f   | 28                       | 5                               | Strelnikova     | Strelnikova       | (N'стрельникова', N'Strelnikova'),       |
| нефедов        | Nefedov             | f   | 27                       | 4                               | Nefedov         | Nefedov           | (N'нефедов', N'Nefedov'),                |
| рыбаков        | Rybakov             | f   | 25                       | 6                               | Rybakov         | Rybakov           | (N'рыбаков', N'Rybakov'),                |
| мезенцева      | Mezentseva          | f   | 24                       | 4                               | Mezentseva      | Mezentseva        | (N'мезенцева', N'Mezentseva'),           |
| лавров         | Lavrov              | f   | 24                       | 4                               | Lavrov          | Lavrov            | (N'лавров', N'Lavrov'),                  |
| баженов        | Bazhenov            | f   | 24                       | 4                               | Bazhenov        | Bazhenov          | (N'баженов', N'Bazhenov'),               |
| кондрашов      | Kondrashov          | f   | 21                       | 4                               | Kondrashov      | Kondrashov        | (N'кондрашов', N'Kondrashov'),           |
| шапошников     | Shaposhnikov        | f   | 21                       | 4                               | Shaposhnikov    | Shaposhnikov      | (N'шапошников', N'Shaposhnikov'),        |
| гаврилина      | Gavrilina           | f   | 20                       | 5                               | Gavrilina       | Gavrilina         | (N'гаврилина', N'Gavrilina'),            |
| коршунов       | Korshunov           | f   | 19                       | 4                               | Korshunov       | Korshunov         | (N'коршунов', N'Korshunov'),             |
| косарев        | Kosarev             | f   | 19                       | 5                               | Kosarev         | Kosarev           | (N'косарев', N'Kosarev'),                |
| трофименко     | Trofimenko          | f   | 19                       | 4                               | Trofimenko      | Trofimenko        | (N'трофименко', N'Trofimenko'),          |
| якушев         | Yakushev            | f   | 17                       | 4                               | Yakushev        | Yakushev          | (N'якушев', N'Yakushev'),                |
| пучков         | Puchkov             | f   | 15                       | 4                               | Puchkov         | Puchkov           | (N'пучков', N'Puchkov'),                 |
| банников       | Bannikov            | f   | 15                       | 5                               | Bannikov        | Bannikov          | (N'банников', N'Bannikov'),              |
| багаутдинова   | Bagautdinova        | f   | 13                       | 4                               | Bagautdinova    | Bagautdinova      | (N'багаутдинова', N'Bagautdinova'),      |
| бэла           | Bela                | i   | 11                       | 4                               | Bela            | Bela              | (N'бэла', N'Bela'),                      |
| дэвид          | David               | i   | 11                       | 4                               | David           | Devid             | (N'дэвид', N'David'),                    |
| подкопаев      | Podkopaev           | f   | 8                        | 4                               | Podkopaev       | Podkopaev         | (N'подкопаев', N'Podkopaev'),            |
| эндрю          | Andrew              | o   | 5                        | 4                               | Andrew          | Endryu            | (N'эндрю', N'Andrew'),                   |
</details>

</details>

<details>
  <summary>Как определяются перепутанные ФИО?</summary>

При формировании списка уникальных элементов алгоритм подсчитывает, сколько раз этот элемент встречается в фамилиях, отчествах и именах и обозначает элемент соответствующей буквой: f, i или o.

В дальнейшем, если в конкретной записи фамилия не похожа на фамилию, зато имя или отчество похоже на фамилию, берётся более похожий элемент. Имя и отчество подставляются аналогично, но не сравниваются между собой, т.к. некоторые иностранные пользователи в отчество подставляют второе имя и в таком случае возможны ошибки.
</details>
  
<details>
  <summary>Сколько всего и каких элементов в SA?</summary>

На 05.10.2021 в SA 208 377 записей.

По данным скрипта это 82 248 уникальных сущности (используемые 614 576 раз), среди которых 64 905 фамилий (используемых 208 326 раза), 10 519 имён (используемых 208 332 раз) и 8556 отчеств (используемых 197 931 раз).

Количество перепутанных ФИО 6424, вероятно мусорных записей - 331 (сущностей - 341).
</details>
  
## Справочник

Справочник согласован с Отделом переводов и добавлен прямо в скрипт (транслитерирующий фрагмент для скрипта сформирован в Excel-файле.

<details>
  <summary>Показать справочник</summary>

| Элемент        | Справочный транслит | Тип | Количество использований | Количество частотных транслитов | Частотный       | Транслит мосметро | Подстановка для скрипта                  |
|----------------|---------------------|-----|--------------------------|---------------------------------|-----------------|-------------------|------------------------------------------|
| сергеевна      | Sergeyevna          | o   | 12389                    | 218                             | Sergeevna       | Sergeevna         | (N'сергеевна', N'Sergeyevna'),           |
| александровна  | Aleksandrovna       | o   | 12325                    | 137                             | Aleksandrovna   | Aleksandrovna     | (N'александровна', N'Aleksandrovna'),    |
| анастасия      | Anastasia           | i   | 9560                     | 126                             | Anastasia       | Anastasiya        | (N'анастасия', N'Anastasia'),            |
| андреевна      | Andreevna           | o   | 8001                     | 108                             | Andreevna       | Andreevna         | (N'андреевна', N'Andreevna'),            |
| алексеевна     | Alekseevna          | o   | 7871                     | 79                              | Alekseevna      | Alekseevna        | (N'алексеевна', N'Alekseevna'),          |
| владимировна   | Vladimirovna        | o   | 7186                     | 215                             | Vladimirovna    | Vladimirovna      | (N'владимировна', N'Vladimirovna'),      |
| екатерина      | Ekaterina           | i   | 7083                     | 268                             | Ekaterina       | Ekaterina         | (N'екатерина', N'Ekaterina'),            |
| мария          | Maria               | i   | 7054                     | 183                             | Maria           | Mariya            | (N'мария', N'Maria'),                    |
| анна           | Anna                | i   | 6941                     | 279                             | Anna            | Anna              | (N'анна', N'Anna'),                      |
| дарья          | Daria               | i   | 6687                     | 112                             | Daria           | Darya             | (N'дарья', N'Daria'),                    |
| александрович  | Aleksandrovich      | o   | 6598                     | 116                             | Aleksandrovich  | Aleksandrovich    | (N'александрович', N'Aleksandrovich'),   |
| сергеевич      | Sergeyevich         | o   | 6496                     | 150                             | Sergeevich      | Sergeevich        | (N'сергеевич', N'Sergeyevich'),          |
| дмитриевна     | Dmitrievna          | o   | 6089                     | 64                              | Dmitrievna      | Dmitrievna        | (N'дмитриевна', N'Dmitrievna'),          |
| елизавета      | Elizaveta           | i   | 4792                     | 66                              | Elizaveta       | Elizaveta         | (N'елизавета', N'Elizaveta'),            |
| александр      | Alexander           | i   | 4618                     | 193                             | Alexander       | Aleksandr         | (N'александр', N'Alexander'),            |
| полина         | Polina              | i   | 4547                     | 67                              | Polina          | Polina            | (N'полина', N'Polina'),                  |
| андреевич      | Andreevich          | o   | 4236                     | 84                              | Andreevich      | Andreevich        | (N'андреевич', N'Andreevich'),           |
| алексеевич     | Alekseevich         | o   | 4090                     | 45                              | Alekseevich     | Alekseevich       | (N'алексеевич', N'Alekseevich'),         |
| игоревна       | Igorevna            | o   | 4080                     | 97                              | Igorevna        | Igorevna          | (N'игоревна', N'Igorevna'),              |
| владимирович   | Vladimirovich       | o   | 4025                     | 175                             | Vladimirovich   | Vladimirovich     | (N'владимирович', N'Vladimirovich'),     |
| евгеньевна     | Evgenievna          | o   | 3982                     | 30                              | Evgenievna      | Evgenyevna        | (N'евгеньевна', N'Evgenievna'),          |
| михайловна     | Mikhailovna         | o   | 3773                     | 57                              | Mikhailovna     | Mikhaylovna       | (N'михайловна', N'Mikhailovna'),         |
| александра     | Alexandra           | i   | 3760                     | 71                              | Alexandra       | Aleksandra        | (N'александра', N'Alexandra'),           |
| николаевна     | Nikolaevna          | o   | 3730                     | 105                             | Nikolaevna      | Nikolaevna        | (N'николаевна', N'Nikolaevna'),          |
| юрьевна        | Yurievna            | o   | 3615                     | 54                              | Yurievna        | Yuryevna          | (N'юрьевна', N'Yurievna'),               |
| олеговна       | Olegovna            | o   | 3579                     | 69                              | Olegovna        | Olegovna          | (N'олеговна', N'Olegovna'),              |
| юлия           | Yulia               | i   | 3551                     | 73                              | Yulia           | Yuliya            | (N'юлия', N'Yulia'),                     |
| дмитриевич     | Dmitrievich         | o   | 3395                     | 50                              | Dmitrievich     | Dmitrievich       | (N'дмитриевич', N'Dmitrievich'),         |
| ксения         | Ksenia              | i   | 3351                     | 55                              | Ksenia          | Kseniya           | (N'ксения', N'Ksenia'),                  |
| елена          | Elena               | i   | 3295                     | 338                             | Elena           | Elena             | (N'елена', N'Elena'),                    |
| ольга          | Olga                | i   | 3216                     | 265                             | Olga            | Olga              | (N'ольга', N'Olga'),                     |
| дмитрий        | Dmitry              | i   | 3139                     | 117                             | Dmitry          | Dmitry            | (N'дмитрий', N'Dmitry'),                 |
| алина          | Alina               | i   | 3019                     | 53                              | Alina           | Alina             | (N'алина', N'Alina'),                    |
| виктория       | Victoria            | i   | 2977                     | 37                              | Victoria        | Viktoriya         | (N'виктория', N'Victoria'),              |
| софья          | Sofya               | i   | 2954                     | 21                              | Sofya           | Sofya             | (N'софья', N'Sofya'),                    |
| никита         | Nikita              | i   | 2888                     | 61                              | Nikita          | Nikita            | (N'никита', N'Nikita'),                  |
| андрей         | Andrey              | i   | 2869                     | 136                             | Andrey          | Andrey            | (N'андрей', N'Andrey'),                  |
| викторовна     | Viktorovna          | o   | 2844                     | 84                              | Viktorovna      | Viktorovna        | (N'викторовна', N'Viktorovna'),          |
| татьяна        | Tatiana             | i   | 2835                     | 133                             | Tatiana         | Tatyana           | (N'татьяна', N'Tatiana'),                |
| ирина          | Irina               | i   | 2612                     | 168                             | Irina           | Irina             | (N'ирина', N'Irina'),                    |
| алексей        | Alexey              | i   | 2574                     | 120                             | Alexey          | Aleksey           | (N'алексей', N'Alexey'),                 |
| иван           | Ivan                | i   | 2546                     | 98                              | Ivan            | Ivan              | (N'иван', N'Ivan'),                      |
| валерия        | Valeria             | i   | 2512                     | 26                              | Valeriya        | Valeriya          | (N'валерия', N'Valeria'),                |
| михаил         | Mikhail             | i   | 2466                     | 138                             | Mikhail         | Mikhail           | (N'михаил', N'Mikhail'),                 |
| максим         | Maksim              | i   | 2464                     | 58                              | Maxim           | Maksim            | (N'максим', N'Maksim'),                  |
| игоревич       | Igorevich           | o   | 2320                     | 79                              | Igorevich       | Igorevich         | (N'игоревич', N'Igorevich'),             |
| сергей         | Sergey              | i   | 2282                     | 187                             | Sergey          | Sergey            | (N'сергей', N'Sergey'),                  |
| наталья        | Natalia             | i   | 2243                     | 125                             | Natalia         | Natalya           | (N'наталья', N'Natalia'),                |
| михайлович     | Mikhailovich        | o   | 2224                     | 38                              | Mikhailovich    | Mikhaylovich      | (N'михайлович', N'Mikhailovich'),        |
| валерьевна     | Valerievna          | o   | 2070                     | 27                              | Valerievna      | Valeryevna        | (N'валерьевна', N'Valerievna'),          |
| павловна       | Pavlovna            | o   | 2018                     | 30                              | Pavlovna        | Pavlovna          | (N'павловна', N'Pavlovna'),              |
| олегович       | Olegovich           | o   | 2011                     | 41                              | Olegovich       | Olegovich         | (N'олегович', N'Olegovich'),             |
| юрьевич        | Yurievich           | o   | 2011                     | 25                              | Yurievich       | Yuryevich         | (N'юрьевич', N'Yurievich'),              |
| николаевич     | Nikolaevich         | o   | 1972                     | 83                              | Nikolaevich     | Nikolaevich       | (N'николаевич', N'Nikolaevich'),         |
| арина          | Arina               | i   | 1971                     | 12                              | Arina           | Arina             | (N'арина', N'Arina'),                    |
| евгеньевич     | Evgenievich         | o   | 1903                     | 23                              | Evgenievich     | Evgenyevich       | (N'евгеньевич', N'Evgenievich'),         |
| илья           | Ilya                | i   | 1890                     | 65                              | Ilya            | Ilya              | (N'илья', N'Ilya'),                      |
| анатольевна    | Anatolievna         | o   | 1882                     | 38                              | Anatolievna     | Anatolyevna       | (N'анатольевна', N'Anatolievna'),        |
| вячеславовна   | Vyacheslavovna      | o   | 1861                     | 31                              | Vyacheslavovna  | Vyacheslavovna    | (N'вячеславовна', N'Vyacheslavovna'),    |
| константиновна | Konstantinovna      | o   | 1840                     | 31                              | Konstantinovna  | Konstantinovna    | (N'константиновна', N'Konstantinovna'),  |
| даниил         | Daniil              | i   | 1747                     | 34                              | Daniil          | Daniil            | (N'даниил', N'Daniil'),                  |
| светлана       | Svetlana            | i   | 1730                     | 141                             | Svetlana        | Svetlana          | (N'светлана', N'Svetlana'),              |
| марина         | Marina              | i   | 1696                     | 108                             | Marina          | Marina            | (N'марина', N'Marina'),                  |
| романовна      | Romanovna           | o   | 1688                     | 9                               | Romanovna       | Romanovna         | (N'романовна', N'Romanovna'),            |
| витальевна     | Vitalievna          | o   | 1678                     | 12                              | Vitalievna      | Vitalyevna        | (N'витальевна', N'Vitalievna'),          |
| кирилл         | Kirill              | i   | 1667                     | 58                              | Kirill          | Kirill            | (N'кирилл', N'Kirill'),                  |
| кристина       | Kristina            | i   | 1623                     | 25                              | Kristina        | Kristina          | (N'кристина', N'Kristina'),              |
| владимир       | Vladimir            | i   | 1616                     | 136                             | Vladimir        | Vladimir          | (N'владимир', N'Vladimir'),              |
| викторович     | Viktorovich         | o   | 1566                     | 58                              | Viktorovich     | Viktorovich       | (N'викторович', N'Viktorovich'),         |
| егор           | Egor                | i   | 1535                     | 20                              | Egor            | Egor              | (N'егор', N'Egor'),                      |
| ивановна       | Ivanovna            | o   | 1531                     | 37                              | Ivanovna        | Ivanovna          | (N'ивановна', N'Ivanovna'),              |
| денисовна      | Denisovna           | o   | 1518                     | 4                               | Denisovna       | Denisovna         | (N'денисовна', N'Denisovna'),            |
| владислав      | Vladislav           | i   | 1489                     | 44                              | Vladislav       | Vladislav         | (N'владислав', N'Vladislav'),            |
| васильевна     | Vasilievna          | o   | 1483                     | 16                              | Vasilevna       | Vasilyevna        | (N'васильевна', N'Vasilievna'),          |
| диана          | Diana               | i   | 1429                     | 16                              | Diana           | Diana             | (N'диана', N'Diana'),                    |
| вероника       | Veronika            | i   | 1364                     | 32                              | Veronika        | Veronika          | (N'вероника', N'Veronika'),              |
| вадимовна      | Vadimovna           | o   | 1335                     | 25                              | Vadimovna       | Vadimovna         | (N'вадимовна', N'Vadimovna'),            |
| софия          | Sofia               | i   | 1330                     | 6                               | Sofia           | Sofiya            | (N'софия', N'Sofia'),                    |
| евгения        | Evgeniya            | i   | 1298                     | 39                              | Evgeniya        | Evgeniya          | (N'евгения', N'Evgeniya'),               |
| павел          | Pavel               | i   | 1274                     | 84                              | Pavel           | Pavel             | (N'павел', N'Pavel'),                    |
| артём          | Artyom              | i   | 1265                     | 13                              | Artem           | Artem             | (N'артём', N'Artyom'),                   |
| евгений        | Evgeny              | i   | 1220                     | 38                              | Evgeny          | Evgeny            | (N'евгений', N'Evgeny'),                 |
| антон          | Anton               | i   | 1192                     | 87                              | Anton           | Anton             | (N'антон', N'Anton'),                    |
| яна            | Yana                | i   | 1186                     | 32                              | Yana            | Yana              | (N'яна', N'Yana'),                       |
| валерьевич     | Valerievich         | o   | 1152                     | 17                              | Valerievich     | Valeryevich       | (N'валерьевич', N'Valerievich'),         |
| денис          | Denis               | i   | 1136                     | 69                              | Denis           | Denis             | (N'денис', N'Denis'),                    |
| роман          | Roman               | i   | 1118                     | 57                              | Roman           | Roman             | (N'роман', N'Roman'),                    |
| павлович       | Pavlovich           | o   | 1114                     | 30                              | Pavlovich       | Pavlovich         | (N'павлович', N'Pavlovich'),             |
| алиса          | Alisa               | i   | 1080                     | 12                              | Alisa           | Alisa             | (N'алиса', N'Alisa'),                    |
| артем          | Artyom              | i   | 1070                     | 35                              | Artem           | Artem             | (N'артем', N'Artyom'),                   |
| анатольевич    | Anatolievich        | o   | 1052                     | 23                              | Anatolievich    | Anatolyevich      | (N'анатольевич', N'Anatolievich'),       |
| варвара        | Varvara             | i   | 1037                     | 18                              | Varvara         | Varvara           | (N'варвара', N'Varvara'),                |
| николай        | Nikolay             | i   | 1027                     | 35                              | Nikolay         | Nikolay           | (N'николай', N'Nikolay'),                |
| константинович | Konstantinovich     | o   | 1013                     | 12                              | Konstantinovich | Konstantinovich   | (N'константинович', N'Konstantinovich'), |
| алёна          | Alyona              | i   | 988                      | 9                               | Alena           | Alena             | (N'алёна', N'Alyona'),                   |
| геннадьевна    | Gennadievna         | o   | 985                      | 14                              | Gennadievna     | Gennadyevna       | (N'геннадьевна', N'Gennadievna'),        |
| надежда        | Nadezhda            | i   | 979                      | 59                              | Nadezhda        | Nadezhda          | (N'надежда', N'Nadezhda'),               |
| вячеславович   | Vyacheslavovich     | o   | 976                      | 15                              | Vyacheslavovich | Vyacheslavovich   | (N'вячеславович', N'Vyacheslavovich'),   |
| маргарита      | Margarita           | i   | 961                      | 33                              | Margarita       | Margarita         | (N'маргарита', N'Margarita'),            |
| борисовна      | Borisovna           | o   | 931                      | 37                              | Borisovna       | Borisovna         | (N'борисовна', N'Borisovna'),            |
| ульяна         | Uliana              | i   | 924                      | 4                               | Ulyana          | Ulyana            | (N'ульяна', N'Uliana'),                  |
| игорь          | Igor                | i   | 922                      | 89                              | Igor            | Igor              | (N'игорь', N'Igor'),                     |
| ангелина       | Angelina            | i   | 900                      | 7                               | Angelina        | Angelina          | (N'ангелина', N'Angelina'),              |
| иванова        | Ivanova             | f   | 891                      | 35                              | Ivanova         | Ivanova           | (N'иванова', N'Ivanova'),                |
| витальевич     | Vitalievich         | o   | 880                      | 14                              | Vitalievich     | Vitalyevich       | (N'витальевич', N'Vitalievich'),         |
| максимович     | Maksimovich         | o   | 864                      | 5                               | Maksimovich     | Maksimovich       | (N'максимович', N'Maksimovich'),         |
| романович      | Romanovich          | o   | 856                      | 8                               | Romanovich      | Romanovich        | (N'романович', N'Romanovich'),           |
| иванович       | Ivanovich           | o   | 849                      | 23                              | Ivanovich       | Ivanovich         | (N'иванович', N'Ivanovich'),             |
| карина         | Karina              | i   | 824                      | 14                              | Karina          | Karina            | (N'карина', N'Karina'),                  |
| георгий        | Georgy              | i   | 822                      | 11                              | Georgii         | Georgy            | (N'георгий', N'Georgy'),                 |
| константин     | Konstantin          | i   | 819                      | 52                              | Konstantin      | Konstantin        | (N'константин', N'Konstantin'),          |
| денисович      | Denisovich          | o   | 817                      | 8                               | Denisovich      | Denisovich        | (N'денисович', N'Denisovich'),           |
| владиславовна  | Vladislavovna       | o   | 804                      | 15                              | Vladislavovna   | Vladislavovna     | (N'владиславовна', N'Vladislavovna'),    |
| олег           | Oleg                | i   | 800                      | 55                              | Oleg            | Oleg              | (N'олег', N'Oleg'),                      |
| васильевич     | Vasilievich         | o   | 777                      | 9                               | Vasilievich     | Vasilyevich       | (N'васильевич', N'Vasilievich'),         |
| эдуардовна     | Eduardovna          | o   | 767                      | 16                              | Eduardovna      | Eduardovna        | (N'эдуардовна', N'Eduardovna'),          |
| ильинична      | Ilinichna           | o   | 763                      | 5                               | Ilinichna       | Ilyinichna        | (N'ильинична', N'Ilinichna'),            |
| петровна       | Petrovna            | o   | 732                      | 27                              | Petrovna        | Petrovna          | (N'петровна', N'Petrovna'),              |
| антоновна      | Antonovna           | o   | 728                      | 8                               | Antonovna       | Antonovna         | (N'антоновна', N'Antonovna'),            |
| леонидовна     | Leonidovna          | o   | 726                      | 33                              | Leonidovna      | Leonidovna        | (N'леонидовна', N'Leonidovna'),          |
| станиславовна  | Stanislavovna       | o   | 695                      | 14                              | Stanislavovna   | Stanislavovna     | (N'станиславовна', N'Stanislavovna'),    |
| наталия        | Natalia             | i   | 671                      | 27                              | Natalia         | Nataliya          | (N'наталия', N'Natalia'),                |
| вадимович      | Vadimovich          | o   | 660                      | 14                              | Vadimovich      | Vadimovich        | (N'вадимович', N'Vadimovich'),           |
| глеб           | Gleb                | i   | 659                      | 18                              | Gleb            | Gleb              | (N'глеб', N'Gleb'),                      |
| юрий           | Yury                | i   | 657                      | 23                              | Yury            | Yury              | (N'юрий', N'Yury'),                      |
| олеся          | Olesya              | i   | 601                      | 7                               | Olesya          | Olesya            | (N'олеся', N'Olesya'),                   |
| алена          | Alyona              | i   | 600                      | 24                              | Alena           | Alena             | (N'алена', N'Alyona'),                   |
| борисович      | Borisovich          | o   | 594                      | 44                              | Borisovich      | Borisovich        | (N'борисович', N'Borisovich'),           |
| кузнецова      | Kuznetsova          | f   | 568                      | 24                              | Kuznetsova      | Kuznetsova        | (N'кузнецова', N'Kuznetsova'),           |
| вера           | Vera                | i   | 564                      | 44                              | Vera            | Vera              | (N'вера', N'Vera'),                      |
| григорий       | Grigory             | i   | 560                      | 10                              | Grigory         | Grigory           | (N'григорий', N'Grigory'),               |
| виктор         | Victor              | i   | 551                      | 27                              | Victor          | Viktor            | (N'виктор', N'Victor'),                  |
| оксана         | Oksana              | i   | 541                      | 25                              | Oksana          | Oksana            | (N'оксана', N'Oksana'),                  |
| вадим          | Vadim               | i   | 539                      | 33                              | Vadim           | Vadim             | (N'вадим', N'Vadim'),                    |
| матвей         | Matvey              | i   | 534                      | 2                               | Matvey          | Matvey            | (N'матвей', N'Matvey'),                  |
| смирнова       | Smirnova            | f   | 531                      | 23                              | Smirnova        | Smirnova          | (N'смирнова', N'Smirnova'),              |
| геннадьевич    | Gennadievich        | o   | 527                      | 15                              | Gennadievich    | Gennadyevich      | (N'геннадьевич', N'Gennadievich'),       |
| данила         | Danila              | i   | 526                      | 3                               | Danila          | Danila            | (N'данила', N'Danila'),                  |
| попова         | Popova              | f   | 522                      | 21                              | Popova          | Popova            | (N'попова', N'Popova'),                  |
| тимур          | Timur               | i   | 518                      | 15                              | Timur           | Timur             | (N'тимур', N'Timur'),                    |
| данил          | Danil               | i   | 515                      | 7                               | Danil           | Danil             | (N'данил', N'Danil'),                    |
| тимофей        | Timofey             | i   | 492                      | 9                               | Timofey         | Timofey           | (N'тимофей', N'Timofey'),                |
| руслан         | Ruslan              | i   | 488                      | 19                              | Ruslan          | Ruslan            | (N'руслан', N'Ruslan'),                  |
| арсений        | Arseny              | i   | 486                      | 5                               | Arsenii         | Arseny            | (N'арсений', N'Arseny'),                 |
| людмила        | Liudmila            | i   | 480                      | 20                              | Liudmila        | Lyudmila          | (N'людмила', N'Liudmila'),               |
| галина         | Galina              | i   | 478                      | 37                              | Galina          | Galina            | (N'галина', N'Galina'),                  |
| георгиевна     | Georgievna          | o   | 475                      | 11                              | Georgievna      | Georgievna        | (N'георгиевна', N'Georgievna'),          |
| степан         | Stepan              | i   | 469                      | 7                               | Stepan          | Stepan            | (N'степан', N'Stepan'),                  |
| иванов         | Ivanov              | f   | 464                      | 17                              | Ivanov          | Ivanov            | (N'иванов', N'Ivanov'),                  |
| валентина      | Valentina           | i   | 461                      | 32                              | Valentina       | Valentina         | (N'валентина', N'Valentina'),            |
| вячеслав       | Vyacheslav          | i   | 449                      | 16                              | Vyacheslav      | Vyacheslav        | (N'вячеслав', N'Vyacheslav'),            |
| любовь         | Liubov              | i   | 444                      | 13                              | Liubov          | Lyubov            | (N'любовь', N'Liubov'),                  |
| василий        | Vasily              | i   | 441                      | 18                              | Vasily          | Vasily            | (N'василий', N'Vasily'),                 |
| кирилловна     | Kirillovna          | o   | 439                      | 8                               | Kirillovna      | Kirillovna        | (N'кирилловна', N'Kirillovna'),          |
| элина          | Elina               | i   | 434                      | 6                               | Elina           | Elina             | (N'элина', N'Elina'),                    |
| васильева      | Vasilieva           | f   | 433                      | 7                               | Vasileva        | Vasilyeva         | (N'васильева', N'Vasilieva'),            |
| владиславович  | Vladislavovich      | o   | 433                      | 9                               | Vladislavovich  | Vladislavovich    | (N'владиславович', N'Vladislavovich'),   |
| григорьевна    | Grigorievna         | o   | 431                      | 4                               | Grigorievna     | Grigoryevna       | (N'григорьевна', N'Grigorievna'),        |
| ярослав        | Yaroslav            | i   | 429                      | 11                              | Yaroslav        | Yaroslav          | (N'ярослав', N'Yaroslav'),               |
| петрович       | Petrovich           | o   | 418                      | 20                              | Petrovich       | Petrovich         | (N'петрович', N'Petrovich'),             |
| валентиновна   | Valentinovna        | o   | 417                      | 18                              | Valentinovna    | Valentinovna      | (N'валентиновна', N'Valentinovna'),      |
| петрова        | Petrova             | f   | 416                      | 13                              | Petrova         | Petrova           | (N'петрова', N'Petrova'),                |
| ильич          | Ilyich              | o   | 405                      | 7                               | Ilyich          | Ilyich            | (N'ильич', N'Ilyich'),                   |
| леонидович     | Leonidovich         | o   | 403                      | 23                              | Leonidovich     | Leonidovich       | (N'леонидович', N'Leonidovich'),         |
| антонович      | Antonovich          | o   | 394                      | 5                               | Antonovich      | Antonovich        | (N'антонович', N'Antonovich'),           |
| артур          | Artur               | i   | 388                      | 10                              | Artur           | Artur             | (N'артур', N'Artur'),                    |
| эдуардович     | Eduardovich         | o   | 385                      | 10                              | Eduardovich     | Eduardovich       | (N'эдуардович', N'Eduardovich'),         |
| леонид         | Leonid              | i   | 374                      | 26                              | Leonid          | Leonid            | (N'леонид', N'Leonid'),                  |
| станислав      | Stanislav           | i   | 372                      | 28                              | Stanislav       | Stanislav         | (N'станислав', N'Stanislav'),            |
| лилия          | Lilia               | i   | 369                      | 8                               | Liliya          | Liliya            | (N'лилия', N'Lilia'),                    |
| ева            | Eva                 | i   | 365                      | 1                               | Eva             | Eva               | (N'ева', N'Eva'),                        |
| маратовна      | Maratovna           | o   | 361                      | 2                               | Maratovna       | Maratovna         | (N'маратовна', N'Maratovna'),            |
| русланович     | Ruslanovich         | o   | 360                      | 8                               | Ruslanovich     | Ruslanovich       | (N'русланович', N'Ruslanovich'),         |
| виталий        | Vitaly              | i   | 355                      | 18                              | Vitaliy         | Vitaly            | (N'виталий', N'Vitaly'),                 |
| нина           | Nina                | i   | 349                      | 25                              | Nina            | Nina              | (N'нина', N'Nina'),                      |
| валерий        | Valery              | i   | 345                      | 11                              | Valeriy         | Valery            | (N'валерий', N'Valery'),                 |
| артуровна      | Arturovna           | o   | 342                      | 3                               | Arturovna       | Arturovna         | (N'артуровна', N'Arturovna'),            |
| станиславович  | Stanislavovich      | o   | 340                      | 10                              | Stanislavovich  | Stanislavovich    | (N'станиславович', N'Stanislavovich'),   |
| кузнецов       | Kuznetsov           | f   | 334                      | 16                              | Kuznetsov       | Kuznetsov         | (N'кузнецов', N'Kuznetsov'),             |
| волкова        | Volkova             | f   | 332                      | 17                              | Volkova         | Volkova           | (N'волкова', N'Volkova'),                |
| артемовна      | Artyomovna          | o   | 330                      | 0                               |                 | Artemovna         | (N'артемовна', N'Artyomovna'),           |
| соколова       | Sokolova            | f   | 318                      | 12                              | Sokolova        | Sokolova          | (N'соколова', N'Sokolova'),              |
| милана         | Milana              | i   | 316                      | 2                               | Milana          | Milana            | (N'милана', N'Milana'),                  |
| георгиевич     | Georgievich         | o   | 312                      | 16                              | Georgievich     | Georgievich       | (N'георгиевич', N'Georgievich'),         |
| таисия         | Taisia              | i   | 311                      | 2                               | Taisiia         | Taisiya           | (N'таисия', N'Taisia'),                  |
| козлова        | Kozlova             | f   | 307                      | 9                               | Kozlova         | Kozlova           | (N'козлова', N'Kozlova'),                |
| михайлова      | Mikhailova          | f   | 306                      | 6                               | Mikhailova      | Mikhaylova        | (N'михайлова', N'Mikhailova'),           |
| морозова       | Morozova            | f   | 304                      | 10                              | Morozova        | Morozova          | (N'морозова', N'Morozova'),              |
| марк           | Mark                | i   | 303                      | 5                               | Mark            | Mark              | (N'марк', N'Mark'),                      |
| смирнов        | Smirnov             | f   | 302                      | 18                              | Smirnov         | Smirnov           | (N'смирнов', N'Smirnov'),                |
| новикова       | Novikova            | f   | 296                      | 10                              | Novikova        | Novikova          | (N'новикова', N'Novikova'),              |
| алексеева      | Alekseeva           | f   | 296                      | 12                              | Alekseeva       | Alekseeva         | (N'алексеева', N'Alekseeva'),            |
| василиса       | Vasilisa            | i   | 292                      | 5                               | Vasilisa        | Vasilisa          | (N'василиса', N'Vasilisa'),              |
| борис          | Boris               | i   | 285                      | 38                              | Boris           | Boris             | (N'борис', N'Boris'),                    |
| захарова       | Zakharova           | f   | 284                      | 11                              | Zakharova       | Zakharova         | (N'захарова', N'Zakharova'),             |
| павлова        | Pavlova             | f   | 283                      | 12                              | Pavlova         | Pavlova           | (N'павлова', N'Pavlova'),                |
| влада          | Vlada               | i   | 280                      | 4                               | Vlada           | Vlada             | (N'влада', N'Vlada'),                    |
| лидия          | Lidia               | i   | 278                      | 8                               | Lidia           | Lidiya            | (N'лидия', N'Lidia'),                    |
| егорова        | Egorova             | f   | 277                      | 6                               | Egorova         | Egorova           | (N'егорова', N'Egorova'),                |
| инна           | Inna                | i   | 277                      | 20                              | Inna            | Inna              | (N'инна', N'Inna'),                      |
| фёдор          | Fyodor              | i   | 275                      | 2                               | Fedor           | Fedor             | (N'фёдор', N'Fyodor'),                   |
| петр           | Petr                | i   | 272                      | 15                              | Petr            | Petr              | (N'петр', N'Petr'),                      |
| лев            | Lev                 | i   | 272                      | 17                              | Lev             | Lev               | (N'лев', N'Lev'),                        |
| григорьевич    | Grigorievich        | o   | 272                      | 3                               | Grigorievich    | Grigoryevich      | (N'григорьевич', N'Grigorievich'),       |
| богдан         | Bogdan              | i   | 270                      | 8                               | Bogdan          | Bogdan            | (N'богдан', N'Bogdan'),                  |
| милена         | Milena              | i   | 269                      | 3                               | Milena          | Milena            | (N'милена', N'Milena'),                  |
| макарова       | Makarova            | f   | 262                      | 15                              | Makarova        | Makarova          | (N'макарова', N'Makarova'),              |
| федор          | Fedor               | i   | 261                      | 13                              | Fedor           | Fedor             | (N'федор', N'Fedor'),                    |
| альбертовна    | Albertovna          | o   | 261                      | 9                               | Albertovna      | Albertovna        | (N'альбертовна', N'Albertovna'),         |
| семён          | Semyon              | i   | 260                      | 3                               | Semyon          | Semen             | (N'семён', N'Semyon'),                   |
| анатолий       | Anatoly             | i   | 259                      | 16                              | Anatoly         | Anatoly           | (N'анатолий', N'Anatoly'),               |
| ким            | Kim                 | f   | 259                      | 11                              | Kim             | Kim               | (N'ким', N'Kim'),                        |
| лариса         | Larisa              | i   | 256                      | 19                              | Larisa          | Larisa            | (N'лариса', N'Larisa'),                  |
| андреева       | Andreeva            | f   | 255                      | 6                               | Andreeva        | Andreeva          | (N'андреева', N'Andreeva'),              |
| алла           | Alla                | i   | 250                      | 23                              | Alla            | Alla              | (N'алла', N'Alla'),                      |
| давид          | David               | i   | 250                      | 8                               | David           | David             | (N'давид', N'David'),                    |
| никитина       | Nikitina            | f   | 250                      | 10                              | Nikitina        | Nikitina          | (N'никитина', N'Nikitina'),              |
| сергеева       | Sergeyeva           | f   | 248                      | 11                              | Sergeeva        | Sergeeva          | (N'сергеева', N'Sergeyeva'),             |
| попов          | Popov               | f   | 248                      | 16                              | Popov           | Popov             | (N'попов', N'Popov'),                    |
| дарина         | Darina              | i   | 248                      | 1                               | Darina          | Darina            | (N'дарина', N'Darina'),                  |
| федоровна      | Fyodorovna          | o   | 247                      | 9                               | Fedorovna       | Fedorovna         | (N'федоровна', N'Fyodorovna'),           |
| виолетта       | Violetta            | i   | 240                      | 2                               | Violetta        | Violetta          | (N'виолетта', N'Violetta'),              |
| артурович      | Arturovich          | o   | 238                      | 3                               | Arturovich      | Arturovich        | (N'артурович', N'Arturovich'),           |
| степанова      | Stepanova           | f   | 238                      | 8                               | Stepanova       | Stepanova         | (N'степанова', N'Stepanova'),            |
| федорова       | Fyodorova           | f   | 237                      | 6                               | Fedorova        | Fedorova          | (N'федорова', N'Fyodorova'),             |
| романова       | Romanova            | f   | 234                      | 8                               | Romanova        | Romanova          | (N'романова', N'Romanova'),              |
| кириллович     | Kirillovich         | o   | 232                      | 4                               | Kirillovich     | Kirillovich       | (N'кириллович', N'Kirillovich'),         |
| фролова        | Frolova             | f   | 230                      | 4                               | Frolova         | Frolova           | (N'фролова', N'Frolova'),                |
| семенова       | Semenova            | f   | 227                      | 5                               | Semenova        | Semenova          | (N'семенова', N'Semenova'),              |
| анжелика       | Angelika            | i   | 227                      | 1                               | Anzelika        | Anzhelika         | (N'анжелика', N'Angelika'),              |
| зайцева        | Zaitseva            | f   | 225                      | 2                               | Zaitseva        | Zaytseva          | (N'зайцева', N'Zaitseva'),               |
| николаева      | Nikolaeva           | f   | 223                      | 7                               | Nikolaeva       | Nikolaeva         | (N'николаева', N'Nikolaeva'),            |
| яковлева       | Yakovleva           | f   | 222                      | 5                               | Yakovleva       | Yakovleva         | (N'яковлева', N'Yakovleva'),             |
| маратович      | Maratovich          | o   | 220                      | 4                               | Maratovich      | Maratovich        | (N'маратович', N'Maratovich'),           |
| альбина        | Albina              | i   | 220                      | 8                               | Albina          | Albina            | (N'альбина', N'Albina'),                 |
| орлова         | Orlova              | f   | 219                      | 9                               | Orlova          | Orlova            | (N'орлова', N'Orlova'),                  |
| петров         | Petrov              | f   | 216                      | 5                               | Petrov          | Petrov            | (N'петров', N'Petrov'),                  |
| лебедева       | Lebedeva            | f   | 215                      | 7                               | Lebedeva        | Lebedeva          | (N'лебедева', N'Lebedeva'),              |
| тамара         | Tamara              | i   | 208                      | 18                              | Tamara          | Tamara            | (N'тамара', N'Tamara'),                  |
| аркадьевна     | Arkadievna          | o   | 205                      | 5                               | Arkadievna      | Arkadyevna        | (N'аркадьевна', N'Arkadievna'),          |
| александрова   | Aleksandrova        | f   | 204                      | 6                               | Aleksandrova    | Aleksandrova      | (N'александрова', N'Aleksandrova'),      |
| камилла        | Kamilla             | i   | 202                      | 1                               | Kamila          | Kamilla           | (N'камилла', N'Kamilla'),                |
| борисова       | Borisova            | f   | 201                      | 6                               | Borisova        | Borisova          | (N'борисова', N'Borisova'),              |
| эвелина        | Evelina             | i   | 201                      | 1                               | Evelina         | Evelina           | (N'эвелина', N'Evelina'),                |
| валентинович   | Valentinovich       | o   | 200                      | 17                              | Valentinovich   | Valentinovich     | (N'валентинович', N'Valentinovich'),     |
| всеволод       | Vsevolod            | i   | 198                      | 5                               | Vsevolod        | Vsevolod          | (N'всеволод', N'Vsevolod'),              |
| максимова      | Maksimova           | f   | 197                      | 5                               | Maksimova       | Maksimova         | (N'максимова', N'Maksimova'),            |
| новиков        | Novikov             | f   | 193                      | 13                              | Novikov         | Novikov           | (N'новиков', N'Novikov'),                |
| григорьева     | Grigorieva          | f   | 193                      | 3                               | Grigoreva       | Grigoryeva        | (N'григорьева', N'Grigorieva'),          |
| белова         | Belova              | f   | 192                      | 5                               | Belova          | Belova            | (N'белова', N'Belova'),                  |
| злата          | Zlata               | i   | 190                      | 1                               | Zlata           | Zlata             | (N'злата', N'Zlata'),                    |
| ринатовна      | Rinatovna           | o   | 190                      | 2                               | Rinatovna       | Rinatovna         | (N'ринатовна', N'Rinatovna'),            |
| тарасова       | Tarasova            | f   | 190                      | 8                               | Tarasova        | Tarasova          | (N'тарасова', N'Tarasova'),              |
| киселева       | Kiseleva            | f   | 189                      | 6                               | Kiseleva        | Kiseleva          | (N'киселева', N'Kiseleva'),              |
| шевченко       | Shevchenko          | f   | 188                      | 8                               | Shevchenko      | Shevchenko        | (N'шевченко', N'Shevchenko'),            |
| сабина         | Sabina              | i   | 188                      | 3                               | Sabina          | Sabina            | (N'сабина', N'Sabina'),                  |
| сорокина       | Sorokina            | f   | 186                      | 3                               | Sorokina        | Sorokina          | (N'сорокина', N'Sorokina'),              |
| кузьмина       | Kuzmina             | f   | 185                      | 5                               | Kuzmina         | Kuzmina           | (N'кузьмина', N'Kuzmina'),               |
| кира           | Kira                | i   | 183                      | 6                               | Kira            | Kira              | (N'кира', N'Kira'),                      |
| тимуровна      | Timurovna           | o   | 182                      | 1                               | Timurovna       | Timurovna         | (N'тимуровна', N'Timurovna'),            |
| семен          | Semyon              | i   | 181                      | 4                               | Semyon          | Semen             | (N'семен', N'Semyon'),                   |
| лада           | Lada                | i   | 180                      | 6                               | Lada            | Lada              | (N'лада', N'Lada'),                      |
| дмитриева      | Dmitrieva           | f   | 179                      | 4                               | Dmitrieva       | Dmitrieva         | (N'дмитриева', N'Dmitrieva'),            |
| соловьева      | Solovyova           | f   | 176                      | 2                               | Solovyeva       | Solovyeva         | (N'соловьева', N'Solovyova'),            |
| майя           | Maya                | i   | 175                      | 3                               | Maya            | Mayya             | (N'майя', N'Maya'),                      |
| медведева      | Medvedeva           | f   | 174                      | 5                               | Medvedeva       | Medvedeva         | (N'медведева', N'Medvedeva'),            |
| эльвира        | Elvira              | i   | 174                      | 6                               | Elvira          | Elvira            | (N'эльвира', N'Elvira'),                 |
| филиппова      | Filippova           | f   | 174                      | 3                               | Filippova       | Filippova         | (N'филиппова', N'Filippova'),            |
| соколов        | Sokolov             | f   | 172                      | 13                              | Sokolov         | Sokolov           | (N'соколов', N'Sokolov'),                |
| пётр           | Pyotr               | i   | 172                      | 1                               | Petr            | Petr              | (N'пётр', N'Pyotr'),                     |
| власова        | Vlasova             | f   | 169                      | 5                               | Vlasova         | Vlasova           | (N'власова', N'Vlasova'),                |
| морозов        | Morozov             | f   | 167                      | 11                              | Morozov         | Morozov           | (N'морозов', N'Morozov'),                |
| эдуард         | Eduard              | i   | 167                      | 7                               | Eduard          | Eduard            | (N'эдуард', N'Eduard'),                  |
| герман         | German              | i   | 166                      | 2                               | German          | German            | (N'герман', N'German'),                  |
| жанна          | Zhanna              | i   | 163                      | 8                               | Zhanna          | Zhanna            | (N'жанна', N'Zhanna'),                   |
| филипп         | Filipp              | i   | 163                      | 5                               | Philipp         | Filipp            | (N'филипп', N'Filipp'),                  |
| ильдаровна     | Ildarovna           | o   | 162                      | 4                               | Ildarovna       | Ildarovna         | (N'ильдаровна', N'Ildarovna'),           |
| мельникова     | Melnikova           | f   | 160                      | 6                               | Melnikova       | Melnikova         | (N'мельникова', N'Melnikova'),           |
| львовна        | Lvovna              | o   | 160                      | 13                              | Lvovna          | Lvovna            | (N'львовна', N'Lvovna'),                 |
| волков         | Volkov              | f   | 159                      | 8                               | Volkov          | Volkov            | (N'волков', N'Volkov'),                  |
| гусева         | Guseva              | f   | 158                      | 9                               | Guseva          | Guseva            | (N'гусева', N'Guseva'),                  |
| королева       | Koroleva            | f   | 158                      | 8                               | Koroleva        | Koroleva          | (N'королева', N'Koroleva'),              |
| бондаренко     | Bondarenko          | f   | 157                      | 4                               | Bondarenko      | Bondarenko        | (N'бондаренко', N'Bondarenko'),          |
| львович        | Lvovich             | o   | 157                      | 12                              | Lvovich         | Lvovich           | (N'львович', N'Lvovich'),                |
| степанов       | Stepanov            | f   | 155                      | 5                               | Stepanov        | Stepanov          | (N'степанов', N'Stepanov'),              |
| баранова       | Baranova            | f   | 155                      | 5                               | Baranova        | Baranova          | (N'баранова', N'Baranova'),              |
| жукова         | Zhukova             | f   | 155                      | 8                               | Zhukova         | Zhukova           | (N'жукова', N'Zhukova'),                 |
| макаров        | Makarov             | f   | 153                      | 10                              | Makarov         | Makarov           | (N'макаров', N'Makarov'),                |
| миронова       | Mironova            | f   | 153                      | 8                               | Mironova        | Mironova          | (N'миронова', N'Mironova'),              |
| карпова        | Karpova             | f   | 151                      | 6                               | Karpova         | Karpova           | (N'карпова', N'Karpova'),                |
| альбертович    | Albertovich         | o   | 151                      | 4                               | Albertovich     | Albertovich       | (N'альбертович', N'Albertovich'),        |
| антонина       | Antonina            | i   | 150                      | 5                               | Antonina        | Antonina          | (N'антонина', N'Antonina'),              |
| михайлов       | Mikhaylov           | f   | 149                      | 6                               | Mikhaylov       | Mikhaylov         | (N'михайлов', N'Mikhaylov'),             |
| ли             | Li                  | f   | 148                      | 4                               | Li              | Li                | (N'ли', N'Li'),                          |
| валентин       | Valentin            | i   | 148                      | 9                               | Valentin        | Valentin          | (N'валентин', N'Valentin'),              |
| ян             | Ian                 | i   | 147                      | 5                               | Jan             | Yan               | (N'ян', N'Ian'),                         |
| регина         | Regina              | i   | 146                      | 5                               | Regina          | Regina            | (N'регина', N'Regina'),                  |
| ковалева       | Kovaleva            | f   | 146                      | 5                               | Kovaleva        | Kovaleva          | (N'ковалева', N'Kovaleva'),              |
| павлов         | Pavlov              | f   | 145                      | 8                               | Pavlov          | Pavlov            | (N'павлов', N'Pavlov'),                  |
| динара         | Dinara              | i   | 141                      | 5                               | Dinara          | Dinara            | (N'динара', N'Dinara'),                  |
| казакова       | Kazakova            | f   | 140                      | 8                               | Kazakova        | Kazakova          | (N'казакова', N'Kazakova'),              |
| козлов         | Kozlov              | f   | 139                      | 6                               | Kozlov          | Kozlov            | (N'козлов', N'Kozlov'),                  |
| федотова       | Fedotova            | f   | 139                      | 4                               | Fedotova        | Fedotova          | (N'федотова', N'Fedotova'),              |
| романов        | Romanov             | f   | 138                      | 11                              | Romanov         | Romanov           | (N'романов', N'Romanov'),                |
| комарова       | Komarova            | f   | 138                      | 4                               | Komarova        | Komarova          | (N'комарова', N'Komarova'),              |
| захаров        | Zakharov            | f   | 138                      | 8                               | Zakharov        | Zakharov          | (N'захаров', N'Zakharov'),               |
| гаврилова      | Gavrilova           | f   | 137                      | 6                               | Gavrilova       | Gavrilova         | (N'гаврилова', N'Gavrilova'),            |
| сидорова       | Sidorova            | f   | 137                      | 4                               | Sidorova        | Sidorova          | (N'сидорова', N'Sidorova'),              |
| исаева         | Isaeva              | f   | 136                      | 8                               | Isaeva          | Isaeva            | (N'исаева', N'Isaeva'),                  |
| осипова        | Osipova             | f   | 135                      | 6                               | Osipova         | Osipova           | (N'осипова', N'Osipova'),                |
| дина           | Dina                | i   | 134                      | 8                               | Dina            | Dina              | (N'дина', N'Dina'),                      |
| андреев        | Andreev             | f   | 132                      | 8                               | Andreev         | Andreev           | (N'андреев', N'Andreev'),                |
| аркадьевич     | Arkadievich         | o   | 131                      | 5                               | Arkadievich     | Arkadyevich       | (N'аркадьевич', N'Arkadievich'),         |
| рената         | Renata              | i   | 131                      | 4                               | Renata          | Renata            | (N'рената', N'Renata'),                  |
| семенов        | Semenov             | f   | 129                      | 5                               | Semenov         | Semenov           | (N'семенов', N'Semenov'),                |
| назарова       | Nazarova            | f   | 128                      | 6                               | Nazarova        | Nazarova          | (N'назарова', N'Nazarova'),              |
| калинина       | Kalinina            | f   | 127                      | 6                               | Kalinina        | Kalinina          | (N'калинина', N'Kalinina'),              |
| коновалова     | Konovalova          | f   | 126                      | 4                               | Konovalova      | Konovalova        | (N'коновалова', N'Konovalova'),          |
| федоров        | Fedorov             | f   | 126                      | 6                               | Fedorov         | Fedorov           | (N'федоров', N'Fedorov'),                |
| лебедев        | Lebedev             | f   | 125                      | 11                              | Lebedev         | Lebedev           | (N'лебедев', N'Lebedev'),                |
| антонова       | Antonova            | f   | 125                      | 10                              | Antonova        | Antonova          | (N'антонова', N'Antonova'),              |
| пономарева     | Ponomareva          | f   | 124                      | 6                               | Ponomareva      | Ponomareva        | (N'пономарева', N'Ponomareva'),          |
| марат          | Marat               | i   | 123                      | 4                               | Marat           | Marat             | (N'марат', N'Marat'),                    |
| алексеев       | Alekseev            | f   | 123                      | 4                               | Alekseev        | Alekseev          | (N'алексеев', N'Alekseev'),              |
| колесникова    | Kolesnikova         | f   | 122                      | 4                               | Kolesnikova     | Kolesnikova       | (N'колесникова', N'Kolesnikova'),        |
| коваленко      | Kovalenko           | f   | 118                      | 6                               | Kovalenko       | Kovalenko         | (N'коваленко', N'Kovalenko'),            |
| ткаченко       | Tkachenko           | f   | 118                      | 4                               | Tkachenko       | Tkachenko         | (N'ткаченко', N'Tkachenko'),             |
| горбунова      | Gorbunova           | f   | 117                      | 4                               | Gorbunova       | Gorbunova         | (N'горбунова', N'Gorbunova'),            |
| виноградова    | Vinogradova         | f   | 117                      | 6                               | Vinogradova     | Vinogradova       | (N'виноградова', N'Vinogradova'),        |
| кравченко      | Kravchenko          | f   | 116                      | 9                               | Kravchenko      | Kravchenko        | (N'кравченко', N'Kravchenko'),           |
| яковлев        | Yakovlev            | f   | 116                      | 6                               | Yakovlev        | Yakovlev          | (N'яковлев', N'Yakovlev'),               |
| орлов          | Orlov               | f   | 116                      | 9                               | Orlov           | Orlov             | (N'орлов', N'Orlov'),                    |
| сергеев        | Sergeev             | f   | 115                      | 4                               | Sergeev         | Sergeev           | (N'сергеев', N'Sergeev'),                |
| герасимова     | Gerasimova          | f   | 115                      | 6                               | Gerasimova      | Gerasimova        | (N'герасимова', N'Gerasimova'),          |
| мадина         | Madina              | i   | 114                      | 4                               | Madina          | Madina            | (N'мадина', N'Madina'),                  |
| щербакова      | Shcherbakova        | f   | 114                      | 4                               | Scherbakova     | Scherbakova       | (N'щербакова', N'Shcherbakova'),         |
| рустам         | Rustam              | i   | 113                      | 6                               | Rustam          | Rustam            | (N'рустам', N'Rustam'),                  |
| тихонова       | Tikhonova           | f   | 112                      | 9                               | Tikhonova       | Tikhonova         | (N'тихонова', N'Tikhonova'),             |
| геннадий       | Gennady             | i   | 112                      | 6                               | Gennady         | Gennady           | (N'геннадий', N'Gennady'),               |
| денисова       | Denisova            | f   | 112                      | 5                               | Denisova        | Denisova          | (N'денисова', N'Denisova'),              |
| егоровна       | Egorovna            | o   | 111                      | 4                               | Egorovna        | Egorovna          | (N'егоровна', N'Egorovna'),              |
| кузьмин        | Kuzmin              | f   | 111                      | 4                               | Kuzmin          | Kuzmin            | (N'кузьмин', N'Kuzmin'),                 |
| альберт        | Albert              | i   | 108                      | 5                               | Albert          | Albert            | (N'альберт', N'Albert'),                 |
| елисеева       | Eliseeva            | f   | 107                      | 8                               | Eliseeva        | Eliseeva          | (N'елисеева', N'Eliseeva'),              |
| мартынова      | Martynova           | f   | 107                      | 4                               | Martynova       | Martynova         | (N'мартынова', N'Martynova'),            |
| матвеева       | Matveeva            | f   | 107                      | 6                               | Matveeva        | Matveeva          | (N'матвеева', N'Matveeva'),              |
| абрамова       | Abramova            | f   | 106                      | 4                               | Abramova        | Abramova          | (N'абрамова', N'Abramova'),              |
| григорьев      | Grigorev            | f   | 105                      | 4                               | Grigorev        | Grigoryev         | (N'григорьев', N'Grigorev'),             |
| ковалев        | Kovalev             | f   | 104                      | 4                               | Kovalev         | Kovalev           | (N'ковалев', N'Kovalev'),                |
| баранов        | Baranov             | f   | 104                      | 4                               | Baranov         | Baranov           | (N'баранов', N'Baranov'),                |
| савина         | Savina              | f   | 104                      | 5                               | Savina          | Savina            | (N'савина', N'Savina'),                  |
| наумова        | Naumova             | f   | 103                      | 4                               | Naumova         | Naumova           | (N'наумова', N'Naumova'),                |
| филатова       | Filatova            | f   | 102                      | 4                               | Filatova        | Filatova          | (N'филатова', N'Filatova'),              |
| тарасов        | Tarasov             | f   | 99                       | 6                               | Tarasov         | Tarasov           | (N'тарасов', N'Tarasov'),                |
| соболева       | Soboleva            | f   | 97                       | 7                               | Soboleva        | Soboleva          | (N'соболева', N'Soboleva'),              |
| афанасьев      | Afanasev            | f   | 97                       | 4                               | Afanasev        | Afanasyev         | (N'афанасьев', N'Afanasev'),             |
| котова         | Kotova              | f   | 97                       | 6                               | Kotova          | Kotova            | (N'котова', N'Kotova'),                  |
| сорокин        | Sorokin             | f   | 96                       | 5                               | Sorokin         | Sorokin           | (N'сорокин', N'Sorokin'),                |
| родионова      | Rodionova           | f   | 95                       | 5                               | Rodionova       | Rodionova         | (N'родионова', N'Rodionova'),            |
| мальцева       | Maltseva            | f   | 94                       | 7                               | Maltseva        | Maltseva          | (N'мальцева', N'Maltseva'),              |
| зоя            | Zoya                | i   | 94                       | 3                               | Zoya            | Zoya              | (N'зоя', N'Zoya'),                       |
| абрамов        | Abramov             | f   | 93                       | 6                               | Abramov         | Abramov           | (N'абрамов', N'Abramov'),                |
| поляков        | Polyakov            | f   | 93                       | 5                               | Polyakov        | Polyakov          | (N'поляков', N'Polyakov'),               |
| алиева         | Alieva              | f   | 92                       | 4                               | Alieva          | Alieva            | (N'алиева', N'Alieva'),                  |
| литвинова      | Litvinova           | f   | 90                       | 6                               | Litvinova       | Litvinova         | (N'литвинова', N'Litvinova'),            |
| филиппов       | Filippov            | f   | 89                       | 7                               | Filippov        | Filippov          | (N'филиппов', N'Filippov'),              |
| кудряшова      | Kudryashova         | f   | 89                       | 4                               | Kudryashova     | Kudryashova       | (N'кудряшова', N'Kudryashova'),          |
| бирюкова       | Biryukova           | f   | 88                       | 4                               | Biryukova       | Biryukova         | (N'бирюкова', N'Biryukova'),             |
| антонов        | Antonov             | f   | 87                       | 4                               | Antonov         | Antonov           | (N'антонов', N'Antonov'),                |
| жуков          | Zhukov              | f   | 86                       | 7                               | Zhukov          | Zhukov            | (N'жуков', N'Zhukov'),                   |
| геннадиевна    | Gennadievna         | o   | 85                       | 4                               | Gennadievna     | Gennadievna       | (N'геннадиевна', N'Gennadievna'),        |
| климова        | Klimova             | f   | 84                       | 5                               | Klimova         | Klimova           | (N'климова', N'Klimova'),                |
| прохорова      | Prokhorova          | f   | 84                       | 4                               | Prokhorova      | Prokhorova        | (N'прохорова', N'Prokhorova'),           |
| катерина       | Katerina            | i   | 83                       | 5                               | Katerina        | Katerina          | (N'катерина', N'Katerina'),              |
| дмитриев       | Dmitriev            | f   | 83                       | 10                              | Dmitriev        | Dmitriev          | (N'дмитриев', N'Dmitriev'),              |
| маркович       | Markovich           | o   | 82                       | 6                               | Markovich       | Markovich         | (N'маркович', N'Markovich'),             |
| савченко       | Savchenko           | f   | 81                       | 4                               | Savchenko       | Savchenko         | (N'савченко', N'Savchenko'),             |
| никулина       | Nikulina            | f   | 81                       | 5                               | Nikulina        | Nikulina          | (N'никулина', N'Nikulina'),              |
| тимофеев       | Timofeev            | f   | 81                       | 5                               | Timofeev        | Timofeev          | (N'тимофеев', N'Timofeev'),              |
| фадеева        | Fadeeva             | f   | 81                       | 6                               | Fadeeva         | Fadeeva           | (N'фадеева', N'Fadeeva'),                |
| давыдов        | Davydov             | f   | 81                       | 5                               | Davydov         | Davydov           | (N'давыдов', N'Davydov'),                |
| карпов         | Karpov              | f   | 80                       | 5                               | Karpov          | Karpov            | (N'карпов', N'Karpov'),                  |
| архипова       | Arkhipova           | f   | 80                       | 4                               | Arkhipova       | Arkhipova         | (N'архипова', N'Arkhipova'),             |
| максимов       | Maksimov            | f   | 80                       | 5                               | Maksimov        | Maksimov          | (N'максимов', N'Maksimov'),              |
| лысенко        | Lysenko             | f   | 80                       | 5                               | Lysenko         | Lysenko           | (N'лысенко', N'Lysenko'),                |
| медведев       | Medvedev            | f   | 80                       | 10                              | Medvedev        | Medvedev          | (N'медведев', N'Medvedev'),              |
| назаров        | Nazarov             | f   | 79                       | 5                               | Nazarov         | Nazarov           | (N'назаров', N'Nazarov'),                |
| михеева        | Mikheeva            | f   | 79                       | 5                               | Mikheeva        | Mikheeva          | (N'михеева', N'Mikheeva'),               |
| яков           | Yakov               | i   | 78                       | 5                               | Yakov           | Yakov             | (N'яков', N'Yakov'),                     |
| белоусова      | Belousova           | f   | 78                       | 4                               | Belousova       | Belousova         | (N'белоусова', N'Belousova'),            |
| казаков        | Kazakov             | f   | 78                       | 7                               | Kazakov         | Kazakov           | (N'казаков', N'Kazakov'),                |
| алевтина       | Alevtina            | i   | 77                       | 4                               | Alevtina        | Alevtina          | (N'алевтина', N'Alevtina'),              |
| марковна       | Markovna            | o   | 77                       | 4                               | Markovna        | Markovna          | (N'марковна', N'Markovna'),              |
| зотова         | Zotova              | f   | 76                       | 1                               | Zotova          | Zotova            | (N'зотова', N'Zotova'),                  |
| демидова       | Demidova            | f   | 75                       | 7                               | Demidova        | Demidova          | (N'демидова', N'Demidova'),              |
| яковлевич      | Yakovlevich         | o   | 75                       | 8                               | Yakovlevich     | Yakovlevich       | (N'яковлевич', N'Yakovlevich'),          |
| тихонов        | Tikhonov            | f   | 74                       | 6                               | Tikhonov        | Tikhonov          | (N'тихонов', N'Tikhonov'),               |
| эльмира        | Elmira              | i   | 73                       | 6                               | Elmira          | Elmira            | (N'эльмира', N'Elmira'),                 |
| галкина        | Galkina             | f   | 73                       | 7                               | Galkina         | Galkina           | (N'галкина', N'Galkina'),                |
| гордеева       | Gordeeva            | f   | 73                       | 4                               | Gordeeva        | Gordeeva          | (N'гордеева', N'Gordeeva'),              |
| калинин        | Kalinin             | f   | 71                       | 5                               | Kalinin         | Kalinin           | (N'калинин', N'Kalinin'),                |
| исаев          | Isaev               | f   | 71                       | 7                               | Isaev           | Isaev             | (N'исаев', N'Isaev'),                    |
| громова        | Gromova             | f   | 68                       | 5                               | Gromova         | Gromova           | (N'громова', N'Gromova'),                |
| куликов        | Kulikov             | f   | 67                       | 5                               | Kulikov         | Kulikov           | (N'куликов', N'Kulikov'),                |
| германович     | Germanovich         | o   | 67                       | 6                               | Germanovich     | Germanovich       | (N'германович', N'Germanovich'),         |
| марианна       | Marianna            | i   | 66                       | 4                               | Marianna        | Marianna          | (N'марианна', N'Marianna'),              |
| павленко       | Pavlenko            | f   | 65                       | 4                               | Pavlenko        | Pavlenko          | (N'павленко', N'Pavlenko'),              |
| левина         | Levina              | f   | 65                       | 4                               | Levina          | Levina            | (N'левина', N'Levina'),                  |
| левченко       | Levchenko           | f   | 64                       | 4                               | Levchenko       | Levchenko         | (N'левченко', N'Levchenko'),             |
| денисов        | Denisov             | f   | 63                       | 5                               | Denisov         | Denisov           | (N'денисов', N'Denisov'),                |
| зуева          | Zueva               | f   | 63                       | 4                               | Zueva           | Zueva             | (N'зуева', N'Zueva'),                    |
| фокина         | Fokina              | f   | 63                       | 4                               | Fokina          | Fokina            | (N'фокина', N'Fokina'),                  |
| романенко      | Romanenko           | f   | 62                       | 4                               | Romanenko       | Romanenko         | (N'романенко', N'Romanenko'),            |
| федотов        | Fedotov             | f   | 61                       | 5                               | Fedotov         | Fedotov           | (N'федотов', N'Fedotov'),                |
| шилова         | Shilova             | f   | 60                       | 5                               | Shilova         | Shilova           | (N'шилова', N'Shilova'),                 |
| майорова       | Mayorova            | f   | 60                       | 4                               | Mayorova        | Mayorova          | (N'майорова', N'Mayorova'),              |
| ларионова      | Larionova           | f   | 60                       | 4                               | Larionova       | Larionova         | (N'ларионова', N'Larionova'),            |
| горбунов       | Gorbunov            | f   | 60                       | 5                               | Gorbunov        | Gorbunov          | (N'горбунов', N'Gorbunov'),              |
| бочарова       | Bocharova           | f   | 59                       | 6                               | Bocharova       | Bocharova         | (N'бочарова', N'Bocharova'),             |
| авдеева        | Avdeeva             | f   | 59                       | 4                               | Avdeeva         | Avdeeva           | (N'авдеева', N'Avdeeva'),                |
| зорина         | Zorina              | f   | 59                       | 2                               | Zorina          | Zorina            | (N'зорина', N'Zorina'),                  |
| шабанова       | Shabanova           | f   | 58                       | 6                               | Shabanova       | Shabanova         | (N'шабанова', N'Shabanova'),             |
| федоренко      | Fedorenko           | f   | 58                       | 5                               | Fedorenko       | Fedorenko         | (N'федоренко', N'Fedorenko'),            |
| тарасенко      | Tarasenko           | f   | 57                       | 5                               | Tarasenko       | Tarasenko         | (N'тарасенко', N'Tarasenko'),            |
| пономарев      | Ponomarev           | f   | 57                       | 5                               | Ponomarev       | Ponomarev         | (N'пономарев', N'Ponomarev'),            |
| крылов         | Krylov              | f   | 57                       | 4                               | Krylov          | Krylov            | (N'крылов', N'Krylov'),                  |
| котов          | Kotov               | f   | 57                       | 6                               | Kotov           | Kotov             | (N'котов', N'Kotov'),                    |
| молчанова      | Molchanova          | f   | 56                       | 5                               | Molchanova      | Molchanova        | (N'молчанова', N'Molchanova'),           |
| логинов        | Loginov             | f   | 55                       | 4                               | Loginov         | Loginov           | (N'логинов', N'Loginov'),                |
| серова         | Serova              | f   | 54                       | 5                               | Serova          | Serova            | (N'серова', N'Serova'),                  |
| шестакова      | Shestakova          | f   | 54                       | 4                               | Shestakova      | Shestakova        | (N'шестакова', N'Shestakova'),           |
| еременко       | Eremenko            | f   | 54                       | 4                               | Eremenko        | Eremenko          | (N'еременко', N'Eremenko'),              |
| клименко       | Klimenko            | f   | 53                       | 6                               | Klimenko        | Klimenko          | (N'клименко', N'Klimenko'),              |
| ася            | Asya                | i   | 53                       | 2                               | Asya            | Asya              | (N'ася', N'Asya'),                       |
| митрофанова    | Mitrofanova         | f   | 53                       | 4                               | Mitrofanova     | Mitrofanova       | (N'митрофанова', N'Mitrofanova'),        |
| мирошниченко   | Miroshnichenko      | f   | 52                       | 4                               | Miroshnichenko  | Miroshnichenko    | (N'мирошниченко', N'Miroshnichenko'),    |
| инга           | Inga                | i   | 52                       | 5                               | Inga            | Inga              | (N'инга', N'Inga'),                      |
| кузина         | Kuzina              | f   | 52                       | 5                               | Kuzina          | Kuzina            | (N'кузина', N'Kuzina'),                  |
| левин          | Levin               | f   | 52                       | 4                               | Levin           | Levin             | (N'левин', N'Levin'),                    |
| кулакова       | Kulakova            | f   | 52                       | 4                               | Kulakova        | Kulakova          | (N'кулакова', N'Kulakova'),              |
| зверева        | Zvereva             | f   | 52                       | 5                               | Zvereva         | Zvereva           | (N'зверева', N'Zvereva'),                |
| зубкова        | Zubkova             | f   | 51                       | 4                               | Zubkova         | Zubkova           | (N'зубкова', N'Zubkova'),                |
| хохлов         | Khokhlov            | f   | 51                       | 4                               | Khokhlov        | Khokhlov          | (N'хохлов', N'Khokhlov'),                |
| соболев        | Sobolev             | f   | 51                       | 5                               | Sobolev         | Sobolev           | (N'соболев', N'Sobolev'),                |
| устинова       | Ustinova            | f   | 50                       | 4                               | Ustinova        | Ustinova          | (N'устинова', N'Ustinova'),              |
| платонова      | Platonova           | f   | 50                       | 4                               | Platonova       | Platonova         | (N'платонова', N'Platonova'),            |
| андрианова     | Andrianova          | f   | 49                       | 5                               | Andrianova      | Andrianova        | (N'андрианова', N'Andrianova'),          |
| горбачева      | Gorbacheva          | f   | 48                       | 5                               | Gorbacheva      | Gorbacheva        | (N'горбачева', N'Gorbacheva'),           |
| шишкин         | Shishkin            | f   | 48                       | 4                               | Shishkin        | Shishkin          | (N'шишкин', N'Shishkin'),                |
| гузель         | Guzel               | i   | 47                       | 4                               | Guzel           | Guzel             | (N'гузель', N'Guzel'),                   |
| комаров        | Komarov             | f   | 47                       | 5                               | Komarov         | Komarov           | (N'комаров', N'Komarov'),                |
| панов          | Panov               | f   | 45                       | 7                               | Panov           | Panov             | (N'панов', N'Panov'),                    |
| сафронов       | Safronov            | f   | 45                       | 4                               | Safronov        | Safronov          | (N'сафронов', N'Safronov'),              |
| красильникова  | Krasilnikova        | f   | 44                       | 4                               | Krasilnikova    | Krasilnikova      | (N'красильникова', N'Krasilnikova'),     |
| грачева        | Gracheva            | f   | 44                       | 5                               | Gracheva        | Gracheva          | (N'грачева', N'Gracheva'),               |
| галкин         | Galkin              | f   | 42                       | 4                               | Galkin          | Galkin            | (N'галкин', N'Galkin'),                  |
| громов         | Gromov              | f   | 41                       | 5                               | Gromov          | Gromov            | (N'громов', N'Gromov'),                  |
| ренат          | Renat               | i   | 40                       | 4                               | Renat           | Renat             | (N'ренат', N'Renat'),                    |
| вишнякова      | Vishnyakova         | f   | 39                       | 4                               | Vishnyakova     | Vishnyakova       | (N'вишнякова', N'Vishnyakova'),          |
| казанцев       | Kazantsev           | f   | 38                       | 5                               | Kazantsev       | Kazantsev         | (N'казанцев', N'Kazantsev'),             |
| минина         | Minina              | f   | 38                       | 5                               | Minina          | Minina            | (N'минина', N'Minina'),                  |
| харитонов      | Kharitonov          | f   | 38                       | 5                               | Kharitonov      | Kharitonov        | (N'харитонов', N'Kharitonov'),           |
| зинченко       | Zinchenko           | f   | 37                       | 5                               | Zinchenko       | Zinchenko         | (N'зинченко', N'Zinchenko'),             |
| богомолова     | Bogomolova          | f   | 36                       | 4                               | Bogomolova      | Bogomolova        | (N'богомолова', N'Bogomolova'),          |
| сизова         | Sizova              | f   | 36                       | 4                               | Sizova          | Sizova            | (N'сизова', N'Sizova'),                  |
| ахмедова       | Akhmedova           | f   | 35                       | 5                               | Akhmedova       | Akhmedova         | (N'ахмедова', N'Akhmedova'),             |
| мироненко      | Mironenko           | f   | 34                       | 4                               | Mironenko       | Mironenko         | (N'мироненко', N'Mironenko'),            |
| рубцов         | Rubtsov             | f   | 32                       | 4                               | Rubtsov         | Rubtsov           | (N'рубцов', N'Rubtsov'),                 |
| ефим           | Efim                | i   | 29                       | 4                               | Efim            | Efim              | (N'ефим', N'Efim'),                      |
| кабанов        | Kabanov             | f   | 29                       | 6                               | Kabanov         | Kabanov           | (N'кабанов', N'Kabanov'),                |
| мясникова      | Myasnikova          | f   | 28                       | 4                               | Myasnikova      | Myasnikova        | (N'мясникова', N'Myasnikova'),           |
| стрельникова   | Strelnikova         | f   | 28                       | 5                               | Strelnikova     | Strelnikova       | (N'стрельникова', N'Strelnikova'),       |
| нефедов        | Nefedov             | f   | 27                       | 4                               | Nefedov         | Nefedov           | (N'нефедов', N'Nefedov'),                |
| рыбаков        | Rybakov             | f   | 25                       | 6                               | Rybakov         | Rybakov           | (N'рыбаков', N'Rybakov'),                |
| мезенцева      | Mezentseva          | f   | 24                       | 4                               | Mezentseva      | Mezentseva        | (N'мезенцева', N'Mezentseva'),           |
| лавров         | Lavrov              | f   | 24                       | 4                               | Lavrov          | Lavrov            | (N'лавров', N'Lavrov'),                  |
| баженов        | Bazhenov            | f   | 24                       | 4                               | Bazhenov        | Bazhenov          | (N'баженов', N'Bazhenov'),               |
| кондрашов      | Kondrashov          | f   | 21                       | 4                               | Kondrashov      | Kondrashov        | (N'кондрашов', N'Kondrashov'),           |
| шапошников     | Shaposhnikov        | f   | 21                       | 4                               | Shaposhnikov    | Shaposhnikov      | (N'шапошников', N'Shaposhnikov'),        |
| гаврилина      | Gavrilina           | f   | 20                       | 5                               | Gavrilina       | Gavrilina         | (N'гаврилина', N'Gavrilina'),            |
| коршунов       | Korshunov           | f   | 19                       | 4                               | Korshunov       | Korshunov         | (N'коршунов', N'Korshunov'),             |
| косарев        | Kosarev             | f   | 19                       | 5                               | Kosarev         | Kosarev           | (N'косарев', N'Kosarev'),                |
| трофименко     | Trofimenko          | f   | 19                       | 4                               | Trofimenko      | Trofimenko        | (N'трофименко', N'Trofimenko'),          |
| якушев         | Yakushev            | f   | 17                       | 4                               | Yakushev        | Yakushev          | (N'якушев', N'Yakushev'),                |
| пучков         | Puchkov             | f   | 15                       | 4                               | Puchkov         | Puchkov           | (N'пучков', N'Puchkov'),                 |
| банников       | Bannikov            | f   | 15                       | 5                               | Bannikov        | Bannikov          | (N'банников', N'Bannikov'),              |
| багаутдинова   | Bagautdinova        | f   | 13                       | 4                               | Bagautdinova    | Bagautdinova      | (N'багаутдинова', N'Bagautdinova'),      |
| бэла           | Bela                | i   | 11                       | 4                               | Bela            | Bela              | (N'бэла', N'Bela'),                      |
| дэвид          | David               | i   | 11                       | 4                               | David           | Devid             | (N'дэвид', N'David'),                    |
| подкопаев      | Podkopaev           | f   | 8                        | 4                               | Podkopaev       | Podkopaev         | (N'подкопаев', N'Podkopaev'),            |
| эндрю          | Andrew              | o   | 5                        | 4                               | Andrew          | Endryu            | (N'эндрю', N'Andrew'),                   |
</details>

## Реализация транслитерации

Транслитерация реализована в виде одной строки с replace (сформирована построчно в Excel - [Побуквенная транслитерация.xlsx](/download/attachments/81443936/%D0%9F%D0%BE%D0%B1%D1%83%D0%BA%D0%B2%D0%B5%D0%BD%D0%BD%D0%B0%D1%8F%20%D1%82%D1%80%D0%B0%D0%BD%D1%81%D0%BB%D0%B8%D1%82%D0%B5%D1%80%D0%B0%D1%86%D0%B8%D1%8F.xlsx?version=1&modificationDate=1633443350307&api=v2)) и протестирована нижеследующим скриптом (по заранее известным транслитам):

**Реализация транслитерации мосметро** 

<details>
  <summary>Развернуть исходный код</summary>

```sql
select
entity,
iif(lower(tnsl) =
-- Алгоритм транслитерации - строчка ниже
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(iif(SUBSTRING(entity,len(entity)-1,2)=N'ий' or SUBSTRING(entity,len(entity)-1,2)=N'ый',concat(SUBSTRING(entity,1,len(entity)-2),'y'),entity),N'ый ',N'y '),N'ий ',N'y '),N'ьё',N'ьyo'),N'ъё',N'ъyo'),N'ё',N'е'),N'тц',N'тs'),N'ьа',N'yа'),N'ье',N'yе'),N'ьи',N'yи'),N'ьо',N'yо'),N'ьу',N'yу'),N'ьэ',N'yэ'),N'ъа',N'yа'),N'ъе',N'yе'),N'ъи',N'yи'),N'ъо',N'yо'),N'ъу',N'yу'),N'ъэ',N'yэ'),N'а',N'a'),N'б',N'b'),N'в',N'v'),N'г',N'g'),N'д',N'd'),N'е',N'e'),N'ж',N'zh'),N'з',N'z'),N'и',N'i'),N'й',N'y'),N'к',N'k'),N'л',N'l'),N'м',N'm'),N'н',N'n'),N'о',N'o'),N'п',N'p'),N'р',N'r'),N'с',N's'),N'т',N't'),N'у',N'u'),N'ф',N'f'),N'х',N'kh'),N'ц',N'ts'),N'ч',N'ch'),N'ш',N'sh'),N'щ',N'sch'),N'ъ',N''),N'ы',N'y'),N'ь',N''),N'э',N'e'),N'ю',N'yu'),N'я',N'ya')
,N'Транслитерация совпадает',N'Транслитерация НЕ совпадает')
as N'Проверка'
  
FROM
  (
    Values
    (N'Битцевский парк', N'Bitsevsky park'), (N'Верхние Лихоборы', N'Verkhnie Likhobory'), (N'Воробьёвы горы', N'Vorobyovy gory'), (N'Выхино', N'Vykhino'), (N'Зябликово', N'Zyablikovo'), (N'Измайловская', N'Izmaylovskaya'), (N'Кожуховская', N'Kozhukhovskaya'), (N'Крылатское', N'Krylatskoe'), (N'Марьина Роща', N'Maryina Roscha'), (N'Марьино', N'Maryino'), (N'Молодёжная', N'Molodezhnaya'), (N'Октябрьская', N'Oktyabrskaya'), (N'Ольховая', N'Olkhovaya'), (N'Парк Победы', N'Park Pobedy'), (N'Площадь Ильича', N'Ploschad Ilyicha'), (N'Площадь Революции', N'Ploschad Revolyutsii'), (N'Пятницкое шоссе', N'Pyatnitskoe shosse'), (N'Румянцево', N'Rumyantsevo'), (N'Саларьево', N'Salaryevo'), (N'Семёновская', N'Semenovskaya'), (N'Сходненская', N'Skhodnenskaya'), (N'Текстильщики', N'Tekstilschiki'), (N'Тёплый стан', N'Teply stan'), (N'Третьяковская', N'Tretyakovskaya'), (N'Тропарёво', N'Troparevo'), (N'Фонвизинская', N'Fonvizinskaya'), (N'Чистые пруды', N'Chistye prudy'), (N'Шоссе Энтузиастов', N'Shosse Entuziastov'), (N'Щёлковская', N'Schelkovskaya'), (N'Электрозаводская', N'Elektrozavodskaya'), (N'Юго-Западная', N'Yugo-Zapadnaya'), (N'Юлия, съешь ещё этих мягких французских булок из Йошкар-Олы, да выпей алтайского чаю', N'Yuliya, syesh esche etikh myagkikh frantsuzskikh bulok iz Yoshkar-Oly, da vypey altayskogo chayu')
  ) AS TempTableName ( entity, tnsl )
 ```
 </details>

## Дополнительные функции и зависимости

Для работы скрипта использована дополнительная функция, которая делает заглавной каждую первую букву (на случай двойных фамилий и имён)

**InitCap** 
<details>
  <summary>Развернуть исходный код</summary>

```sql
-- http://www.sql-server-helper.com/functions/initcap.aspx
-- Начинает каждое первое слово с заглавной буквы
CREATE FUNCTION [dbo].[SA_fn_InitCap] ( @InputString varchar(4000) )
RETURNS VARCHAR(4000)
AS
BEGIN
 
DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @OutputString   VARCHAR(255)
 
SET @OutputString = LOWER(@InputString)
SET @Index = 1
 
WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END
 
    IF @PrevChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @PrevChar != '''' OR UPPER(@Char) != 'S'
            SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
    END
 
    SET @Index = @Index + 1
END
 
RETURN @OutputString
 
END
GO
```
</details>

## Скрипт

**Скрипт-транслитератор** 
<details>
  <summary>Развернуть исходный код</summary>

  ```sql
/*
Скрипт-транслитератор базы SA
*/
 
 
-- добавление колонок ФИО, приведённых к нижнему регистру и очищенных от табуляций, точек, неразрывных и лишних пробелов, необычных букв Ё
WITH sa1
AS (
    SELECT [id], [last_name] AS 'Фамилия', [first_name] AS 'Имя', [surname] AS 'Отчество',
    iif([last_name] = '-', '', lower(trim(replace(replace(replace(replace(isnull([last_name], ''), CHAR(9), ''), CHAR(160), ' '), 'ë', N'ё'), '.', '')))) AS 'Фамилия_е',
    iif([first_name] = '-', '', lower(trim(replace(replace(replace(replace(isnull([first_name], ''), CHAR(9), ''), CHAR(160), ' '), 'ë', N'ё'), '.', '')))) AS 'Имя_е',
    iif([surname] = '-', '', lower(trim(replace(replace(replace(replace(isnull([surname], ''), CHAR(9), ''), CHAR(160), ' '), 'ë', N'ё'), '.', '')))) AS 'Отчество_е',
    replace(replace(isnull([last_name_en], ''), CHAR(9), ''), CHAR(160), ' ') AS 'Фамилия_en',
    replace(replace(isnull([first_name_en], ''), CHAR(9), ''), CHAR(160), ' ') AS 'Имя_en',
    replace(replace(isnull([surname_en], ''), CHAR(9), ''), CHAR(160), ' ') AS 'Отчество_en'
    FROM [SA].[dbo].[SA_Users]
    ), dir_trans
-- таблица справочных транслитераций
AS (
    SELECT *
    FROM (
        VALUES (N'александр', N'Alexander'), (N'александра', N'Alexandra'), (N'александрова', N'Aleksandrova'), (N'александрович', N'Aleksandrovich'), (N'александровна', N'Aleksandrovna'), (N'алексеева', N'Alekseeva'), (N'алексеевич', N'Alekseevich'), (N'алексеевна', N'Alekseevna'), (N'алексей', N'Alexey'), (N'алена', N'Alyona'), (N'алёна', N'Alyona'), (N'алина', N'Alina'), (N'алиса', N'Alisa'), (N'алла', N'Alla'), (N'альбертовна', N'Albertovna'), (N'альбина', N'Albina'), (N'анастасия', N'Anastasia'), (N'анатолий', N'Anatoly'), (N'анатольевич', N'Anatolievich'), (N'анатольевна', N'Anatolievna'), (N'ангелина', N'Angelina'), (N'андреева', N'Andreeva'), (N'андреевич', N'Andreevich'), (N'андреевна', N'Andreevna'), (N'андрей', N'Andrey'), (N'анжелика', N'Angelika'
            ), (N'анна', N'Anna'), (N'антон', N'Anton'), (N'антонович', N'Antonovich'), (N'антоновна', N'Antonovna'), (N'арина', N'Arina'), (N'аркадьевна', N'Arkadievna'), (N'арсений', N'Arseny'), (N'артем', N'Artyom'), (N'артём', N'Artyom'), (N'артемовна', N'Artyomovna'), (N'артур', N'Artur'), (N'артурович', N'Arturovich'), (N'артуровна', N'Arturovna'), (N'белова', N'Belova'), (N'богдан', N'Bogdan'), (N'борис', N'Boris'), (N'борисова', N'Borisova'), (N'борисович', N'Borisovich'), (N'борисовна', N'Borisovna'), (N'вадим', N'Vadim'), (N'вадимович', N'Vadimovich'), (N'вадимовна', N'Vadimovna'), (N'валентина', N'Valentina'), (N'валентинович', N'Valentinovich'), (N'валентиновна', N'Valentinovna'), (N'валерий', N'Valery'), (N'валерия', N'Valeria'
            ), (N'валерьевич', N'Valerievich'), (N'валерьевна', N'Valerievna'), (N'варвара', N'Varvara'), (N'василий', N'Vasily'), (N'василиса', N'Vasilisa'), (N'васильева', N'Vasilieva'), (N'васильевич', N'Vasilievich'), (N'васильевна', N'Vasilievna'), (N'вера', N'Vera'), (N'вероника', N'Veronika'), (N'виктор', N'Victor'), (N'виктория', N'Victoria'), (N'викторович', N'Viktorovich'), (N'викторовна', N'Viktorovna'), (N'виолетта', N'Violetta'), (N'виталий', N'Vitaly'), (N'витальевич', N'Vitalievich'), (N'витальевна', N'Vitalievna'), (N'влада', N'Vlada'), (N'владимир', N'Vladimir'), (N'владимирович', N'Vladimirovich'), (N'владимировна', N'Vladimirovna'), (N'владислав', N'Vladislav'), (N'владиславович', N'Vladislavovich'), (N'владиславовна', N'Vladislavovna'
            ), (N'власова', N'Vlasova'), (N'волков', N'Volkov'), (N'волкова', N'Volkova'), (N'всеволод', N'Vsevolod'), (N'вячеслав', N'Vyacheslav'), (N'вячеславович', N'Vyacheslavovich'), (N'вячеславовна', N'Vyacheslavovna'), (N'галина', N'Galina'), (N'геннадьевич', N'Gennadievich'), (N'геннадьевна', N'Gennadievna'), (N'георгиевич', N'Georgievich'), (N'георгиевна', N'Georgievna'), (N'георгий', N'Georgy'), (N'герман', N'German'), (N'глеб', N'Gleb'), (N'григорий', N'Grigory'), (N'григорьева', N'Grigorieva'), (N'григорьевич', N'Grigorievich'), (N'григорьевна', N'Grigorievna'), (N'давид', N'David'), (N'даниил', N'Daniil'), (N'данил', N'Danil'), (N'данила', N'Danila'), (N'дарина', N'Darina'), (N'дарья', N'Daria'), (N'денис', N'Denis')
            , (N'денисович', N'Denisovich'), (N'денисовна', N'Denisovna'), (N'диана', N'Diana'), (N'дмитриева', N'Dmitrieva'), (N'дмитриевич', N'Dmitrievich'), (N'дмитриевна', N'Dmitrievna'), (N'дмитрий', N'Dmitry'), (N'ева', N'Eva'), (N'евгений', N'Evgeny'), (N'евгения', N'Evgeniya'), (N'евгеньевич', N'Evgenievich'), (N'евгеньевна', N'Evgenievna'), (N'егор', N'Egor'), (N'егорова', N'Egorova'), (N'екатерина', N'Ekaterina'), (N'елена', N'Elena'), (N'елизавета', N'Elizaveta'), (N'жанна', N'Zhanna'), (N'зайцева', N'Zaitseva'), (N'захарова', N'Zakharova'), (N'злата', N'Zlata'), (N'иван', N'Ivan'), (N'иванов', N'Ivanov'), (N'иванова', N'Ivanova'), (N'иванович', N'Ivanovich'), (N'ивановна', N'Ivanovna'), (N'игоревич', N'Igorevich'
            ), (N'игоревна', N'Igorevna'), (N'игорь', N'Igor'), (N'ильдаровна', N'Ildarovna'), (N'ильинична', N'Ilinichna'), (N'ильич', N'Ilyich'), (N'илья', N'Ilya'), (N'инна', N'Inna'), (N'ирина', N'Irina'), (N'камилла', N'Kamilla'), (N'карина', N'Karina'), (N'ким', N'Kim'), (N'кира', N'Kira'), (N'кирилл', N'Kirill'), (N'кириллович', N'Kirillovich'), (N'кирилловна', N'Kirillovna'), (N'киселева', N'Kiseleva'), (N'козлова', N'Kozlova'), (N'константин', N'Konstantin'), (N'константинович', N'Konstantinovich'), (N'константиновна', N'Konstantinovna'), (N'королева', N'Koroleva'), (N'кристина', N'Kristina'), (N'ксения', N'Ksenia'), (N'кузнецов', N'Kuznetsov'), (N'кузнецова', N'Kuznetsova'), (N'кузьмина', N'Kuzmina'), (N'лада', N'Lada'
            ), (N'лариса', N'Larisa'), (N'лебедева', N'Lebedeva'), (N'лев', N'Lev'), (N'леонид', N'Leonid'), (N'леонидович', N'Leonidovich'), (N'леонидовна', N'Leonidovna'), (N'лидия', N'Lidia'), (N'лилия', N'Lilia'), (N'львовна', N'Lvovna'), (N'любовь', N'Liubov'), (N'людмила', N'Liudmila'), (N'майя', N'Maya'), (N'макарова', N'Makarova'), (N'максим', N'Maksim'), (N'максимова', N'Maksimova'), (N'максимович', N'Maksimovich'), (N'маратович', N'Maratovich'), (N'маратовна', N'Maratovna'), (N'маргарита', N'Margarita'), (N'марина', N'Marina'), (N'мария', N'Maria'), (N'марк', N'Mark'), (N'матвей', N'Matvey'), (N'медведева', N'Medvedeva'), (N'милана', N'Milana'), (N'милена', N'Milena'), (N'михаил', N'Mikhail'), (N'михайлова', N'Mikhailova'
            ), (N'михайлович', N'Mikhailovich'), (N'михайловна', N'Mikhailovna'), (N'морозов', N'Morozov'), (N'морозова', N'Morozova'), (N'надежда', N'Nadezhda'), (N'наталия', N'Natalia'), (N'наталья', N'Natalia'), (N'никита', N'Nikita'), (N'никитина', N'Nikitina'), (N'николаева', N'Nikolaeva'), (N'николаевич', N'Nikolaevich'), (N'николаевна', N'Nikolaevna'), (N'николай', N'Nikolay'), (N'нина', N'Nina'), (N'новиков', N'Novikov'), (N'новикова', N'Novikova'), (N'оксана', N'Oksana'), (N'олег', N'Oleg'), (N'олегович', N'Olegovich'), (N'олеговна', N'Olegovna'), (N'олеся', N'Olesya'), (N'ольга', N'Olga'), (N'орлова', N'Orlova'), (N'павел', N'Pavel'), (N'павлова', N'Pavlova'), (N'павлович', N'Pavlovich'), (N'павловна', N'Pavlovna'
            ), (N'петр', N'Petr'), (N'пётр', N'Pyotr'), (N'петров', N'Petrov'), (N'петрова', N'Petrova'), (N'петрович', N'Petrovich'), (N'петровна', N'Petrovna'), (N'полина', N'Polina'), (N'попов', N'Popov'), (N'попова', N'Popova'), (N'ринатовна', N'Rinatovna'), (N'роман', N'Roman'), (N'романова', N'Romanova'), (N'романович', N'Romanovich'), (N'романовна', N'Romanovna'), (N'руслан', N'Ruslan'), (N'русланович', N'Ruslanovich'), (N'сабина', N'Sabina'), (N'светлана', N'Svetlana'), (N'семен', N'Semyon'), (N'семён', N'Semyon'), (N'семенова', N'Semenova'), (N'сергеева', N'Sergeyeva'), (N'сергеевич', N'Sergeyevich'), (N'сергеевна', N'Sergeyevna'), (N'сергей', N'Sergey'), (N'смирнов', N'Smirnov'), (N'смирнова', N'Smirnova'), (N'соколов', N'Sokolov'
            ), (N'соколова', N'Sokolova'), (N'соловьева', N'Solovyova'), (N'сорокина', N'Sorokina'), (N'софия', N'Sofia'), (N'софья', N'Sofya'), (N'станислав', N'Stanislav'), (N'станиславович', N'Stanislavovich'), (N'станиславовна', N'Stanislavovna'), (N'степан', N'Stepan'), (N'степанова', N'Stepanova'), (N'таисия', N'Taisia'), (N'тамара', N'Tamara'), (N'тарасова', N'Tarasova'), (N'татьяна', N'Tatiana'), (N'тимофей', N'Timofey'), (N'тимур', N'Timur'), (N'тимуровна', N'Timurovna'), (N'ульяна', N'Uliana'), (N'федор', N'Fedor'), (N'фёдор', N'Fyodor'), (N'федорова', N'Fyodorova'), (N'федоровна', N'Fyodorovna'), (N'филипп', N'Filipp'), (N'филиппова', N'Filippova'), (N'фролова', N'Frolova'), (N'шевченко', N'Shevchenko'), (N'эвелина', N'Evelina'
            ), (N'эдуард', N'Eduard'), (N'эдуардович', N'Eduardovich'), (N'эдуардовна', N'Eduardovna'), (N'элина', N'Elina'), (N'эльвира', N'Elvira'), (N'юлия', N'Yulia'), (N'юрий', N'Yury'), (N'юрьевич', N'Yurievich'), (N'юрьевна', N'Yurievna'), (N'яковлева', N'Yakovleva'), (N'яна', N'Yana'), (N'ярослав', N'Yaroslav'), (N'абрамов', N'Abramov'), (N'абрамова', N'Abramova'), (N'авдеева', N'Avdeeva'), (N'алевтина', N'Alevtina'), (N'алексеев', N'Alekseev'), (N'алиева', N'Alieva'), (N'альберт', N'Albert'), (N'альбертович', N'Albertovich'), (N'андреев', N'Andreev'), (N'андрианова', N'Andrianova'), (N'антонина', N'Antonina'), (N'антонов', N'Antonov'), (N'антонова', N'Antonova'), (N'аркадьевич', N'Arkadievich'), (N'архипова', N'Arkhipova'
            ), (N'ася', N'Asya'), (N'афанасьев', N'Afanasev'), (N'ахмедова', N'Akhmedova'), (N'багаутдинова', N'Bagautdinova'), (N'баженов', N'Bazhenov'), (N'банников', N'Bannikov'), (N'баранов', N'Baranov'), (N'баранова', N'Baranova'), (N'белоусова', N'Belousova'), (N'бирюкова', N'Biryukova'), (N'богомолова', N'Bogomolova'), (N'бондаренко', N'Bondarenko'), (N'бочарова', N'Bocharova'), (N'бэла', N'Bela'), (N'валентин', N'Valentin'), (N'виноградова', N'Vinogradova'), (N'вишнякова', N'Vishnyakova'), (N'гаврилина', N'Gavrilina'), (N'гаврилова', N'Gavrilova'), (N'галкин', N'Galkin'), (N'галкина', N'Galkina'), (N'геннадиевна', N'Gennadievna'), (N'геннадий', N'Gennady'), (N'герасимова', N'Gerasimova'), (N'германович', N'Germanovich'), (N'горбачева', N'Gorbacheva'
            ), (N'горбунов', N'Gorbunov'), (N'горбунова', N'Gorbunova'), (N'гордеева', N'Gordeeva'), (N'грачева', N'Gracheva'), (N'григорьев', N'Grigorev'), (N'громов', N'Gromov'), (N'громова', N'Gromova'), (N'гузель', N'Guzel'), (N'гусева', N'Guseva'), (N'давыдов', N'Davydov'), (N'демидова', N'Demidova'), (N'денисов', N'Denisov'), (N'денисова', N'Denisova'), (N'дина', N'Dina'), (N'динара', N'Dinara'), (N'дмитриев', N'Dmitriev'), (N'дэвид', N'David'), (N'егоровна', N'Egorovna'), (N'елисеева', N'Eliseeva'), (N'еременко', N'Eremenko'), (N'ефим', N'Efim'), (N'жуков', N'Zhukov'), (N'жукова', N'Zhukova'), (N'захаров', N'Zakharov'), (N'зверева', N'Zvereva'), (N'зинченко', N'Zinchenko'), (N'зорина', N'Zorina'), (N'зотова', N'Zotova'
            ), (N'зоя', N'Zoya'), (N'зубкова', N'Zubkova'), (N'зуева', N'Zueva'), (N'инга', N'Inga'), (N'исаев', N'Isaev'), (N'исаева', N'Isaeva'), (N'кабанов', N'Kabanov'), (N'казаков', N'Kazakov'), (N'казакова', N'Kazakova'), (N'казанцев', N'Kazantsev'), (N'калинин', N'Kalinin'), (N'калинина', N'Kalinina'), (N'карпов', N'Karpov'), (N'карпова', N'Karpova'), (N'катерина', N'Katerina'), (N'клименко', N'Klimenko'), (N'климова', N'Klimova'), (N'ковалев', N'Kovalev'), (N'ковалева', N'Kovaleva'), (N'коваленко', N'Kovalenko'), (N'козлов', N'Kozlov'), (N'колесникова', N'Kolesnikova'), (N'комаров', N'Komarov'), (N'комарова', N'Komarova'), (N'кондрашов', N'Kondrashov'), (N'коновалова', N'Konovalova'), (N'коршунов', N'Korshunov')
            , (N'косарев', N'Kosarev'), (N'котов', N'Kotov'), (N'котова', N'Kotova'), (N'кравченко', N'Kravchenko'), (N'красильникова', N'Krasilnikova'), (N'крылов', N'Krylov'), (N'кудряшова', N'Kudryashova'), (N'кузина', N'Kuzina'), (N'кузьмин', N'Kuzmin'), (N'кулакова', N'Kulakova'), (N'куликов', N'Kulikov'), (N'лавров', N'Lavrov'), (N'ларионова', N'Larionova'), (N'лебедев', N'Lebedev'), (N'левин', N'Levin'), (N'левина', N'Levina'), (N'левченко', N'Levchenko'), (N'ли', N'Li'), (N'литвинова', N'Litvinova'), (N'логинов', N'Loginov'), (N'лысенко', N'Lysenko'), (N'львович', N'Lvovich'), (N'мадина', N'Madina'), (N'майорова', N'Mayorova'), (N'макаров', N'Makarov'), (N'максимов', N'Maksimov'), (N'мальцева', N'Maltseva'), (N'марат', N'Marat'
            ), (N'марианна', N'Marianna'), (N'маркович', N'Markovich'), (N'марковна', N'Markovna'), (N'мартынова', N'Martynova'), (N'матвеева', N'Matveeva'), (N'медведев', N'Medvedev'), (N'мезенцева', N'Mezentseva'), (N'мельникова', N'Melnikova'), (N'минина', N'Minina'), (N'мироненко', N'Mironenko'), (N'миронова', N'Mironova'), (N'мирошниченко', N'Miroshnichenko'), (N'митрофанова', N'Mitrofanova'), (N'михайлов', N'Mikhaylov'), (N'михеева', N'Mikheeva'), (N'молчанова', N'Molchanova'), (N'мясникова', N'Myasnikova'), (N'назаров', N'Nazarov'), (N'назарова', N'Nazarova'), (N'наумова', N'Naumova'), (N'нефедов', N'Nefedov'), (N'никулина', N'Nikulina'), (N'орлов', N'Orlov'), (N'осипова', N'Osipova'), (N'павленко', N'Pavlenko'), (N'павлов', N'Pavlov'
            ), (N'панов', N'Panov'), (N'платонова', N'Platonova'), (N'подкопаев', N'Podkopaev'), (N'поляков', N'Polyakov'), (N'пономарев', N'Ponomarev'), (N'пономарева', N'Ponomareva'), (N'прохорова', N'Prokhorova'), (N'пучков', N'Puchkov'), (N'регина', N'Regina'), (N'ренат', N'Renat'), (N'рената', N'Renata'), (N'родионова', N'Rodionova'), (N'романенко', N'Romanenko'), (N'романов', N'Romanov'), (N'рубцов', N'Rubtsov'), (N'рустам', N'Rustam'), (N'рыбаков', N'Rybakov'), (N'савина', N'Savina'), (N'савченко', N'Savchenko'), (N'сафронов', N'Safronov'), (N'семенов', N'Semenov'), (N'сергеев', N'Sergeev'), (N'серова', N'Serova'), (N'сидорова', N'Sidorova'), (N'сизова', N'Sizova'), (N'соболев', N'Sobolev'), (N'соболева', N'Soboleva'
            ), (N'сорокин', N'Sorokin'), (N'степанов', N'Stepanov'), (N'стрельникова', N'Strelnikova'), (N'тарасенко', N'Tarasenko'), (N'тарасов', N'Tarasov'), (N'тимофеев', N'Timofeev'), (N'тихонов', N'Tikhonov'), (N'тихонова', N'Tikhonova'), (N'ткаченко', N'Tkachenko'), (N'трофименко', N'Trofimenko'), (N'устинова', N'Ustinova'), (N'фадеева', N'Fadeeva'), (N'федоренко', N'Fedorenko'), (N'федоров', N'Fedorov'), (N'федотов', N'Fedotov'), (N'федотова', N'Fedotova'), (N'филатова', N'Filatova'), (N'филиппов', N'Filippov'), (N'фокина', N'Fokina'), (N'харитонов', N'Kharitonov'), (N'хохлов', N'Khokhlov'), (N'шабанова', N'Shabanova'), (N'шапошников', N'Shaposhnikov'), (N'шестакова', N'Shestakova'), (N'шилова', N'Shilova'), (N'шишкин', N'Shishkin'
            ), (N'щербакова', N'Shcherbakova'), (N'эльмира', N'Elmira'), (N'эндрю', N'Andrew'), (N'яков', N'Yakov'), (N'яковлев', N'Yakovlev'), (N'яковлевич', N'Yakovlevich'), (N'якушев', N'Yakushev'), (N'ян', N'Ian')
        ) AS tmp(ru, en)
    ), entities_prep
-- сложение фамилий, имён и отчеств в один столбец сущностей (и соотвествующий второй столбец их переводов), подготовка к подсчёту использований сущности в качестве фамилии, имени отчества
AS (
    SELECT sa1.Фамилия_е AS entity, sa1.Фамилия_en AS entity_en, ф_кол = 1, и_кол = 0, о_кол = 0
    FROM sa1
      
    UNION ALL
      
    SELECT sa1.Имя_е AS entity, sa1.Имя_en AS entity_en, ф_кол = 0, и_кол = 1, о_кол = 0
    FROM sa1
      
    UNION ALL
      
    SELECT sa1.Отчество_е AS entity, sa1.Отчество_en AS entity_en, ф_кол = 0, и_кол = 0, о_кол = 1
    FROM sa1
    ),
-- группировка по сущностям и переводам, пометка переводов, суммирование статистики
    entities_prep2
AS (
    SELECT entity, entity_en, iif(entity_en <> '', 1, 0) AS en_transl, sum(ф_кол) AS ф_кол, sum(и_кол) AS и_кол, sum(о_кол) AS о_кол, sum(ф_кол) + sum(и_кол) + sum(о_кол) AS cols
    FROM entities_prep
    GROUP BY entity, entity_en
    ),
-- определение уникальных сущностей и самых популярных переводов, суммирование статистики
    entities_prep3
AS (
    SELECT DISTINCT first_value(entity) OVER (PARTITION BY entity ORDER BY en_transl DESC, cols DESC) AS entity,
            first_value(entity_en) OVER (PARTITION BY entity ORDER BY en_transl DESC, cols DESC) AS entity_en_freq,
            sum(ф_кол) OVER (PARTITION BY entity) AS ф_кол,
            sum(и_кол) OVER (PARTITION BY entity) AS и_кол,
            sum(о_кол) OVER (PARTITION BY entity) AS о_кол,
            sum(cols) OVER (PARTITION BY entity) AS col,
            first_value(cols) OVER (PARTITION BY entity ORDER BY en_transl DESC, cols DESC) AS col_en
    FROM entities_prep2
    ), entities_prep4
-- формирование справочных, частотных и побуквенных транслитов
AS (
    SELECT entity,
        [dbo].[SA_fn_InitCap](replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(iif(SUBSTRING(entity, len(entity) - 1, 2) = N'ий' OR SUBSTRING(entity, len(entity) - 1, 2) = N'ый', CONCAT (SUBSTRING(entity, 1, len(entity) - 2), 'y'), entity), N'ый ', N'y '), N'ий ', N'y '), N'ьё', N'ьyo'), N'ъё', N'ъyo'), N'ё', N'е'), N'тц', N'тs'), N'ьа', N'yа'), N'ье', N'yе'), N'ьи', N'yи'), N'ьо', N'yо'), N'ьу', N'yу'), N'ьэ', N'yэ'), N'ъа', N'yа'), N'ъе', N'yе'), N'ъи', N'yи'), N'ъо', N'yо'), N'ъу', N'yу'), N'ъэ', N'yэ'), N'а', N'a'), N'б', N'b'), N'в', N'v'), N'г', N'g'), N'д', N'd'), N'е', N'e'), N'ж', N'zh'), N'з', N'z'), N'и', N'i'), N'й', N'y'), N'к', N'k'), N'л', N'l'), N'м', N'm'), N'н', N'n'), N'о', N'o'), N'п', N'p'), N'р', N'r'), N'с', N's'), N'т', N't'), N'у', N'u'), N'ф', N'f'), N'х', N'kh'), N'ц', N'ts'), N'ч', N'ch'), N'ш', N'sh'), N'щ', N'sch'), N'ъ', N''), N'ы', N'y'), N'ь', N''), N'э', N'e'), N'ю', N'yu'), N'я', N'ya'))
        AS entity_en_transl,
        CASE
            WHEN (ф_кол >= и_кол) AND (ф_кол >= о_кол) THEN 'f'
            WHEN (о_кол >= и_кол) AND (о_кол >= ф_кол) THEN 'o'
            WHEN (и_кол >= ф_кол) AND (и_кол >= о_кол) THEN 'i'
        END tpe,
        col,
        entity_en_freq,
        dt.en AS entity_en_dir,
        iif(entity_en_freq = '', 0, col_en) AS col_en,
-- статистика, отключено для ускорения
--      iif(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(entity,N'а',''),N'б',''),N'в',''),N'г',''),N'д',''),N'е',''),N'ё',''),N'ж',''),N'з',''),N'и',''),N'й',''),N'к',''),N'л',''),N'м',''),N'н',''),N'о',''),N'п',''),N'р',''),N'с',''),N'т',''),N'у',''),N'ф',''),N'х',''),N'ц',''),N'ч',''),N'ш',''),N'щ',''),N'ъ',''),N'ь',''),N'ы',''),N'э',''),N'ю',''),N'я',''),N'a',''),N'b',''),N'c',''),N'd',''),N'e',''),N'f',''),N'g',''),N'h',''),N'i',''),N'j',''),N'k',''),N'l',''),N'm',''),N'n',''),N'o',''),N'p',''),N'q',''),N'r',''),N's',''),N't',''),N'u',''),N'v',''),N'w',''),N'x',''),N'y',''),N'z',''),N' ',''),N'-','')
--      <>'' or entity like N'%тест%' or  entity like N'%test%',1,0) as junk
        0 as junk  --заглушка
    FROM entities_prep3
    LEFT JOIN dir_trans AS dt ON entity = ru
    ), entities
-- итоговая таблица сущностей с выбранным транслитом
AS (
    SELECT entity,
        isnull(entity_en_dir,
        iif(col_en < 4, entity_en_transl, entity_en_freq)) AS entity_en,
        tpe,
        col,
        col_en,
        iif(entity_en_dir IS NULL,
        iif(col_en < 4, N'Транслит', N'Частотный'), N'Справочный') AS transl_type,
        entity_en_dir, entity_en_freq,
        entity_en_transl AS entity_en_transl,
        iif(iif(col_en < 4, entity_en_transl, entity_en_freq) <> entity_en_transl, 1, 0) AS different_transl,
        junk
    FROM entities_prep4
    WHERE entity <> ''
    ), sa2
-- определение перепутанных ФИО и расстановка их по местам
AS (
    SELECT sa1.id,
        sa1.Фамилия,
        sa1.Имя, sa1.Отчество,
        sa1.Фамилия_en,
        sa1.Имя_en, sa1.Отчество_en,
        CASE
            WHEN ef.tpe = 'f' THEN sa1.Фамилия_е
            WHEN ei.tpe = 'f' THEN sa1.Имя_е
            WHEN eo.tpe = 'f' THEN sa1.Отчество_е
            ELSE sa1.Фамилия_е
            END Фамилия_е,
        CASE
            WHEN ei.tpe = 'i' THEN sa1.Имя_е
            WHEN ef.tpe = 'i' THEN sa1.Фамилия_е
            ELSE sa1.Имя_е
            END Имя_е,
        CASE
            WHEN eo.tpe = 'o' THEN sa1.Отчество_е
            WHEN ef.tpe = 'o' THEN sa1.Фамилия_е
            ELSE Отчество_е
            END Отчество_е,
            iif((
                (
                    ef.tpe <> 'f'
                    AND (ei.tpe = 'f' OR eo.tpe = 'f')
                    )
                AND sa1.Фамилия_е <> ''
                )
            OR (
                (ei.tpe <> 'i' AND ef.tpe = 'i')
                AND sa1.Имя_е <> ''
                )
            OR (
                (eo.tpe <> 'o' AND ef.tpe = 'o')
                AND sa1.Отчество_е <> ''
                ), 1, 0) AS fio_switch,
            iif((ef.junk=1) or (ei.junk=1) or (eo.junk=1),1,0) as junk
    FROM sa1
    LEFT JOIN entities AS ef ON sa1.Фамилия_е = ef.entity
    LEFT JOIN entities AS ei ON sa1.Имя_е = ei.entity
    LEFT JOIN entities AS eo ON sa1.Отчество_е = eo.entity
    )
,
-- подбор транслитераций
sa3 as (
SELECT sa2.id,
    replace(sa2.Фамилия, CHAR(9), '') AS Фамилия,
    replace(sa2.Имя, CHAR(9), '') AS Имя,
    replace(sa2.Отчество, CHAR(9), '') AS Отчество,
    CASE
        WHEN sa2.Фамилия_en <> '' THEN sa2.Фамилия_en
        WHEN ef.entity_en <> ''   THEN ef.entity_en
        WHEN sa2.Фамилия_е = '' THEN NULL
        END Фамилия_en1,
    CASE WHEN sa2.Имя_en <> '' THEN sa2.Имя_en
        WHEN ei.entity_en <> '' THEN ei.entity_en
        WHEN sa2.Имя_е = '' THEN NULL
        END Имя_en1,
    CASE
        WHEN sa2.Отчество_en <> '' THEN sa2.Отчество_en
        WHEN eo.entity_en <> ''   THEN eo.entity_en
        WHEN sa2.Отчество_е = '' THEN NULL
        END Отчество_en1, sa2.fio_switch,
    sa2.junk
FROM sa2
LEFT JOIN entities AS ef ON sa2.Фамилия_е = ef.entity
LEFT JOIN entities AS ei ON sa2.Имя_е = ei.entity
LEFT JOIN entities AS eo ON sa2.Отчество_е = eo.entity
)
select
*
from sa3
order by id asc
 
/*
 
-- статистика
 
select
count(all sa2.id) as 'Количество записей',
count(all iif(sa2.Фамилия_е='',NULL,sa2.Фамилия_е)) as 'Фамилии (количество использований)',
count(all iif(sa2.Имя_е='',NULL,sa2.Имя_е)) as 'Имена (количество использований)',
count(all iif(sa2.Отчество_е='',NULL,sa2.Отчество_е)) as 'Отчества (количество использований)',
count(distinct iif(sa2.Фамилия_е='',NULL,sa2.Фамилия_е)) as 'Фамилии (уникальные)',
count(distinct iif(sa2.Имя_е='',NULL,sa2.Имя_е)) as 'Имена (уникальные)',
count(distinct iif(sa2.Отчество_е='',NULL,sa2.Отчество_е)) as 'Отчества (уникальные)',
sum(sa2.fio_switch) as 'Перепутанные ФИО',
count(all entities.entity) as 'Количество сущностей',
sum(entities.col) as 'Количество использований сущностей',
sum(sa2.junk) as 'Количество мусорных записей',
sum(entities.junk) as 'Количество мусорных сущностей'
from sa2
full outer join entities on sa2.id=NULL
*/
 
/*
 
-- сущности
 
select
*
from entities
order by col desc, entity asc
*/
  ```
  </details>
