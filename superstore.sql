--Xây dựng cơ sở sử dụng SALES
create database SALES
use SALES
--Tạo bảng TableCustomer 
create table TableCustomer 
(CustomerID varchar(15) not null,
CustomerName varchar(50) not null,
Segment varchar(11) not null,
Country varchar(40) not null,
Region varchar(40) not null,
Market varchar(12) not null)

--Tạo bảng TableProduct
create table TableProduct 
(ProductID char(11) not null,
ProductName varchar(50) not null,
SubCategory varchar(15) not null,
Category varchar(15) not null)

--Tạo bảng TableSummary
create table TableSummary
(RowID varchar(5)not null,
OrderID varchar(30) not null,
OrderDate date not null,
ShipDate date not null,
ShipMode varchar(15) not null,
OrderPriority varchar(8) not null,
CustomerID varchar(15) not null,
PostalCode varchar(5),
City varchar(30) not null,
States varchar(25) not null,
ProductID char(11) not null,
Sale money not null,
Quantity int not null,
Discount money not null,
Profit money not null,
ShippingCost money not null)
--
select * from TableSummary
select * from TableCustomer
select * from TableProduct
--Lọc ra các hàng trùng ở bảng TableProduct rồi tạo thành 
--thêm ràng buộc UNIQUE cho cột làm khóa chính và tạo khóa chính
select distinct * into Product from TableProduct
ALTER TABLE Product ADD UNIQUE (ProductID)
ALTER TABLE Product ADD CONSTRAINT PK_Product PRIMARY KEY (ProductID)
--Lọc ra các hàng trùng ở bảng TableCustomer rồi tạo thành 
--thêm ràng buộc UNIQUE cho cột làm khóa chính và tạo khóa chính
select distinct * into Customer from TableCustomer
ALTER TABLE Customer ADD UNIQUE (CustomerID)
ALTER TABLE Customer ADD CONSTRAINT PK_Customer PRIMARY KEY (CustomerID)
--Lọc ra các hàng trùng ở bảng TableSummary rồi tạo thành 
--thêm ràng buộc UNIQUE cho cột làm khóa chính và tạo khóa chính
select distinct * into Summary from TableSummary
ALTER TABLE Summary ADD UNIQUE (RowID)
ALTER TABLE Summary ADD CONSTRAINT PK_Summary PRIMARY KEY (RowID)
-- Khóa ngoại bảng Product
ALTER TABLE Summary ADD CONSTRAINT FK_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
-- Khóa ngoại bảng Customer
ALTER TABLE Summary ADD CONSTRAINT FK_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
--
select * from Customer
select * from Summary
select * from Product

--Cau1: Tính lợi nhuận của cửa hàng theo tháng trong 4 năm.
select year(OrderDate) as Nam, month(OrderDate) as Thang, sum(profit) as Tong_LN
from Summary
group by year(OrderDate), month(OrderDate) 
order by Nam, Thang 

--Cau2: Tìm mặt hàng bán chạy nhất, mặt hàng nào bán kém nhất trong từng năm.
select year(Summary.OrderDate) as Nam,Product.ProductName as TenSP, Sum(Summary.Sale) as tong_doanh_thu into Bang2 
from Summary inner join Product on Summary.ProductID = Product.ProductID
group by year(Summary.OrderDate),Product.ProductName

DECLARE @nam int = 2014;
WHILE @nam <2018
BEGIN
	select Nam,TenSP, tong_doanh_thu as MH_Max from Bang2 
	where (Nam = @nam) and (tong_doanh_thu = (select max(tong_doanh_thu) from Bang2 group by Nam having Nam = @nam))
    select Nam,TenSP, tong_doanh_thu as MH_Min from Bang2
	where (Nam = @nam) and (tong_doanh_thu = (select min(tong_doanh_thu) from Bang2 group by Nam having Nam = @nam))
    SET @nam = @nam + 1;
END
drop table Bang2

--Câu 3: Tháng nào bán nhiều nhất, tháng nào bán ít nhất trong từng năm?
select year(Summary.OrderDate) as Nam,Month(Summary.OrderDate) as Thang, Sum(Summary.Sale) as tong_doanh_thu into Bang3
from Summary inner join Product on Summary.ProductID = Product.ProductID
group by year(Summary.OrderDate),Month(Summary.OrderDate)

DECLARE @nam int = 2014;
WHILE @nam <2018
BEGIN
	select Nam,Thang, tong_doanh_thu as Thang_Max from Bang3 
	where (Nam = @nam) and (tong_doanh_thu = (select max(tong_doanh_thu) from Bang3 group by Nam having Nam = @nam))
    select Nam,Thang, tong_doanh_thu as Thang_Min from Bang3
	where (Nam = @nam) and (tong_doanh_thu = (select min(tong_doanh_thu) from Bang3 group by Nam having Nam = @nam))
    SET @nam = @nam + 1;
END
drop table Bang3

--Câu 4: khách hàng nào có tổng hóa đơn là nhiều tiền nhất? khách hàng nào có tổng hóa đơn là ít tiền nhất? 
--trung bình hóa đơn của mỗi khách hàng là bao nhiêu?
select Customer.CustomerID, Customer.CustomerName,sum(Summary.Sale) as Tong_tien into Bang4
from Customer inner join Summary on Customer.CustomerID=Summary.CustomerID
group by Customer.CustomerID,Customer.CustomerName

select CustomerID,CustomerName, Tong_tien as Tong_tien_Max from Bang4 
where Tong_tien = (select max(Tong_tien) from Bang4)
select CustomerID,CustomerName, Tong_tien as Tong_tien_Min from Bang4 
where Tong_tien = (select min(Tong_tien) from Bang4)
select avg(Tong_tien) as Tong_tien_TB from Bang4

--Câu 5:khách hàng nào mua nhiều lần nhất? khách hàng nào mua ít lần nhất? 
--trung bình mỗi khách hàng đã mua bao nhiêu lần?
select distinct Customer.CustomerID, Customer.CustomerName,Summary.OrderID into Bang5a
from Customer inner join Summary on Customer.CustomerID=Summary.CustomerID
select * from Bang5a
--drop table Bang5
select CustomerID,CustomerName,count(*) as So_lan into Bang5b from Bang5a
group by CustomerID,CustomerName
order by So_lan DESC
select CustomerID,CustomerName, So_lan as So_lan_Max from Bang5b
where So_lan = (select max(So_lan) from Bang5b)
select CustomerID,CustomerName, So_lan as So_lan_Min from Bang5b
where So_lan = (select min(So_lan) from Bang5b)
select avg(So_lan) as So_lan_TB from Bang5b

--Câu 7: Có tổng cộng bao nhiêu khách hàng đã mua hàng ở mỗi tháng trong từng năm?
select distinct year(Summary.OrderDate) as Nam,Month(Summary.OrderDate) as Thang, Summary.CustomerID into Bang7 from Summary
--drop table Bang7
select Nam,Thang,count(CustomerID) as So_lan from Bang7
group by Nam,Thang
order by Nam,Thang

--Câu 8: Mỗi nhóm hàng có doanh số bán là bao nhiêu ở mỗi tháng trong từng năm?
select year(Summary.OrderDate) as Nam,month(Summary.OrderDate) as Thang,Product.Category,
Sum(Summary.Sale) as Sale_total
from Summary inner join Product on Summary.ProductID=Product.ProductID
group by year(Summary.OrderDate),month(Summary.OrderDate),Product.Category
order by Nam,Thang,Category,Sale_total

--Câu 9: So sánh doanh số của các phân khúc khách hàng theo mỗi tháng trong năm.
select year(Summary.OrderDate) as Nam,month(Summary.OrderDate) as Thang,Customer.Segment,
Sum(Summary.Sale) as Sale_total
from Summary inner join Customer on Summary.CustomerID=Customer.CustomerID
group by year(Summary.OrderDate),month(Summary.OrderDate),Customer.Segment
order by Nam,Thang,Segment,Sale_total

--Câu 10: So sánh doanh số ở các nước theo năm.
Select year(Summary.OrderDate) as Nam,Customer.Country,Sum(Summary.Sale) as Sale_total 
from Summary inner join Customer on Summary.CustomerID=Customer.CustomerID
group by year(Summary.OrderDate),Customer.Country
order by Nam, Sale_total DESC

--Câu 11: Tìm số đơn hàng giao trễ cho từng chế độ giao hàng.
select * from Summary
where 
((datediff(day,OrderDate,ShipDate)>0) AND (ShipMode='Same Day')) 
or ((datediff(day,OrderDate,ShipDate)>3) AND (ShipMode='First Class'))
or ((datediff(day,OrderDate,ShipDate)>5) AND (ShipMode='Second Class'))
or ((datediff(day,OrderDate,ShipDate)>7) AND (ShipMode='Standard Class'))

drop table Bang2










