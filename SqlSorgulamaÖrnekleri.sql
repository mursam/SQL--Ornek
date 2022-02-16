-- ��lem adetlerine g�re en fazla kayd� olan 3 �al��an�n ad�n� ve i�lem adedini yaz�n
--BUnu bir view olarak kaydedip test edin , sonra da yeni bir kullan�c� i�in select yetkisi veriniz 
 USE Northwind


ALTER VIEW EnCokIslemYapan 

AS


SELECT TOP 3 WITH TIES E.FirstName ,E.EmployeeID, COUNT (*) as Adet
FROM Orders O 
JOIN Employees E  ON E.EmployeeID = O.EmployeeID
GROUP By E.EmployeeID, E.FirstName
HAVING COUNT (*)>=125
ORDER BY COUNT(*) desc 


GRANT SELECT ON EnCokIslemYapan TO murat2

--- �R�NLER�N ADNI SUPPL�ERINI CATEGORYS�N� L�STELEY�N VE ADA G�RE TERS SIRALAMA YAPIN VE BUNU B�R V�EW OLARAK KAYDED�N

CREATE VIEW vw_UrunAdiFiyati
AS 
SELECT P.ProductName , C.CategoryName, S.CompanyName
FROM Products AS P
LEFT JOIN Suppliers AS S ON P.SupplierID= S.SupplierID
LEFT JOIN Categories AS C ON C.CategoryID = P.CategoryID
WHERE P.UnitPrice BETWEEN 20 AND 25


SELECT * FROM vw_UrunAdiFiyati
ORDER BY ProductName DESC

ALTER FUNCTION [dbo].[fn_Productswith2025] (@UnitPrice1 as  int , @UnitPrice2 as int)
RETURNS TABLE
AS 

RETURN
SELECT P.ProductName/ , C.CategoryName, S.CompanyName, P.UnitPrice
FROM Products AS P
LEFT JOIN Suppliers AS S ON P.SupplierID= S.SupplierID
LEFT JOIN Categories AS C ON C.CategoryID = P.CategoryID
WHERE P.UnitPrice BETWEEN @UnitPrice1 AND @UnitPrice2

SELECT * FROM [dbo].[fn_Productswith2025](0,10) 
ORDER BY UnitPrice DESC


---�al��anlar�n ad�n� soyad�n� telefonlar�n� ve kime raporlad�klar�n� , raporlad�klar� ki�ilerin adlar�
CREATE VIEW EmployeeManagerList
AS
SELECT Employee.LastName, Employee.FirstName , Employee.FirstName + ' ' + Employee.LastName AS FullName, Employee.HomePhone, Employee.ReportsTo, ISNULL(Manager.FirstName,'-') AS ManagerName
FROM Employees AS Employee
LEFT JOIN Employees AS Manager ON Manager.EmployeeID = Employee.ReportsTo


SELECT * FROM EmployeeManagerList

---Hocan�n att��� kaynaktan 8.soru 
SET DATEFORMAt DMY
SELECT CONVERT(varchar,OrderDate,103) , convert(varchar,ShippedDate,103), CustomerID, Freight
FROM Orders
WHERE OrderDate = '19/05/1997'


--SORU 22
SELECT FirstName, LastName , City , Region
FROM Employees 
WHERE Region = 'WA' AND City NOT IN ('Seattle')

--SORU 17
SELECT CompanyName, ContactName, City
FROM Customers
WHERE City LIKE 'A%' OR City like 'B%' -- LEFT(City,1) = 'A' OR LEFT(City,1) = 'B'
ORDER BY ContactName DESC

--SORU 35 
SET DATEFORMAT DMY
SELECT C.CompanyName , Count(*) AS NumOrders  
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
WHERE O.OrderDate > ='31.12.1996'
GROUP BY C.CompanyName 
HAVING Count(*) > 15
ORDER BY Count(*) DESC


---SORU 36 


SELECT  OD.OrderID , C.CompanyName, (OD.UnitPrice * Od.Quantity) * (1- OD.Discount) AS TotalPrice
FROM [Order Details] OD
JOIN Orders O ON O.OrderID = OD.OrderID
JOIN Customers C ON C.CustomerID = O.CustomerID
WHERE (OD.UnitPrice * Od.Quantity) * (1- OD.Discount) > 10000
ORDER BY (OD.UnitPrice * Od.Quantity) * (1- OD.Discount) DESC


--SORU 33
SELECT E.FirstName, E.LastName , O.OrderID
FROM Orders O 
JOIN Employees E On O.EmployeeID = E.EmployeeID
WHERE O.ShippedDate > O.RequiredDate
ORDER BY E.LastName, O.OrderID

--Shippers tabolsunda sat�r silindi�inde ba�ka bir yedek tabloda silinen sat�r yedeklensin.

CREATE TRIGGER [dbo].[CopyDeletedShippers] ON Shippers
AFTER DELETE
 AS 
BEGIN
	
	
	
	SELECT*INTO Shippers_Delete
	FROM deleted
	
END



--SYS VIEWS SORGULARI
--- Bu sunucuda hangi database ler var 

SELECT database_id, name 
FROM sys.databases

--- Database deki tablolar� g�rmek i�in

SELECT*FROM sys.tables

--database deki tablo adlar�
SELECT Name FROM sys.views

SELECT * FROM sys.triggers


 SELECT*FROM sys.objects WHERE object_id  = 117575457

SELECT t.name as triggername, o.name as tablename
 FROM sys.triggers AS t
 JOIN sys.objects as o ON o.object_id = t.parent_id
 ORDER BY tablename, triggername

 SELECT * FROM sys.triggers 


 -- ORder details tablosuna yeni bir sat�r eklendi�ine ilgili �r�nden stok d���m� yaps�n , ve yeteri kadar stok yoksa izin vermesin


--1.AD�m� INSTEAD OF TRIGGERI
 CREATE TRIGGER UrunStockKontrolu ON [Order Details]
 INSTEAD OF INSERT --Instead of triggerlar�nda if ko�ulu kullan�l�yorsa else de yap�lmak istenen i�lem yap�laml�d�r.

 AS 

 BEGIN 
	set nocount on 
	
	DECLARE @Quantity as smallint , @UnitsInStock as smallint 
	SELECT @Quantity = Quantity FROM inserted

	SELECT @UnitsInStock = UnitsInStock FROM Products WHERE ProductID = (SELECT ProductID FROM inserted)
	
	IF @Quantity>@UnitsInStock
	BEGIN 
		RAISERROR('Stok Yeterli DE�ildir', 1,1)
		ROLLBACK TRAN
	END 
	ELSE 
	BEGIN
		INSERT INTO [Order Details] (OrderID,ProductID,UnitPrice,Quantity,Discount)
		SELECT OrderID,ProductID,UnitPrice,Quantity,Discount
		FROM inserted
	END

 END
 --EKLENEN �R�N� TABLODAN D���R�YOR

 ALTER TRIGGER UrunEkleme ON [Order Details]
 AFTER INSERT 

 AS 
 Declare @ProductID as int, @Quantity as int 

 SELECT @Quantity = Quantity FROM inserted

 SELECT @ProductID = ProductID FROM inserted

 UPDATE Products

 SET UnitsInStock = UnitsInStock - @Quantity

 WHERE ProductID  = @ProductID



 INSERT INTO [Order Details] (OrderID,ProductID,UnitPrice,Quantity,Discount)
 
 VALUES (10248,1,100,3,0)

 SELECT OrderID , Quantity,ProductID
 FROM [Order Details]
 WHERE ProductID = 1

 SELECT ProductID,UnitsInStock,ProductName
 FROM Products
 WHERE ProductID = 1
 
 ---Girilen yanl�� sipari�i d�zeltip geri vermek i�in yap.. 