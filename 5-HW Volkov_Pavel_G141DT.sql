-- 0. Отобразите для каждого из курсов количество парней и девушек. 

 select course, gender, count(gender)cnt
  from students
 group by course, gender
 order by course;

-- 1. Напишите запрос для таблицы EXAM_MARKS, выдающий даты, для которых средний балл 
--    находиться в диапазоне от 4.22 до 4.77. Формат даты для вывода на экран: 
--    день месяць, например, 05 Jun.

select exam_date, date_format(exam_date, '%e, %M') Em_date, avg(mark)
  from EXAM_MARKS
 group by exam_date
 having avg (mark)>=4.22 and avg(mark)<=4.77;

-- 2. Напишите запрос, который по таблице EXAM_MARKS позволяет найти промежуток времени (*),
--    который занял у студента в течении его сессии, кол-во всех попыток сдачи экзаменов, 
--    а также их максимальные и минимальные оценки. В выборке дожлен присутствовать 
--    идентификатор студента.
--    Примечание: таблица оценок - покрывает одну сессию, (*) промежуток времени -
--    количество дней, которые провел студент на этой сессии - от первого до 
--    последнего экзамена включительно
--    Примечание-2: функция DAY() для решения не подходит! 

select  student_id, (DATEDIFF(max(exam_date), min(exam_date)))+1 ses_days, 
	   count(mark) count_exam, min(mark) min_mark, max(mark) max_mark
  from EXAM_MARKS  
 group by student_id;

 
-- 3. Покажите список идентификаторов студентов, которые имеют пересдачи. 

select student_id
  from exam_marks
 group by student_id
  having count(distinct subj_id) < count(subj_id);

-- 4. Напишите запрос, отображающий список предметов обучения, вычитываемых за самый короткий 
--    промежуток времени, отсортированный в порядке убывания семестров. Поле семестра в 
--    выходных данных должно быть первым, за ним должны следовать наименование и 
--    идентификатор предмета обучения.

select semester,name, id 
  from subjects
 where hours=(select min(hours)
                from subjects)
order by semester desc;   

-- 5. Напишите запрос с подзапросом для получения данных обо всех положительных оценках(4, 5) Марины 
--    Шуст (предположим, что ее персональный номер неизвестен), идентификаторов предметов и дат 
--    их сдачи.

select mark, subj_id, date_format(exam_date, "%d/%m/%Y") exam_date
  from exam_marks
 where student_id in (select id
                     from students
					where name = 'Марина'and surname ='Шуст' and not mark in (2,3));

-- 6. Покажите сумму баллов для каждой даты сдачи экзаменов, при том, что средний балл не равен 
--    среднему арифметическому между максимальной и минимальной оценкой. Данные расчитать только 
--    для студенток. Результат выведите в порядке убывания сумм баллов, а дату в формате dd/mm/yyyy.

select date_format(exam_date, "%d/%m/%Y") exam_date, sum(mark) sum
  from exam_marks
 where student_id in (select id
                        from students 
                        where gender='f') 
group by exam_date
having avg(mark)<>(max(mark)+min(mark))/2
order by exam_date desc;

-- 7. Покажите имена и фамилии всех студентов, у которых средний балл по предметам
--    с идентификаторами 1 и 2 превышает средний балл этого же студента
--    по всем остальным предметам. Используйте вложенные подзапросы, а также конструкцию
--    AVG(case...), либо коррелирующий подзапрос.
--    Примечание: может так оказаться, что по "остальным" предметам (не 1ый и не 2ой) не было
--    получено ни одной оценки, в таком случае принять средний бал за 0 - для этого можно
--    использовать функцию ISNULL().

select name, surname
  from students
 where id in (Select student_id
                from exam_marks
            group by student_id
		       having avg (case
                           when subj_id in (1,2) then mark
						   end)>isnull( avg (case
                           when subj_id not in (1,2) then mark
						    end),0));

-- 8. Напишите запрос, выполняющий вывод общего суммарного и среднего баллов каждого 
--    экзаменованого второкурсника, его идентификатор и кол-во полученных оценок при условии, 
--    что он успешно сдал 3 и более предметов.

select student_id, sum(mark) total_m, avg(mark) avg_m, count(distinct subj_id) mark_qty
  from exam_marks
 where student_id in (select id from students where course=2) and mark>=4
group by student_id
having count(distinct subj_id)>=3;

-- 9. Вывести названия всех предметов, средний балл которых превышает средний балл по всем 
--    предметам университетов г.Днепропетровска. Используйте вложенные подзапросы.

select name
  from subjects
 where id in (select subj_id -- avg(mark) avg_m
                from exam_marks
            group by subj_id
              having avg(mark)>(select  avg(mark) avg_m
                                  from exam_marks
				                 where student_id in (select id
                                                        from students 
										               where univ_id in (select id 
                                                                           from universities
					                                                       where city = 'Днепропетровск'))));   

