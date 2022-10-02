-- 1. Напишите запрос, выдающий список фамилий преподавателей английского
--    языка с названиями университетов, в которых они преподают.
--    Отсортируйте запрос по городу, где расположен университ, а
--    затем по фамилии лектора.

select l.surname, u.name
  from lecturers l join universities u on l.univ_id=u.id
 where l.id in (select lecturer_id
                  from subj_lect
                 where subj_id in (select id
                                     from subjects
                                    where name like '%Английский%')); 

-- 2. Напишите запрос, который выполняет вывод данных о фамилиях, сдававших экзамены 
--    студентов, учащихся в Б.Церкви, вместе с наименованием каждого сданного ими предмета, 
--    оценкой и датой сдачи.

select s.surname, u.city, sb.name, em.mark, em.exam_date
  from students s 
  left join exam_marks em on s.id=em.student_id
  right join universities u on s.univ_id=u.id
  left join subjects sb on em.subj_id=sb.id
 where u.city='Белая Церковь'; 

-- 3. Используя оператор JOIN, выведите объединенный список городов с указанием количества 
--    учащихся в них студентов и преподающих там же преподавателей.

select u.city, count(distinct s.id) qty_stu, count(distinct l.id) qty_lec
  from universities u left join students s on u.id=s.univ_id
  left join lecturers l on u.id=l.univ_id
 group by u.city;          
  
-- 4. Напишите запрос который выдает фамилии всех преподавателей и наименование предметов,
--    которые они читают в КПИ

select l.surname, sb.name
  from lecturers l
 right join universities u on l.univ_id=u.id
 left join subj_lect sbl on l.id=sbl.lecturer_id
 left join subjects sb on sb.id=sbl.subj_id
 where u.name='КПИ'; 
  

-- 5. Покажите всех студентов-двоешников, кто получил только неудовлетворительные оценки (2) 
--    и по каким предметам, а также тех кто не сдал ни одного экзамена. 
--    В выходных данных должны быть приведены фамилии студентов, названия предметов и 
--    оценка, если оценки нет, заменить ее на прочерк.

select s.surname, s.name, isnull(convert(em1.mark, char),'-' mark, isnull(sb.name,'-') 
  from exam_marks em1
right join (select s.id
              from exam_marks em right join students s on em.student_id=s.id   
          group by s.id
having max(mark)=2 or max(mark) isnull) x s.id=em1.student_id
join students s on x.id=s.id
left join subjects sb on sb.id=em1.subj_id; 


-- 6. Напишите запрос, который выполняет вывод списка университетов с рейтингом, 
--    превышающим 490, вместе со значением максимального размера стипендии, 
--    получаемой студентами в этих университетах.
 
select u.name, max(s.stipend) max_stipend
  from universities u join students s on u.id=s.univ_id
 where u.rating>490
group by u.name; 

-- 7. Расчитать средний бал по оценкам студентов для каждого университета, 
--    умноженный на 100, округленный до целого, и вычислить разницу с текущим значением
--    рейтинга университета.

select u1.name, ravg1.ravg, (u1.rating-ravg1.ravg) Delta
  from universities u1 
  join (select  u.name, round((avg(em.mark))*100,0) Ravg
          from universities u
  join students s on s.univ_id=u.id
  join exam_marks em on em.student_id=s.id
group by u.id,u.name) ravg1 on u1.name=ravg1.name;
                       

-- 8. Написать запрос, выдающий список всех фамилий лекторов из Киева попарно. 
--    При этом не включать в список комбинации фамилий самих с собой,
--    то есть комбинацию типа "Коцюба-Коцюба", а также комбинации фамилий, 
--    отличающиеся порядком следования, т.е. включать лишь одну из двух 
--    комбинаций типа "Хижна-Коцюба" или "Коцюба-Хижна".

select l1.surname + '-' + l2.surname pairs
  from lecturers l1 cross join lecturers l2
 where l1.city like '%Киев%' and l1.city=l2.city
                             and l1.id<>l2.id
                             and l1.id >l2.id;

-- 9. Выдать информацию о всех университетах, всех предметах и фамилиях преподавателей, 
--    если в университете для конкретного предмета преподаватель отсутствует, то его фамилию
--    вывести на экран как прочерк '-' (воспользуйтесь ф-ей isnull)

select u.name, s.name, isnull(sl1.surname), '-'  as surname
  from universities u cross join subjects s
                       left join (select *
                                    from subj_lect sl join lecturers on sl.lecturer_id =l.id) sl1
                                    on s.id=sl1.subj_id and u.id=sl1.univ_id;
                                    
-- 10. Кто из преподавателей и сколько поставил пятерок за свой предмет?

select tab1.surname, count(tab1.surname) cnt_5
  from exam_marks em left join students s on s.id=em.student_id
                     left join (select *
                                  from lecturers l join subj_lect sl on l.id=sl.lecturer_id) tab1
                     on s.univ_id=tab1.univ_id and em.subj_id=tab1.subj_id
 where em.mark=5 and tab1.surname is not null
group by tab1.surname;
 
-- 11. Добавка для уверенных в себе студентов: показать кому из студентов какие экзамены
--     еще досдать.
select s.surname student, sub.name subjects
  from students s cross join subjects sub 
                   left join exam_marks em on s.id=em.student_id and sub.id=em.subj_id
 where em.student_id is null and em.subj_id is null; 