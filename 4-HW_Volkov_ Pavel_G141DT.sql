-- Внимание! Во всех результирующих выборках должны быть учтены все записи, даже
-- те, которые содержать NULL поля, однако, склейка не должна быть NULL записью!
-- Для этого используйте либо CASE, либо функцию 
-- ISNULL(<выражение>, <значение по умолчанию>) -- Microsoft SQL Server
-- IFNULL(<выражение>, <значение по умолчанию>) -- MySQL
-- nvl(<выражение>, <значение по умолчанию>) --Oracle COALESCE(<выражение>, <значение по умолчанию>) -- ANSI SQL (стандарт)
-- Соблюдать это условие достаточно для двух полей BIRTHDAY и UNIV_ID.
-- В качестве <значения по умолчания> используйте строку 'unknown'.

use qalight;

-- 1. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала один столбец типа varchar, содержащий последовательность разделенных 
--    символом ';' (точка с запятой) значений столбцов этой таблицы, и при этом 
--    текстовые значения должны отображаться прописными символами (верхний регистр), 
--    то есть быть представленными в следующем виде: 
--    1;КАБАНОВ;ВИТАЛИЙ;M;550;4;ХАРЬКОВ;01/12/1990;2.
--    ...
--    примечание: в выборку должны попасть студенты из любого города из 5 букв
  
select concat(id, ';', upper(surname), ';', upper(name), ';', 
       upper(gender), ';', stipend, course, ';', upper(city), ';',  date_format(birthday, "%d/%m/%Y"), ';', univ_id)  as coloumn 
  from students
 where birthday is not null and univ_id is not null 
                              and city like '_____'; 
-- 2. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде: 
--    В.КАБАНОВ;местожительства-ХАРЬКОВ;родился-01.12.90
--    ...
--    примечание: в выборку должны попасть студенты, фамилия которых содержит вторую
--    букву 'е' и предпоследнюю букву 'и', либо же фамилия заканчивается на 'ц'

select concat(left(name,1), '.', ';', upper(surname),';', 
       'местожительства-', upper(city), ';', 'родился-', left(birthday,11)) as coloumn
  from students
 where  surname like '_е%' and surname like '%и_' 
         or surname like '%ц' and (birthday is not null 
         and univ_id is not null); 

-- 3. Составьте запрос для таблицы STUDENT таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    т.цилюрик;местожительства-Херсон; учится на IV курсе
--    ...
--    примечание: курс указать римскими цифрами (воспользуйтесь CASE), 
--    отобрать студентов, стипендия которых кратна 200
 
 select concat(left( lower(name),1), '.', lower(surname),
       ';', 'местожительсвта-', city, ';', 'учится на', 
    case course
	when 1 then 'I'
    when 2 then 'II'
    when 3 then 'III' 
    when 4 then 'IV'
    when 5 then 'V'
    else        'VI'
    end, 'курсе') as coloumn
 from students  
 where stipend%200=0;

-- 4. Составьте запрос для таблицы STUDENT таким образом, чтобы выборка 
--    содержала столбец в следующем виде:
--     Нина Федосеева из г.Днепропетровск родилась в 1992 году
--     ...
--     Дмитрий Коваленко из г.Хмельницкий родился в 1993 году
--     ...
--     примечание: для всех городов, в которых более 8 букв

select concat(name, ' ', surname, ' ', 'из', ' ', 'г.' ,city, ' ', 
    case gender
	when gender='m' then 'родился'
    when gender='f' then 'родилась'
    
    end, ' ','в', ' ', (left(birthday,11)), 'году' ) as coloumn,
    CHAR_LENGTH(city) length_c 
 from students
where CHAR_LENGTH(city)>=8;

-- 5. Вывести фамилии, имена студентов и величину получаемых ими стипендий, 
--    при этом значения стипендий первокурсников должны быть увеличены на 17.5%

select surname, name, stipend,
  case
  when course=1 then stipend * 0.175+stipend
  end as stipend2
 from students; 


-- 6. Вывести наименования всех учебных заведений и их расстояния 
--    (придумать/нагуглить/взять на глаз) до Киева.

select *, case city
         when 'Киев' then 0
         else round(rating*2/id)
         end as distance
  from UNIVERSITIES;

-- 7. Вывести все учебные заведения и их две последние цифры рейтинга.

select name, right(rating,2) as new_rating
   from universities;

-- 8. Составьте запрос для таблицы UNIVERSITY таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    Код-1;КПИ-г.Киев;Рейтинг относительно ДНТУ(501) +756
--    ...
--    Код-11;КНУСА-г.Киев;рейтинг относительно ДНТУ(501) -18
--    ...
--    примечание: рейтинг вычислить относительно ДНТУшного, а также должен 
--    присутствовать знак (+/-), рейтинг ДНТУ заранее известен = 501
 
 select concat('Код-',id, ';', name, '-г.', city,';', case rating 
                                                       when rating-(select rating   
																	  from universities
                                                                     where name='ДНТУ')>0 then concat('+', rating-(select rating   
																	                                                 from universities
                                                                                                               where name='ДНТУ'))
                                                       else rating-(select rating   
																	  from universities
                                                                     where name='ДНТУ')
                                                         end) as coloumn           
  from universities;


-- 9. Составьте запрос для таблицы UNIVERSITY таким образом, чтобы выходная таблица 
--    содержала всего один столбец в следующем виде:
--    Код-1;КПИ-г.Киев;рейтинг состоит из 12 сотен
--    Код-2;КНУ-г.Киев;рейтинг состоит из 6 сотен
--    ...
--    примечание: в рейтинге необходимо указать кол-во сотен


select concat('Код-',id, ';', name, '-г.', city,';', 'рейтинг', ' ', 'из', ' ',  
													   case 
                                                       when rating=1257 then 12
                                                       when rating>600 then 6
                                                       when rating>500 then 5											
                                                       when rating>400 then 4
                                                       when rating>300 then 3 
                                                       when rating<100 then 0
                                                       else   0         
                                                       end, ' ', 'сотен') as coloumn
  from universities;
