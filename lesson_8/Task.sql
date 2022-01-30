--1. Выберите заказчиков из Германии, Франции и Мадрида, выведите их название, страну и адрес.
SELECT CustomerName, Address, Country FROM [Customers]
WHERE Country in ('Germany', 'France') or City = 'Madrid'

--2. Выберите топ 3 страны по количеству заказчиков, выведите их названия и количество записей.
SELECT count(*) as CustCnt, Country FROM [Customers]
GROUP BY Country
ORDER BY CustCnt DESC
LIMIT 3

--3. Выберите перевозчика, который отправил 10-й по времени заказ, выведите его название, и дату отправления.
SELECT S.ShipperName, O.OrderDate FROM [Orders] O, [Shippers] S
WHERE O.ShipperID = S.ShipperID and O.OrderDate = (
 SELECT max(OrderDate) FROM (
  SELECT * FROM [Orders]
  ORDER BY OrderDate ASC
  LIMIT 10
 )
)

--4. Выберите самый дорогой заказ, выведите список товаров с их ценами.
SELECT OD.OrderID, P.ProductName, (OD.Quantity * P.Price) as ProductSum FROM [OrderDetails] OD, [Products] P
WHERE P.ProductID = OD.ProductID and OD.OrderID = (
 SELECT OrderID FROM (
  SELECT OD.OrderID, SUM(OD.Quantity * P.Price) as OrderSum FROM [OrderDetails] OD, [Products] P
  WHERE P.ProductID = OD.ProductID
  GROUP BY OD.OrderID
  ORDER BY OrderSum DESC
  LIMIT 1
 )
)

--5. Какой товар больше всего заказывали по количеству единиц товара, выведите его название и количество единиц в каждом из заказов.
SELECT OD.OrderID, P.ProductName, OD.Quantity FROM [OrderDetails] OD, [Products] P
WHERE P.ProductID = OD.ProductID and OD.ProductID = (
 SELECT ProductID FROM (
  SELECT P.ProductID, sum(OD.Quantity) as MostSells FROM [OrderDetails] OD, [Products] P
  WHERE P.ProductID = OD.ProductID
  GROUP BY OD.OrderID
  ORDER BY MostSells DESC
  LIMIT 1
 )
)

--6. Выведите топ 5 поставщиков по количеству заказов, выведите их названия, страну, контактное лицо и телефон.
SELECT SupplierName, Country, ContactName, Phone FROM [Suppliers]
WHERE SupplierID in (
 SELECT SupplierID FROM (
  SELECT COUNT(*) as OrderCount, SupplierID FROM (
   SELECT OD.OrderID, P.SupplierID FROM [OrderDetails] OD, [Products] P
   WHERE P.ProductID = OD.ProductID
   GROUP BY OD.OrderID, P.SupplierID
  )
  GROUP BY SupplierID
  ORDER BY OrderCount DESC
  LIMIT 5
 )
)

--7. Какую категорию товаров заказывали больше всего по стоимости в Бразилии, выведите страну, название категории и сумму.
SELECT S.Country, C.CategoryName, T.TotalSum FROM [Suppliers] S, [Categories] C, (
 SELECT Sum(Quantity * Price) as TotalSum, CategoryID, SupplierID FROM [OrderDetails] OD, [Products] P
 WHERE OD.ProductID = P.ProductID and OrderID in (
  -- Brazil Orders
  SELECT OrderID FROM [Orders]
  WHERE CustomerID in (
   -- Brazil Customers
   SELECT CustomerID FROM [Customers]
   WHERE Country='Brazil'
  )
 )
 GROUP BY CategoryID, SupplierID
 ORDER BY TotalSum DESC
 LIMIT 1
) T
WHERE S.SupplierID = T.SupplierID and C.CategoryID = T.CategoryID

--8. Какая разница в стоимости между самым дорогим и самым дешевым заказом из США.
SELECT (max(OrderSum) - min(OrderSum)) as DiffMaxMin FROM (
 -- USA Orders with sum
 SELECT OrderID, sum(ProductSum) as OrderSum FROM (
  -- USA Orders with sum for every product
  SELECT OD.OrderID, (OD.Quantity * P.Price) as ProductSum FROM [OrderDetails] OD, [Products] P
  WHERE P.ProductID = OD.ProductID and OD.OrderID in (
   -- USA Orders
   SELECT OrderID FROM [Orders]
   WHERE CustomerID in (
    -- USA Customers
    SELECT CustomerID FROM [Customers]
    WHERE Country='USA'
   )
  )
 )
 GROUP BY OrderID
)

--9. Выведите количество заказов у каждого их трех самых молодых сотрудников, а также имя и фамилию во второй колонке.
SELECT count(*) as OrderCount, FI FROM [Orders] O, (
 SELECT FirstName ||' '|| LastName as FI, EmployeeID FROM [Employees]
 ORDER BY BirthDate desc
 LIMIT 3
) E
WHERE O.EmployeeID = E.EmployeeID
GROUP BY FI

--10. Сколько банок крабового мяса всего было заказано.
-- ProductID=40, ProductName=Boston Crab Meat
-- Непонятно что означает комментарий: 24 - 4 oz tins
SELECT SUM(OD.Quantity) as CrabMeatQuantity FROM [OrderDetails] OD
WHERE OD.ProductID = 40