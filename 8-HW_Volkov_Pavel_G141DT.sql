-- /* Везде, где необходимо данные придумать самостоятельно. */
-- Для каждого задания (кроме 4-го) можете использовать конструкцию
-------------------------
-- начать транзакцию
start transaction;
-- проверка до изменений
SELECT * FROM EXAM_MARKS;
-- изменения
-- insert into SUBJECTS (ID,NAME,HOURS,SEMESTER) values (25,'Этика',58,2),(26,'Астрономия',34,1)
-- insert into EXAM_MARKS ...
-- delete from EXAM_MARKS where SUBJ_ID in (...)
-- проверка после изменений
SELECT * FROM EXAM_MARKS; -- WHERE STUDENT_ID > 120;
-- отменить транзакцию
rollback;


-- 1. Необходимо добавить двух новых студентов для нового учебного 
-- заведения "Винницкий Медицинский Университет".

start transaction;

SELECT * FROM students;
insert into students 
values (48, 'Иванов', 'Олег', 'm', 500, 4, 'Киев', current_date(), 20),
       (49, 'Петров', 'Петя', 'm', 500, 4, 'Киев', current_date(), 20);
SELECT * FROM students;

SELECT * FROM universities;
insert into universities 
values (20, 'ВМУ', 800, 'Винница');
SELECT * FROM universities;
-- commit
rollback;

-- 2. Добавить еще один институт для города Ивано-Франковск, 
--    1-2 преподавателей, преподающих в нем, 1-2 студента,
--    а так же внести новые данные в экзаменационную таблицу.


start transaction;

select * from universities;
insert into universities
values (( select max(id) from universities)+1, 'New', null, 'Ивано-Франсковск');
select * from universities;

select * from lecturers;
insert into lectirers
values ((select max(id) from lecturers)+1, 'Иванов', 'Петр', 'Ивано-Франковск', (select id 
                                                                                    from universities 
                                                                                   where name like 'New')),
       ((select max(id) from lecturers)+2, 'Петров', 'Иван', 'Ивано-Франковск', (select id 
                                                                                    from universities 
                                                                                   where name like 'New'));
select * from lecturers;

select * from students;
insert into students (id, surname, name, gender,birthday, univ_id)
values ((select max(id) from students)+1, 'Кулик ','Василий','m', convert('1986-05-06', date), (select id 
                                                                                                  from universities 
                                                                                                 where name like 'New')), 
       ((select max(id) from students)+2, 'Васильев ','Егор','m', convert('1987-07-07', date), (select id 
                                                                                                  from universities 
                                                                                                 where name like 'New'));
select * from students;

select * from exam_marks;
insert into exam_marks (student_id)
values ((select id from students where surname like '%Кулик%')),
       ((select id from students where surname like '%Васильев%'));
select * from exam_marks;                                                                                           
-- commit
rollback;

-- 3. Известно, что студенты Павленко и Пименчук перевелись в ОНПУ. 
--    Модифицируйте соответствующие таблицы и поля.

start transaction;
select * from students;
update students
   set univ_id = (select id from universities
                   where name like 'ОНПУ')
where id = (select *
              from students
             where surname like 'Павленко' or surname like 'Пименчук'); 
select * from students;
-- commit
rollback;

-- 4. В учебных заведениях Украины проведена реформа и все студенты, 
--    у которых средний бал не превышает 3.5 балла - отчислены из институтов. 
--    Сделайте все необходимые удаления из БД.
--    Примечание: предварительно "отчисляемых" сохранить в архивационной таблице

start transaction;

select * from students_archive;
insert into students_archive
select *
  from students
 where id in (select student_id
                from exam_marks
			group by student_id
            having avg(mark)<=3.5);
select * from students_archive;
select * from exam_marks;
delete 
  from exam_marks
 where student_id in (select student_id
                from exam_marks
			group by student_id
            having avg(mark)<=3.5); 
select * from exam_marks;
select * from students; 
delete 
  from students
 where id in (select id
                from students_archive);
select * from students;
-- commit
rollback;


-- 5. Студентам со средним балом 4.75 начислить 12.5% к стипендии,
--    со средним балом 5 добавить 200 грн.
--    Выполните соответствующие изменения в БД.

start transaction;
select * from students;
update students
   set stipend = (select case avg(em.mark)
						  when 4.75 then (s.stipend*0.125)+s.stipend
                          when 5 then s.stipend+200
                          else stipend
                         end new_stipend
                    from exam_marks em join students s on s.id=em.student_id 
				group by em.student_id, s.id, s.stipend
                  having (avg(mark)=4.75 or avg(mark)=5) and students.id=em.student_id)
 where students.id in (select student_id
						from exam_marks
					group by student_id
                      having (avg(mark)=4.75 or avg(mark)=5));
select * from students;
-- commit
rollback;

-- 6. Необходимо удалить все предметы, по котором не было получено ни одной оценки.
--    Если таковые отсутствуют, попробуйте смоделировать данную ситуацию.

start transaction;
select * from subjects;
insert into subjects (id, name, hours, semester)
select (select max(id)+1 from subjects), 'test', sb.hours, sb.semester from subjects sb where id=5;
select * from subjects;
delete
  from subjects
where not exists (select * from exam_marks em where em.subj_id=subjects.id);
select * from subjects;
-- commit
rollback;

-- 7. Лектор 3 ушел на пенсию, необходимо корректно удалить о нем данные.

start transaction;
select * from subj_lect;
delete 
  from subj_lect
 where lecturer_id=3;
 
select * from subj_lect;
select * from lecturers; 
delete  
  from lecturers
 where id=3;  
select * from lecturers;
-- commit
rollback;