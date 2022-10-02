-- 1. Создайте модифицируемое представление для получения сведений обо всех студентах, 
--    круглых отличниках. Используя это представление, напишите запрос обновления, 
--    "расжалующий" их в троечников.

create view v_stud_ok as
select *
  from students s
 where s.id in (select em.student_id
                  from exam_marks em
			  group by em.student_id
              having avg(em.mark)=5);
select *
  from v_stud_ok;              

create view v_stud_ok_marks as
select s_ok, em.id xxx, em.mark
  from v_stud_ok s_ok join exam_marks em on s_ok.id=em.student_id;
  
select *
  from v_stud_ok_marks;
  
start transaction;
select *
  from v_stud_ok_marks;
update v_stud_ok_marks
   set mark=3
select *
  from v_stud_ok_marks;
rollback;
  
   
-- 2. Создайте представление для получения сведений о количестве студентов 
--    обучающихся в каждом городе.

create view v_stud_city as
select u.city, count(s.id) cnt_stud
  from students s, universities u
 where u.id=s.univ_id
group by u.city;

select * from v_stud_city; 
-- 3. Создайте представление для получения сведений по каждому студенту: 
--    его ID, фамилию, имя, средний и общий баллы.

create view v_stud_marks as
select s.id, s.surname, s.name, avg(em.mark) avgm, sum(em.mark) cnt_m
  from students s, exam_marks em
 where s.id=em.student_id
group by s.id, s.surname, s.name;

select * from v_stud_murks; 

-- 4. Создайте представление для получения сведений о студенте фамилия, 
--    имя, а также количестве экзаменов, которые он сдал успешно, и количество,
--    которое ему еще нужно досдать (с учетом пересдач двоек).


-- 5. Какие из представленных ниже представлений являются обновляемыми?


-- A. CREATE VIEW DAILYEXAM AS
--    SELECT DISTINCT STUDENT_ID, SUBJ_ID, MARK, EXAM_DATE
--    FROM EXAM_MARKS


-- B. CREATE VIEW CUSTALS AS
--    SELECT SUBJECTS.ID, SUM (MARK) AS MARK1
--    FROM SUBJECTS, EXAM_MARKS
--    WHERE SUBJECTS.ID = EXAM_MARKS.SUBJ_ID
--    GROUP BY SUBJECT.ID


-- C. CREATE VIEW THIRDEXAM
--    AS SELECT *
--    FROM DAILYEXAM
--    WHERE EXAM_DATE = '2012/06/03'


-- D. CREATE VIEW NULLCITIES
--    AS SELECT ID, SURNAME, CITY
--    FROM STUDENTS
--    WHERE CITY IS NULL
--    OR SURNAME BETWEEN 'А' AND 'Д'
--    WITH CHECK OPTION

  C, D;

-- 6. Создайте представление таблицы STUDENTS с именем STIP, включающее поля 
--    STIPEND и ID и позволяющее вводить или изменять значение поля 
--    стипендия, но только в пределах от 100 д о 500.

create view v_stip as
select id, stipend
  from students
 where stipend>=100 and stipend<=500
with check option;

select * from v_stip;

 