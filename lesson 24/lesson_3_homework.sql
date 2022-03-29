--task1  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/the-report/problem
SELECT
    CASE
        WHEN g.grade>=8 THEN s.name ELSE NULL
    END,
    g.grade,
    s.marks
FROM students s
INNER JOIN grades g ON s.marks BETWEEN min_mark AND max_mark
ORDER BY g.grade DESC, s.name, s.marks;

--task2  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/occupations/problem
select d, p, s, a from 
(
  select
    Name,
    Occupation,
    (row_number() over(partition by Occupation order by Name)) as rn
  from Occupations
) 
pivot 
( 
  max(Name) for Occupation in (
      'Doctor' as d,
      'Professor' as p,
      'Singer' as s,
      'Actor' as a
  )  
)
order by rn;

--task3  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-9/problem
select distinct city
from station
where
    city not like 'A%' and
    city not like 'E%' and
    city not like 'I%' and
    city not like 'O%' and
    city not like 'U%';
    
--task4  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-10/problem
select distinct city
from station
where
    city not like '%a' and
    city not like '%e' and
    city not like '%i' and
    city not like '%o' and
    city not like '%u';
    
--task5  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-11/problem
select DISTINCT city
from (
    SELECT T1.city
    FROM station T1
    WHERE
        lower(SUBSTR(T1.city, -1)) not IN ('a','e','i','o','u')
    union all
    SELECT T1.city
    FROM station T1
    WHERE
        lower(SUBSTR(T1.city, 0, 1)) not IN ('a','e','i','o','u')
)
order by city;

--task6  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-12/problem
SELECT DISTINCT CITY
FROM STATION
WHERE
    LOWER(SUBSTR(CITY,-1)) NOT IN ('a','e','i','o','u') and
    LOWER(SUBSTR(CITY,0,1)) NOT IN ('a','e','i','o','u')
order by city;

--task7  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/salary-of-employees/problem
select name
from employee
where
    months < 10 and
    salary > 2000
order by employee_id asc;

--task8  (lesson3)
-- oracle: https://www.hackerrank.com/challenges/the-report/problem
SELECT
    CASE
        WHEN g.grade>=8 THEN s.name ELSE NULL
    END,
    g.grade,
    s.marks
FROM students s
INNER JOIN grades g ON s.marks BETWEEN min_mark AND max_mark
ORDER BY g.grade DESC, s.name, s.marks;
