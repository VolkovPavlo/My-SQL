-- 1. Напишите запрос с EXISTS, позволяющий вывести данные обо всех студентах, 
--    обучающихся в вузах с рейтингом не попадающим в диапазон от 488 до 571

select *
from STUDENTS S
where not exists
	     (select *
	        from UNIVERSITIES U
	       where (RATING between 488 and 571) and ID = S.ID);

-- 2. Напишите запрос с EXISTS, выбирающий всех студентов, для которых в том же городе, 
--    где живет и учится студент, существуют другие университеты, в которых он не учится.

select *
  from students s
 where univ_id in(select id
                    from universities u 
				   where u.city=s.city) and exists(select city, count(u.city)cnc
                                                      from universities u
												  group by u.city
                                                  having count(u.city)>1 and u.city=s.city);
										
-- 3. Напишите запрос, выбирающий из таблицы SUBJECTS данные о названиях предметов обучения, 
--    экзамены по которым были хоть как-то сданы более чем 12 студентами, за первые 10 дней сессии. 
--    Используйте EXISTS. Примечание: по возможности выходная выборка должна быть без пересдач.

select s.name
  from subjects s 
 where exists(select *
			    from exam_marks em
			   where s.id=em.subj_id and em.mark>=3 and em.exam_date<(select date_add('2012-06-13',interval 10)
																	    from exam_marks em)
																	group by em.subj_id
                                                                    having count(distinct em.student_id)>=12);

-- 4. Напишите запрос EXISTS, выбирающий фамилии всех лекторов, преподающих в университетах
--    с рейтингом, превосходящим рейтинг каждого харьковского универа.

select surname
  from lecturers l
 where exists
	  (select id
	from universities u
	where u.id = l.univ_id and rating > all
		(select rating from universities where city = 'Харьков'));

-- 5. Напишите 2 запроса, использующий ANY и ALL, выполняющий выборку данных о студентах, 
--    у которых в городе их постоянного местожительства нет университета.

select *
from students s
where s.city <> all
	(select U.CITY from universities u);

select *
from students s
where not s.city = any
	(select u.city from universities u);

-- 6. Напишите запрос выдающий имена и фамилии студентов, которые получили
--    максимальные оценки в первый и последний день сессии.
--    Подсказка: выборка должна содержать по крайне мере 2х студентов.

select s.name, s.surname
  from students s  
 where exists (select *
                 from exam_marks em
 where em.exam_date=(select max(exam_date) 
                       from exam_marks)
        and em.mark=(select max(mark)
                       from exam_marks
                      where exam_date=(select max(exam_date) from exam_marks))
        and em.student_id=s.id)
or exists (select *
                 from exam_marks em
 where em.exam_date=(select min(exam_date) 
                       from exam_marks)
        and em.mark=(select max(mark)
                       from exam_marks
                      where exam_date=(select min(exam_date) from exam_marks))
        and em.student_id=s.id);        

-- 7. Напишите запрос EXISTS, выводящий кол-во студентов каждого курса, которые успешно 
--    сдали экзамены, и при этом не получивших ни одной двойки.

select s.course, count(distinct s.id) cnt
  from exam_marks em, students s
 where mark>=3
   and not exists (select *
                    from exam_marks em1
                   where  em1.mark=2
                     and em. student_id=em1.student_id
   and em.student_id=s.id)
   group by s.course;

-- 8. Напишите запрос EXISTS на выдачу названий предметов обучения, 
--    по которым было получено максимальное кол-во оценок.

select s.name
  from subjects s  
 where exists (select em1.subj_id
                from exam_marks em1
               where s.id=em1.subj_id
              group by em1.subj_id 
			  having count(*) in (select  max(mc.cntmark) 
								  from (select subj_id, count(mark) cntmark
                                  from exam_marks
                              group by subj_id) as mc));
                              
                              

-- 9. Напишите команду, которая выдает список фамилий студентов по алфавиту, 
--    с колонкой комментарием: 'успевает' у студентов , имеющих все положительные оценки, 
--    'не успевает' для сдававших экзамены, но имеющих хотя бы одну 
--    неудовлетворительную оценку, и комментарием 'не сдавал' – для всех остальных.
--    Примечание: по возможности воспользуйтесь операторами ALL и ANY.

select 'успевает' successful, surname
  from students 
union all
select 'не успевает', surname
  from lecturers 
 order by successful desc, surname asc; 

-- 10. Создайте объединение двух запросов, которые выдают значения полей 
--     NAME, CITY, RATING для всех университетов. Те из них, у которых рейтинг 
--     равен или выше 500, должны иметь комментарий 'Высокий', все остальные – 'Низкий'.

select name, city, rating
  from universities
union all 
select city, rating ,case
               when rating>=500 then 'высокий'
               else 'низкий'
               end as dif_rating
  from universities;

-- 11. Напишите UNION запрос на выдачу списка фамилий студентов 4-5 курсов в виде 3х полей выборки:
--     SURNAME, 'студент <значение поля COURSE> курса', STIPEND
--     включив в список преподавателей в виде
--     SURNAME, 'преподаватель из <значение поля CITY>', <значение зарплаты в зависимости от города проживания (придумать самим)>
--     отсортировать по фамилии
--     Примечание: достаточно учесть 4-5 городов.

select surname, concat('студент', course, 'курса') stud, stipend
  from students 
 where course=4
union all
select surname, concat('студент', course, 'курса') stud, stipend
  from students 
 where course=5 
union all
select surname, concat('преподаватель из', city), case city
                                                  when 'Харьков' then 10000
                                                  when 'Львов' then 15000
                                                  when 'Днепропетрровск' then 20000
                                                  when 'Лугнаск' then 25000 
                                                  else 5000
                                                  end as salary
  from lecturers
order by surname;
