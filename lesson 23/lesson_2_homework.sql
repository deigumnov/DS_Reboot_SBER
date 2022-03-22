--task1  (lesson2)
-- oracle: https://leetcode.com/problems/department-top-three-salaries/
select Department, Employee, Salary
from (
    select
        Department.name as Department,
        Employee.name as Employee,
        Employee.salary as Salary,
        dense_rank() over (partition by Employee.departmentId order by Employee.salary desc) as rnk
    from Employee, Department
    where Department.id = Employee.departmentId
) a
where rnk <= 3

--task2  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/17
SELECT member_name, status, SUM(pay_price) AS costs
FROM (
    SELECT member_name, status, (amount * unit_price) as pay_price
    FROM FamilyMembers, Payments
    WHERE
        FamilyMembers.member_id = Payments.family_member AND 
        YEAR(date) = 2005
) member_with_payment
GROUP BY member_name, status

--task3  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/13
SELECT name FROM Passenger
GROUP BY name
HAVING COUNT(name) > 1 

--task4  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/38
SELECT COUNT(first_name) AS count FROM Student
WHERE first_name = 'Anna'

--task5  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/35
SELECT COUNT(classroom) AS count FROM Schedule
WHERE date = '2019-09-02'

--task6  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/38
SELECT COUNT(first_name) AS count FROM Student
WHERE first_name = 'Anna'

--task7  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/32
SELECT FLOOR(AVG(FLOOR(((YEAR(CURRENT_DATE)-YEAR(birthday))*12 + MONTH(CURRENT_DATE) - MONTH(birthday))/12))) AS age FROM FamilyMembers

--task8  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/27
SELECT good_type_name, SUM(amount*unit_price) as costs FROM Payments, GoodTypes, Goods
WHERE good = good_id AND type = good_type_id AND YEAR(date) = 2005 
GROUP BY good_type_name

--task9  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/37
SELECT MIN(FLOOR(((YEAR(CURRENT_DATE)-YEAR(birthday))*12 + MONTH(CURRENT_DATE) - MONTH(birthday))/12)) AS year from Student 

--task10  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/44
SELECT MAX(YEAR(CURRENT_DATE) - YEAR(Student.birthday)) AS max_year
FROM Class, Student_in_class, Student
WHERE
    Class.name LIKE '10%' AND
    Class.id = Student_in_class.class AND 
    Student_in_class.student = Student.id
    
--task11 (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/20
SELECT status, member_name, SUM(amount*unit_price) AS costs
FROM FamilyMembers, Payments, Goods, GoodTypes
WHERE 
    FamilyMembers.member_id = Payments.family_member AND 
    Payments.good = Goods.good_id AND 
    Goods.type = GoodTypes.good_type_id
GROUP BY status, member_name

--task12  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/55
DELETE FROM Company
WHERE id in (
    SELECT company FROM Trip
    GROUP BY company
    HAVING COUNT(id) = (
        SELECT MIN(cnt)
        FROM (
            SELECT COUNT(id) AS cnt
            FROM Trip
            GROUP BY Company
        ) Company_trips_cnt
    )
)

--task13  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/45
SELECT classroom FROM Schedule
GROUP BY classroom
HAVING COUNT(id) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(id) AS cnt FROM Schedule
        GROUP BY classroom 
    ) cnt_classroom_id
)

--task14  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/43
SELECT last_name FROM Teacher, Schedule, Subject
WHERE
    Teacher.id = Schedule.teacher AND 
    Schedule.subject = Subject.id AND 
    Subject.name = 'Physical Culture'
ORDER BY last_name

--task15  (lesson2)
-- https://sql-academy.org/ru/trainer/tasks/63
SELECT CONCAT(last_name, '.', LEFT(first_name, 1), '.', LEFT(middle_name, 1), '.') AS name FROM Student
ORDER BY name