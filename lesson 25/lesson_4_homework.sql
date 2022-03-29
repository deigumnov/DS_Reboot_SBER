--task1  (lesson7)
--no task

--task2  (lesson7)
-- oracle: https://leetcode.com/problems/duplicate-emails/
select email from (
    select count(email) as cnt_emails, email from person
    group by email
)
where cnt_emails > 1

--task3  (lesson7)
-- oracle: https://leetcode.com/problems/employees-earning-more-than-their-managers/
select e1.name Employee
from Employee e1
join Employee e2
on e1.managerId = e2.id
where e1.salary > e2.salary

--task4  (lesson7)
-- oracle: https://leetcode.com/problems/rank-scores/
select score, dense_rank() over(order by score desc) as rank from Scores

--task5  (lesson7)
-- oracle: https://leetcode.com/problems/combine-two-tables/
select FirstName, LastName, City, State from Person left join Address on Person.PersonId=Address.PersonId
