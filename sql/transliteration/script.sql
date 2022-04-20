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