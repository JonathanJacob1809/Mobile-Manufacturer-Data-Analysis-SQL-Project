select top 1* from DIM_CUSTOMER
select top 1* from DIM_DATE
select top 1* from DIM_LOCATION
select top 1* from DIM_MANUFACTURER
select top 1* from DIM_MODEL
select top 1* from FACT_TRANSACTIONS

-- Q1
select distinct State from(
select L.State, year(F.Date) as _year , sum(Quantity) as qty from
DIM_LOCATION as L
inner join
FACT_TRANSACTIONS as F
on L.IDLocation = F.IDLocation
where year(F.Date) >=2005
group by L.State, year(F.Date)
) as A

-- Q2
select top 1 L.State, count(*) as _count from
DIM_LOCATION as L
join FACT_TRANSACTIONS as F
on L.IDLocation = F.IDLocation
join DIM_MODEL as MO
on F.IDModel = MO.IDModel
join DIM_MANUFACTURER as MA
on MO.IDManufacturer = MA.IDManufacturer
where L.Country = 'US' and MA.Manufacturer_Name = 'Samsung'
group by L.State

-- Q3
select L.State,L.ZipCode,F.IDModel,count(*) as _cnt from
FACT_TRANSACTIONS as F
join DIM_LOCATION as L
on F.IDLocation = L.IDLocation
group by L.State,L.ZipCode,F.IDModel

-- Q4
select top 1 model_name, min(unit_price) as _price
from DIM_MODEL
group by model_name
order by _price

-- Q5
select t1.IDModel,avg(totalprice) as avg_price, sum(quantity) as _qty from
FACT_TRANSACTIONS as t1
join DIM_MODEL as t2
on t1.IDModel=t2.IDModel
join DIM_MANUFACTURER as t3
on t2.IDManufacturer = t3.IDManufacturer
where Manufacturer_Name in
			(select top 5 Manufacturer_Name from FACT_TRANSACTIONS as t1
			join DIM_MODEL as t2
			on t1.IDModel=t2.IDModel
			join DIM_MANUFACTURER as t3
			on t2.IDManufacturer = t3.IDManufacturer
			group by Manufacturer_Name
			order by sum(totalprice) desc)
group by t1.IDModel
order by avg_price desc;

-- Q6

SELECT T1.Customer_Name,AVG(totalprice) AS avg_price FROM
DIM_CUSTOMER AS T1
JOIN FACT_TRANSACTIONS AS T2
ON T1.IDCustomer = T2.IDCustomer
WHERE YEAR(date) = 2009
GROUP BY T1.Customer_Name
HAVING AVG(totalprice) > 500

select top 1* from DIM_CUSTOMER
select top 1* from DIM_DATE
select top 1* from DIM_LOCATION
select top 1* from DIM_MANUFACTURER
select top 1* from DIM_MODEL
select top 1* from FACT_TRANSACTIONS


-- Q7
SELECT * FROM (
SELECT TOP 5 IDMODEL FROM FACT_TRANSACTIONS
WHERE YEAR(DATE) = 2008
GROUP BY IDModel
ORDER BY SUM(QUANTITY) DESC ) AS A
INTERSECT
SELECT * FROM(
SELECT TOP 5 IDMODEL FROM FACT_TRANSACTIONS
WHERE YEAR(DATE) = 2009
GROUP BY IDModel
ORDER BY SUM(QUANTITY) DESC ) AS B
INTERSECT
SELECT * FROM (
SELECT TOP 5 IDMODEL FROM FACT_TRANSACTIONS
WHERE YEAR(DATE) = 2010
GROUP BY IDModel
ORDER BY SUM(QUANTITY) DESC) AS C

-- Q8
SELECT * FROM (
SELECT TOP 1 * FROM (
SELECT TOP 2 T3.Manufacturer_Name,YEAR(DATE) AS _year,SUM(totalprice) AS sales FROM FACT_TRANSACTIONS AS T1
JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel
JOIN DIM_MANUFACTURER AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE) = 2009
GROUP BY T3.Manufacturer_Name,YEAR(DATE)
ORDER BY sales DESC ) AS A
ORDER BY sales ASC
) AS B
UNION
SELECT * FROM (
SELECT TOP 1 * FROM (
SELECT TOP 2 T3.Manufacturer_Name,YEAR(DATE) AS _year,SUM(totalprice) AS sales FROM FACT_TRANSACTIONS AS T1
JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel
JOIN DIM_MANUFACTURER AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE) = 2010
GROUP BY T3.Manufacturer_Name,YEAR(DATE)
ORDER BY sales DESC ) AS A
ORDER BY sales ASC
) AS C

-- Q9

SELECT T3.Manufacturer_Name FROM FACT_TRANSACTIONS AS T1
JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel
JOIN DIM_MANUFACTURER AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE) = 2010
GROUP BY T3.Manufacturer_Name
EXCEPT
SELECT T3.Manufacturer_Name FROM FACT_TRANSACTIONS AS T1
JOIN DIM_MODEL AS T2
ON T1.IDModel = T2.IDModel
JOIN DIM_MANUFACTURER AS T3
ON T2.IDManufacturer = T3.IDManufacturer
WHERE YEAR(DATE) = 2009
GROUP BY T3.Manufacturer_Name

-- Q10

SELECT *, ((Avg_price - lag_price)/lag_price) AS Percentage_change FROM (
SELECT *, LAG(Avg_price,1) OVER(PARTITION BY IDCustomer ORDER BY _yr) AS lag_price FROM (
SELECT IDCustomer, YEAR(DATE) AS _yr, AVG(totalprice) AS avg_price, SUM(QUANTITY) AS qty FROM FACT_TRANSACTIONS
WHERE IDCustomer IN (
			SELECT TOP 10 IDCustomer FROM FACT_TRANSACTIONS
			GROUP BY IDCustomer
			ORDER BY SUM(totalprice) DESC )
GROUP BY IDCustomer, YEAR(DATE) 
) AS A
) AS B