
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

--EXEC dbo.YilAdetHesapla Prosedürler EXEC komutu ile çalýþtýrýlýr. 

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

GRANT CONTROL ON dbo.YilAdetHesapla TO murat2 -- DROP omutu ile ayný komuttur.


-- EXEC store prosedure ve scalar valued functions ile select yetkisi verilir 
-- Table valued functions tablo gibi davrandýrðý için SELECT ile yetki verilir. 



--TRIGGER 
/* Ýkiye ayrýlýr AFTER VE INSTEAD OF 
INSERT UPDATE VE DELETE ile kullanýlýr 

INSTEAD OF 
Ýþlemi durdurak ve bloklamak için yapýlýr

AFTER yapýlan iþlemden sonra bir iþlem daha yapar.

Her ikisinde de transection (iþlem, bir bütünlük içerisinde olan iþlem )

BEGIN TRAN - Baþarýlý ise > COMMIT TRAN
BEGIN TRAN - Baþarýsýz ise > ROLL BACK TRAN */

CREATE TRIGGER CategorySilinemez ON Categories
INSTEAD OF DELETE  -- INSTEAD OF triggerlar yalzýldýðý iþlemin yerine çalýþýr.Burada DELETE iþlemi yerine devreye girer
--Categories tablosunda DELETE iþlemi denenirse TRIGGER devreye girer ve hata verip sonra da TRANSACTION ý geriye alýr
--YANÝ silmeye izin vermez 

AS 
BEGIN 
	RAISERROR('Categories Tablosu üzerinde kayýt silinemez',1,1) 
	ROLLBACK TRAN
END 


SELECT  * INTO Products_14122021 -- SELECT INTO iþlemi 
-- Tablonun kopyasýný oluþturur ancak PrimaryKey, Foreýgn Key ve baðlantýlýarý göstermez
FROM Products


--AFTER TRIGGER 

CREATE TRIGGER [dbo].[AddPriceHÝstory]ON Products
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
		INSERT INTO PriceHistory(ProductID,OldPrice,NewPrice,ÝslemTarihi)
		VALUES(@ProductID,@OldPrice,@NewPrice,getdate())
	END
END


UPDATE Products SET UnitPrice = 24 WHERE ProductID = 1

--Customerstan bir satýr silinince bir baþka tabloda yedek olarak ayný satýrý yazan trigger ý yaz.

CREATE TRIGGER [dbo].[CopyDeletedCustomers1]ON Customers -- Otomatik tabloyu oluþturuyor. ve siliyor
AFTER DELETE 
AS 

BEGIN
	
	SET NOCOUNT ON 

	SELECT * INTO Customers_14122021
	FROM deleted
END



ALTER TRIGGER [dbo].[CopyDeletedCustomers1]ON [dbo].Customers 
-- Var olan tabloya eklemek için 
AFTER DELETE 
AS 

BEGIN
	
	SET NOCOUNT ON 

	INSERT INTO Customers_14122021
	SELECT * FROM deleted
END



 
 -- BÝR TABLO BAÞKA TABLOYU ETKÝLECEK ,
 --PRODUCT ENTER , ProductID ,Amount, EnterDate
 -- AFTER TRIGGGER , iligili prouctId in miktarýný gien miktar kadar artýr.


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


--Ürün adeti eklerken yapýlan hatayý geri alacaðýz 


ALTER TRIGGER[dbo].[PrdouctDenyDelete] ON [dbo]. [ProductEnter]
INSTEAD OF UPDATE 
AS 
BEGIN 
	RAISERROR('Productneter Tablasunda UPDATE yapamazsýnýz',1,1) 
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


SELECT * FROM Products -- XML dosyayý olarak istenen tabloyu gösterir. 
FOR XML RAW
