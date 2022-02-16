
ALTeR PROCEDURE dbo.YilAdetHesapla
AS

DELETE YilAdet

INSERT INTO YilAdet (Yil,Adet)


SELECT YEAR (O.OrderDate) AS 'YIL', SUM(OD.Quantity) AS 'ADET'
FROM [Order Details]  OD
JOIN Orders O ON OD.OrderID = O.OrderID
GROUP BY YEAR(O.OrderDate)
ORDER BY YEAR(O.OrderDate)

EXEC dbo.YilAdetHesapla

--EXEC dbo.YilAdetHesapla Prosed�rler EXEC komutu ile �al��t�r�l�r. 

CREATE FUNCTION [dbo]. [fn_TableCategories](@CategoryName as varchar(50))
RETURNS TABLE 

AS 

RETURN 

SELECT P.ProductName , C.CategoryName, P.UnitPrice
FROM Products P
JOIN Categories C ON C.CategoryID = P.CategoryID
WHERE CategoryName = @CategoryName



GRANT SELECT ON dbo.fn_TableCategories TO murat2


GRANT EXEC ON  dbo.SumSales TO murat2

GRANT EXEC ON dbo.YilAdetHesapla TO murat2

GRANT CONTROL ON dbo.YilAdetHesapla TO murat2 -- DROP omutu ile ayn� komuttur.


-- EXEC store prosedure ve scalar valued functions ile select yetkisi verilir 
-- Table valued functions tablo gibi davrand�r�� i�in SELECT ile yetki verilir. 



--TRIGGER 
/* �kiye ayr�l�r AFTER VE INSTEAD OF 
INSERT UPDATE VE DELETE ile kullan�l�r 

INSTEAD OF 
��lemi durdurak ve bloklamak i�in yap�l�r

AFTER yap�lan i�lemden sonra bir i�lem daha yapar.

Her ikisinde de transection (i�lem, bir b�t�nl�k i�erisinde olan i�lem )

BEGIN TRAN - Ba�ar�l� ise > COMMIT TRAN
BEGIN TRAN - Ba�ar�s�z ise > ROLL BACK TRAN */

CREATE TRIGGER CategorySilinemez ON Categories
INSTEAD OF DELETE  -- INSTEAD OF triggerlar yalz�ld��� i�lemin yerine �al���r.Burada DELETE i�lemi yerine devreye girer
--Categories tablosunda DELETE i�lemi denenirse TRIGGER devreye girer ve hata verip sonra da TRANSACTION � geriye al�r
--YAN� silmeye izin vermez 

AS 
BEGIN 
	RAISERROR('Categories Tablosu �zerinde kay�t silinemez',1,1) 
	ROLLBACK TRAN
END 


SELECT  * INTO Products_14122021 -- SELECT INTO i�lemi 
-- Tablonun kopyas�n� olu�turur ancak PrimaryKey, Fore�gn Key ve ba�lant�l�ar� g�stermez
FROM Products


--AFTER TRIGGER 

CREATE TRIGGER [dbo].[AddPriceH�story]ON Products
AFTER UPDATE 
AS 

BEGIN
	
	SET NOCOUNT ON 

	DECLARE @ProductID AS int, @OldPrice as money, @NewPrice as money

	SELECT @ProductID = ProductID
	FROM deleted

	SELECT @OldPrice = UnitPrice 
	FROM deleted

	SELECT @NewPrice = UnitPrice
	FROM inserted

	IF @OldPrice = @NewPrice
	
	BEGIN
		INSERT INTO PriceHistory(ProductID,OldPrice,NewPrice,�slemTarihi)
		VALUES(@ProductID,@OldPrice,@NewPrice,getdate())
	END
END


UPDATE Products SET UnitPrice = 24 WHERE ProductID = 1

--Customerstan bir sat�r silinince bir ba�ka tabloda yedek olarak ayn� sat�r� yazan trigger � yaz.

CREATE TRIGGER [dbo].[CopyDeletedCustomers1]ON Customers -- Otomatik tabloyu olu�turuyor. ve siliyor
AFTER DELETE 
AS 

BEGIN
	
	SET NOCOUNT ON 

	SELECT * INTO Customers_14122021
	FROM deleted
END



ALTER TRIGGER [dbo].[CopyDeletedCustomers1]ON [dbo].Customers 
-- Var olan tabloya eklemek i�in 
AFTER DELETE 
AS 

BEGIN
	
	SET NOCOUNT ON 

	INSERT INTO Customers_14122021
	SELECT * FROM deleted
END



 
 -- B�R TABLO BA�KA TABLOYU ETK�LECEK ,
 --PRODUCT ENTER , ProductID ,Amount, EnterDate
 -- AFTER TRIGGGER , iligili prouctId in miktar�n� gien miktar kadar art�r.


 CREATE TRIGGER [dbo].[AddProductStockOnEnter] ON ProductEnter
AFTER INSERT
AS 

BEGIN
	
	SET NOCOUNT ON 

	DECLARE @ProductID AS int, @Amount as int

	SELECT @ProductID = ProductID
	FROM inserted

	SELECT @Amount = Amount
	FROM inserted

	UPDATE Products
	SET UnitsInStock = UnitsInStock + @Amount
	WHERE ProductID = @ProductID

	
	
END

 CREATE TRIGGER [dbo].[AddProductStockOnEnter] ON ProductEnter
AFTER INSERT
AS 

BEGIN
	
	SET NOCOUNT ON 

	DECLARE @ProductID AS int, @Amount as int

	SELECT @ProductID = ProductID
	FROM inserted

	SELECT @Amount = Amount
	FROM inserted

	UPDATE Products
	SET UnitsInStock = UnitsInStock + @Amount
	WHERE ProductID = @ProductID

	
	
END


--�r�n adeti eklerken yap�lan hatay� geri alaca��z 


ALTER TRIGGER[dbo].[PrdouctDenyDelete] ON [dbo]. [ProductEnter]
INSTEAD OF UPDATE 
AS 
BEGIN 
	RAISERROR('Productneter Tablasunda UPDATE yapamazs�n�z',1,1) 
	ROLLBACK TRAN
END 




ALTER TRIGGER [dbo].[DeleteProductEnter] ON ProductEnter
AFTER DELETE
AS 

BEGIN
	
	SET NOCOUNT ON 

	DECLARE @ProductID AS int, @Amount as int

	SELECT @ProductID = ProductID
	FROM deleted

	SELECT @Amount = Amount
	FROM deleted

	UPDATE  Products
	SET UnitsInStock = UnitsInStock - @Amount
	WHERE ProductID = @ProductID
	


	
	
END


SELECT * FROM Products -- XML dosyay� olarak istenen tabloyu g�sterir. 
FOR XML RAW
