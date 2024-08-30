select top 100*
from Sales$;

---- Q1 Find unique key column/s in dbo.Sales$ ----

-- # of rows - 806,485
select *
from Sales$;

-- # of rows - 806,485
select distinct Invoice, TransactionDate, DeliveryDate, EmpKey, ChannelKey, StoreID, 
ProductKey, CustomerKey, Qty, Cost, Price
from Sales$;

-- # of rows - 806,311
select distinct Invoice
from Sales$;

--# of rows - 806,485
select invoice
from Sales$;

-- # of rows - 0
select Invoice, TransactionDate, DeliveryDate, EmpKey, ChannelKey, StoreID, 
ProductKey, CustomerKey, Qty, Cost, Price, count(*)
from Sales$
group by Invoice, TransactionDate, DeliveryDate, EmpKey, ChannelKey, StoreID, 
ProductKey, CustomerKey, Qty, Cost, Price
having count(*) > 1;

--Invoice has duplicates because one invoice/transaction includes 
--all products sold in that transaction
select Invoice, count(*)
from Sales$
group by Invoice
having count(*) > 1;

-- # of rows - 0
--When selecting Invoice and Product Key together, we get no duplicates, therefore there are
--no duplicate rows with the same exact data
select Invoice, 
ProductKey, count(*)
from Sales$
group by Invoice, 
ProductKey
having count(*) > 1;

select Invoice, EmpKey, StoreID, 
ProductKey, CustomerKey, count(*)
from Sales$
group by Invoice, EmpKey, StoreID, 
ProductKey, CustomerKey
having count(*) > 1;

-- 0 rows returned, therefore no null values exist
select *
from Sales$
where Invoice is null or TransactionDate is null or DeliveryDate is null or EmpKey is null 
or ChannelKey is null or StoreID is null or ProductKey is null or CustomerKey is null 
or Qty is null or Cost is null or Price is null;


---- Q2 Print months when revenue of 50 million was crossed ----

-- Made a new column for Month_Year
select Invoice, TransactionDate, Price, CONCAT(Month(TransactionDate),':', 
Year(TransactionDate)) as Month_Year
from Sales$;

-- Found the total sales based on each Month and Year using Group By
select CONCAT(Month(TransactionDate),':', 
Year(TransactionDate)) as Month_Year, Sum(Price)
from Sales$
group by CONCAT(Month(TransactionDate),':', Year(TransactionDate))
order by Month_Year;

-- Added a Having clause to previous query to filter for sales greater than $50 million
select CONCAT(Month(TransactionDate),':', 
Year(TransactionDate)) as Month_Year, round((Sum(Price)/1000000),2) as Monthly_Sales_Millions
from Sales$
group by CONCAT(Month(TransactionDate),':', Year(TransactionDate))
having sum(Price) > 50000000
order by Month_Year;


---- Q3 Find Top 10 customers who spent most money on orders ----

-- First found top 10 sales based on CustomerKey using a Group By
select top 10 CustomerKey, round((Sum(Price)/1000000),2) as Total_Money_Spent_Millions
from Sales$
group by CustomerKey
order by sum(Price) desc;

-- Wanted to add CustomerName too so joined Sales and Customer table
select Sales$.CustomerKey, Customers$.CustomerName
from Sales$ join Customers$
on Sales$.CustomerKey = Customers$.CustomerKey;

-- Put the first two queries together (Group By query and Join query) for final results
select top 10 Sales$.CustomerKey, Customers$.CustomerName, round((Sum(Price)/1000000),2) as Total_Money_Spent_Millions
from Sales$ join Customers$
on Sales$.CustomerKey = Customers$.CustomerKey
group by Sales$.CustomerKey, Customers$.CustomerName
order by sum(Price) desc;


---- Q4 Print CustomerKey, Name and Country of top 10 spending customers ----

-- Joined Sales and Customer table followed by a Group by to find sales based on Customer
select top 10 Sales$.CustomerKey, Customers$.CustomerName, Customers$.Country, 
round((Sum(Price)/1000000),2) as Total_Money_Spent_Millions
from Sales$ join Customers$
on Sales$.CustomerKey = Customers$.CustomerKey
group by Sales$.CustomerKey, Customers$.CustomerName, Customers$.Country
order by sum(Price) desc;

---- Q5 Find Top 10 stores with most sales in 2006 and 2007. ----
---- Print results separately for 2006 and 2007. ----

--Typical aggregate function with a Group By in order to get top sales based on Store
-- Using Where clause to filter for sales in specified year
select top 10 StoreID, round((Sum(Price)/1000000),2) as Sales_In_2006_Millions
from Sales$
where Year(TransactionDate) = 2006
group by StoreID
order by sum(Price) desc;

select top 10 StoreID, round((Sum(Price)/1000000),2) as Sales_In_2007_Millions
from Sales$
where Year(TransactionDate) = 2007
group by StoreID
order by sum(Price) desc;

---- Q6 Between years 2006 and 2007 which stores were part of Top 10 sales list ----

--Typical aggregate function with a Group By in order to get top sales based on Store
-- Using Where clause to filter for sales between 2006 and 2007

select top 10 StoreID, round((Sum(Price)/1000000),2) as Sales_Millions_2006_to_2007
from Sales$
where Year(TransactionDate) between 2006 and 2007
group by StoreID
order by sum(Price) desc;

---- Q7 Which product is most famous with buyers of US ----

-- Found total quantity of products sold
select ProductKey, sum(Qty)
from Sales$
group by ProductKey;

-- Joined Sales and Customers table and used Group by to find total products sold
-- then filtered by US and found top product sold in the US
select top 5 s.ProductKey, sum(Qty) as Qty_of_Products, c.Country
from Sales$ as s
join Customers$ as c
on s.CustomerKey = c.CustomerKey
group by c.Country, s.ProductKey
having Country = 'US'
order by sum(Qty) desc;


---- Q8 Find all details of products(from dbo.products$) which are top 5 in previous query ----

-- Used query from previous question, and Joined Products table to it
-- then selected top 5 and included all of the details from Products table
select top 5 s.ProductKey, sum(Qty) as Qty_of_Products, c.Country, p.ProductDescription,
p.SubCategoryKey, p.Brand, p.Type, p.Color, p.ShipDays, p.Status
from Customers$ as c
join Sales$ as s
on c.CustomerKey = s.CustomerKey
join Products$ as p
on s.ProductKey = p.ProductKey
group by c.Country, s.ProductKey, p.ProductDescription,
p.SubCategoryKey, p.Brand, p.Type, p.Color, p.ShipDays, p.Status
having Country = 'US'
order by sum(Qty) desc;

-- Using Subquery to get answer
select *
from Products$
where ProductKey IN 
	(select top 5 s.ProductKey
	from Customers$ as c
	join Sales$ as s
	on c.CustomerKey = s.CustomerKey
	group by s.ProductKey, c.Country
	having Country = 'US'
	order by sum(Qty) desc);


---- Q9 Find out most successful channel responsible for sales and how much sales ----
---- it have done till now in millions ----

-- Found total sales based on Channel by using a Group by
select ChannelKey, sum(Price) as Total_Sales_by_Channel
from Sales$
group by ChannelKey
order by sum(Price) desc;

-- Using previous query, found top Channel and converted Sales into millions and rounded
select top 1 s.ChannelKey, c.Channel, round((sum(Price)/1000000), 2) as Channel_Total_Sales_Millions
from Sales$ s
Join Channel$ c
on s.ChannelKey = c.ChannelKey
group by s.ChannelKey, c.Channel
order by sum(Price) desc;

select Channel
from Channel$
where ChannelKey = 6;


---- Q10 Which channel is most successful in latest 5 years in data (Most recent 5 years) ----
---- compute dynamically which are latest 5 years in data ----


select ChannelKey, sum(Price) as SalesLast5Years
from Sales$
where Year(TransactionDate) between dateadd(Year, -5, datepart(Year, getdate())) 
and datepart(Year, getdate())
group by ChannelKey
order by sum(Price) desc;

select ChannelKey, sum(Price) as SalesLast5Years
from Sales$ 
group by ChannelKey, TransactionDate
having Year(TransactionDate) > 
(select 
dateadd(Year, -5, Year(max(TransactionDate))))
order by sum(Price) desc;

select ChannelKey, sum(Price)
from Sales$
where TransactionDate between '2008-01-01' and '2013-01-02'
group by ChannelKey
order by sum(Price) desc;

select min(TransactionDate), max(TransactionDate)
from Sales$;

select sum(Price)
from Sales$
where ChannelKey = 6 and TransactionDate between '2008-01-01' and '2013-01-02';

select sum(Price)
from Sales$
where ChannelKey = 8 and TransactionDate between '2008-01-01' and '2013-01-02';

select ChannelKey, TransactionDate
from Sales$
where Year(TransactionDate) = Year(max(TransactionDate));

select Year(max(TransactionDate)) - 5
from Sales$;

-- Correct Answer, Used a Group By to get sales by ChannelKey, then used a subquery to 
-- calculate the last 5 years of data and used a Where clause to filter by those last 5 years
select ChannelKey, round((Sum(Price)/1000000),2) as SalesLast5YearsMillions
from Sales$
where Year(TransactionDate) >= (
select Year(max(TransactionDate)) - 5
from Sales$)
group by ChannelKey
order by sum(Price) desc;

---- Q11 Find out which is most profitable year and because of which product ----
---- and how much top product contributed in that year in millions ----

select top 1 Year(TransactionDate) as Most_Profitable_Year, 
sum(Price) as Most_Profitable_Year_Sales 
from Sales$
group by Year(TransactionDate)
order by sum(Price) desc;

select top 1 ProductKey, round((sum(Price)/1000000), 2) as Product_Sales_Millions
from Sales$
where Year(TransactionDate) = 2004
group by ProductKey
order by sum(Price) desc;


select top 1 ProductKey, Year(TransactionDate) as Most_Profitable_Year, 
round((sum(Price)/1000000), 2) as Most_Profitable_Product_Sales_Millions
from Sales$
where Year(TransactionDate) = (
select top 1 Year(TransactionDate)
from Sales$
group by Year(TransactionDate)
order by sum(Price) desc)
group by ProductKey, Year(TransactionDate)
order by sum(Price) desc;


---- Q12 For each country find out in which year they spent most money ----
---- Use Customer and Sales table ----

--***** How do I filter out just the top year for each group of countries *****
-- Rank or Dense rank maybe??
select c.Country, round((Sum(Price)/1000000),2) as TotalSpentThatYearMillions, Year(s.TransactionDate) as 'Year',
dense_rank() over(Partition by c.Country order by sum(Price) desc) as Year_rank
from Sales$ as s
Join Customers$ as c
on s.CustomerKey = c.CustomerKey
group by c.Country, Year(s.TransactionDate)
order by Country, sum(s.Price) desc;


select e1.*
from (
	select d1.Country, d1.year_sale, d1.sales,
	DENSE_RANK() over(partition by d1.Country order by
	d1.sales desc) as rank
		from (
			select c1.Country, c1.year_sale ,sum(Price) as sales
			from (
				select a1.*, b1.Country,
				year(TransactionDate) as year_sale
				from dbo.sales$ a1 inner join dbo.Customers$ b1
				on a1.CustomerKey =b1.CustomerKey) c1
			group by c1.Country, c1.year_sale) 
		d1 ) e1
where e1.rank = 1;


---- Q13. Find out top performing employees for year 2011 in terms of number of orders assisted ----
select distinct EmpKey
from Sales$
order by EmpKey;

select EmpKey, count(Invoice) as Num_of_Orders
from Sales$
where Year(TransactionDate) = 2011
group by EmpKey
order by count(Invoice) desc;


---- Q14. Find out top performing employees for year 2011 in terms of 
---- total revenue generated from sales ----
select EmpKey, round((sum(Price)/1000000),2) as Employee2011TotalSalesMillions
from Sales$
where Year(TransactionDate) = 2011
group by EmpKey
order by sum(Price) desc;


select *
from Sales$;
