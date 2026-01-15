--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction ParseCharToInt    Script Date: 03.03.2024 16:44:00 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE FUNCTION ParseCharToInt (@symbol nchar)
--RETURNS int
--AS
--BEGIN
--	declare @tmpNumber int;
--		IF (dbo.CharIsNumber(@symbol)=0)
--			SET @tmpNumber=0
--		ELSE
--			IF (@symbol='0')
--					SET @tmpNumber=0
--			ELSE IF (@symbol='1')
--					SET @tmpNumber=1
--			ELSE IF (@symbol='2')
--					SET @tmpNumber=2
--			ELSE IF (@symbol='3')
--					SET @tmpNumber=3
--			ELSE IF (@symbol='4')
--					SET @tmpNumber=4
--			ELSE IF (@symbol='5')
--					SET @tmpNumber=5
--			ELSE IF (@symbol='6')
--					SET @tmpNumber=6
--			ELSE IF (@symbol='7')
--					SET @tmpNumber=7
--			ELSE IF (@symbol='8')
--					SET @tmpNumber=8
--			ELSE 	SET @tmpNumber=9

--	return @tmpNumber
--END


--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction CharIsNumber    Script Date: 03.03.2024 16:44:00 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE FUNCTION CharIsNumber (@symbol nchar)
--RETURNS bit
--AS
--BEGIN
--	declare @bitNumber bit;
--		IF (@symbol='0' OR @symbol='1' OR @symbol='2' OR @symbol='3'  OR @symbol='4'  OR @symbol='5'  OR @symbol='6'  OR @symbol='7'  OR @symbol='8'  OR @symbol='9')
--				SET @bitNumber=1
--		ELSE
--				SET @bitNumber=0

--		return @bitNumber
--END

--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction ParseNvarcharToNumber    Script Date: 03.03.2024 20:44:00 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE FUNCTION ParseNvarcharToNumber (@str nvarchar(25))
--RETURNS int
--AS
--BEGIN
--	/*
--	Отличие этой функции, от стандартного приведения nvarchar к INT в том, что если не удаётся привести к числу,
--	то функция вернёт NULL, который в последующем можно обработать
--	*/
--	declare @number INT;												--число, которое будет возвращено
--	declare @i INT;														--итератор для цикла
--	declare @IsNegative BIT;											--показатель, положительное или отрицательное число
--	declare @symbol nchar;												--переменная в которую извлекаются отдельные символы из строки

--	--проверка на положительное или отрицательное число
--	SET @symbol = SUBSTRING(@str,1,1);
--	IF @symbol='-' 
--		SET @IsNegative=1
--	ELSE
--		SET @IsNegative=0

--	/*
--		Цикл перевода извлекает последний символ в строке, проверяет, является-ли этот символ цифрой, в случае положительного значения
--		в переменную @tmpNumber присваивается значение цифры в формате INT, если не цифра, тогда присваивается значения NULL.
--		Далее итератор @i увеличивается на 1, и т.д., до тех пор, пока не будет извлечён первый символ (или втрой, в случае отрицательного
--		числа).
--		Все извлечённые символы, кроме последнего(который был извлечён первым) умножаются на множитель, который переводит извлечённые числа
--		в дестяки, сотни и т.д., в зависимости от порядка. Множитель изменяется, в зависимости от итератора @i.
--		Если переменной @tmpNumber будет присвоено значение NULL, при последующей проверке, возвращаемому число будет присвоено также
--		значение NULL, а итератору @i значение для выхода из цикла 
--	*/
--	SET @i=0;
--	SET @number=0
--	WHILE (@i+@IsNegative)<LEN(@str)									--такое условие сделано,что бы не переводить первый символ, если число отрицательное
--		BEGIN	
--			SET @i=@i+1;

			
--			declare @tmpNumber int;										--переменная в которую помещаются преобразованные символы из строки
--			declare @multiplayer int;									--множитель, для преобразования в десятки, сотни и т.д.
--			SET @multiplayer=1

--			SET @symbol = SUBSTRING(@str,LEN(@str)-@i+1,1);				--извлечение происходит с конца, для того, что бы в последствии корректно сложить

--			SET @tmpNumber = dbo.ParseCharToInt(@symbol)				--символ преобразуется в число типа int от 0 до 9, либо NULL, если был другой символ		
--			BEGIN
--				IF (@tmpNumber IS NOT NULL)								--проверка на NULL
--					BEGIN

--						declare @j int;									--итератор, для цикла WHILE
--						SET @j=1										--присваивается значение 1, что бы избежать умножение множителя, при первом символе с конца
--						WHILE @j<@i
--							BEGIN
--								SET @j=@j+1;							--увеличивается итератор для приближения к условию выхода из цикла
--								SET @multiplayer=@multiplayer*10		--перемножается множитель, что бы получить число следующего порядка
--							END

--						SET @tmpNumber = @tmpNumber*@multiplayer		--умножается на множитель, что бы получить число следующего порядка
--						SET @number=@number+@tmpNumber
--					END
--				ELSE
--					BEGIN
--						SET @number=NULL								--если, какой-то из символов не число, присваивается значение NULL и выходит из цикла
--						SET @i=LEN(@str)

--					END
--			END

--		END;

--	IF (@IsNegative = 1 AND @number  IS NOT NULL)
--		BEGIN
--			SET @number=-1*@number
--		END
--	return @number
--END

--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction GetCountFromPackage    Script Date: 03.03.2024 23:31:45 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE FUNCTION GetCountFromPackage (@package nvarchar(25))
--RETURNS INT
--AS
--BEGIN
--	declare @count int;
--	IF (CHARINDEX('упак',@package)>0)
--		BEGIN
--			IF (LEN(@package)<>4)
--				BEGIN
--					declare @tmpstr nvarchar(25)
--					SET @tmpstr=SUBSTRING(@package,7,LEN(@package)-(7+3))
--					SET @tmpstr = REPLACE (@tmpstr, ' ', '')
--					SET @count = dbo.ParseNvarcharToInt(@tmpstr)

--				END
--			ELSE
--				SET @count=1;
--		END
--	ELSE
--		SET @count=1;

--	RETURN @count
--END

--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction GetClearPrice Script Date: 05.03.2024 00:22:45 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE FUNCTION GetClearPrice (@IsIncludeNDC bit, @Price Money, @NDC Money)
--RETURNS money
--AS
--BEGIN
--	declare @ClearPrice Money;
--	IF (@IsIncludeNDC=1)
--		BEGIN
--			SET @ClearPrice=@Price-@NDC;
--		END
--	ELSE
--		SET @ClearPrice=@Price;

--	RETURN @ClearPrice
--END

/*****************ЗАГОТОВОЧКА ДЛЯ ФУНКЦИИ*************************/
/*
SELECT T1.OrderNumber, T1.OrderDate, T2.MaterialID, T2.MaterialName, T1.Unit_of_Measure_in_Order,
	   T1.Quantity, T1.Price_per_Unit, T1.[Sum],T1.NDC, T3.ContractorID,T4.ContractorName FROM OrdersDetails T1
LEFT OUTER JOIN Materials T2 ON T1.MaterialID=T2.MaterialID
LEFT OUTER JOIN OrdersMain T3 ON T1.OrderNumber = T3.OrderNumber AND T1.OrderDate = T3.OrderDate
LEFT OUTER JOIN Contractors T4 ON T3.ContractorID= T4.ContractorID
--WHERE T2.MaterialID=1
ORDER BY T1.OrderNumber, T1.OrderDate;

WITH Tmp AS
(
SELECT T1.OrderNumber, T1.OrderDate, T2.MaterialID, T2.MaterialName, T1.Unit_of_Measure_in_Order,
	   T1.Quantity,dbo.GetCountFromPackage(T1.Unit_of_Measure_in_Order) AS RealQuantity,
	   T1.Quantity*dbo.GetCountFromPackage(T1.Unit_of_Measure_in_Order) AS TotalQuantity_In_Order
	   , T1.Price_per_Unit, T1.[Sum],T1.NDC,T3.IsIncludeNDC/*, T3.ContractorID,T4.ContractorName*/
	   ,dbo.GetClearPrice(T3.IsIncludeNDC,T1.[Sum],T1.NDC) AS ClearPrice
	   ,ROUND(dbo.GetClearPrice(T3.IsIncludeNDC,T1.[Sum],T1.NDC)/(T1.Quantity*dbo.GetCountFromPackage(T1.Unit_of_Measure_in_Order)),2) AS ClearPrice_Per_Unit
	   ,CONCAT (T1.OrderNumber,' : ',T1.OrderDate) AS OrderNumDate
FROM OrdersDetails T1
LEFT OUTER JOIN Materials T2 ON T1.MaterialID=T2.MaterialID
LEFT OUTER JOIN OrdersMain T3 ON T1.OrderNumber = T3.OrderNumber AND T1.OrderDate = T3.OrderDate
LEFT OUTER JOIN Contractors T4 ON T3.ContractorID= T4.ContractorID
WHERE T2.MaterialID=1
)

SELECT*
FROM Tmp
UNION
SELECT	NULL																						--1) Order
		,NULL																						--2) OrderDate
		,NULL																						--3) MaterialID
		,'Итого'																					--4) MaterialName
		,NULL																						--5) Unit_of_Measure_in_Order
		,(SELECT SUM(Quantity)FROM Tmp)																--6) Quantity
		,NULL																						--7) RealQuantity
		,(SELECT SUM(TotalQuantity_In_Order)FROM Tmp)												--8) TotalQuantity_In_Order
		,(SELECT SUM([SUM])FROM Tmp)/(SELECT SUM(Quantity)FROM Tmp)									--9) Price_per_Unit
		,(SELECT SUM([SUM])FROM Tmp)																--10) SUM
		,(SELECT SUM(NDC)FROM Tmp)																	--11) NDC
		,NULL																						--12) IsIncludeNDC
		,(SELECT SUM(ClearPrice)FROM Tmp)															--13) ClearPrice_Per
		,ROUND((SELECT SUM(ClearPrice)FROM Tmp)/(SELECT SUM(TotalQuantity_In_Order)FROM Tmp),2)		--14) ClearPrice_Per_Unit
		,(SELECT STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(OrderNumDate,'N/A')), ' / ')FROM Tmp)
ORDER BY Tmp.OrderNumber, Tmp.OrderDate
*/

--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction GetClearPrice Script Date: 05.03.2024 00:22:45 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE PROCEDURE GetMiddleClearPriceById
--				@ID INT,
--				@OrdersCount INT,
--				@BeginDate DATE,
--				@EndDate DATE,
--				@CleaarSinglePrice Money OUTPUT,
--				@OrdersNumDate nvarchar(210) OUTPUT

--AS
--BEGIN
--	WITH Tmp AS
--	(
--		SELECT TOP 10 T1.OrderNumber, T1.OrderDate, T2.MaterialID, T2.MaterialName, T1.Unit_of_Measure_in_Order,
--					T1.Quantity,dbo.GetCountFromPackage(T1.Unit_of_Measure_in_Order) AS RealQuantity,
--					T1.Quantity*dbo.GetCountFromPackage(T1.Unit_of_Measure_in_Order) AS TotalQuantity_In_Order
--					, T1.Price_per_Unit, T1.[Sum],T1.NDC,T3.IsIncludeNDC/*, T3.ContractorID,T4.ContractorName*/
--					,dbo.GetClearPrice(T3.IsIncludeNDC,T1.[Sum],T1.NDC) AS ClearPrice
--					,ROUND(dbo.GetClearPrice(T3.IsIncludeNDC,T1.[Sum],T1.NDC)/(T1.Quantity*dbo.GetCountFromPackage(T1.Unit_of_Measure_in_Order)),2) AS ClearPrice_Per_Unit
--					,CONCAT (T1.OrderNumber,' : ',T1.OrderDate) AS OrderNumDate
--					FROM OrdersDetails T1
--		LEFT OUTER JOIN Materials T2 ON T1.MaterialID=T2.MaterialID
--		LEFT OUTER JOIN OrdersMain T3 ON T1.OrderNumber = T3.OrderNumber AND T1.OrderDate = T3.OrderDate
--		LEFT OUTER JOIN Contractors T4 ON T3.ContractorID= T4.ContractorID
--		WHERE T2.MaterialID=@ID AND T1.OrderDate BETWEEN @BeginDate AND @EndDate
--		ORDER BY T1.OrderDate DESC
--	)


--	SELECT	@CleaarSinglePrice = ROUND((SELECT SUM(ClearPrice)FROM Tmp)/(SELECT SUM(TotalQuantity_In_Order)FROM Tmp),2)
--			,@OrdersNumDate = STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(OrderNumDate,'N/A')), ' / ') FROM Tmp;

--	IF (@CleaarSinglePrice IS NULL)
--		BEGIN
--			SET @CleaarSinglePrice=0
--			SET @OrdersNumDate='нет данных'
--		END

--END


--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction GetClearPrice Script Date: 07.03.2024 00:58:32 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE PROCEDURE LogIssueByMatId
--				@MaterailID INT,
--				@Quantity real,
--				@ConsigneeContractorID INT,
--				@Mes nvarchar(50) OUTPUT --нужна, что бы посмотреть, наличие материала с таким ID
--AS
--BEGIN
--	--Проверяется существование материала с таким ID, если не существует, то регистрация выдачи материала не производится
--	IF ((SELECT COUNT(*) FROM Materials WHERE MaterialID=@MaterailID)=1)
--		BEGIN
--			--Проверяется существование подрядчика с таким ID, если не существует, то в переменную @ConsigneeContractorID
--			-- присваивается значение NULL
--			IF ((SELECT COUNT(*) FROM Contractors WHERE ContractorID=@ConsigneeContractorID)=0)
--				BEGIN
--					SET @ConsigneeContractorID = NULL
--				END
			
--			declare @Price_per_Unit money
--			declare @OrderNumber INT
--			declare @OrderDate DATE

--			--Проверяется существуют-ли заказы с данным материалом, и подходящие по дате
--			IF ((SELECT COUNT(*) FROM OrdersDetails WHERE MaterialID=@MaterailID AND OrderDate<=GETDATE())=0)
--				BEGIN
					
--					--Блок переменных для определения чистой цены
--					declare @Sum_In_Order money
--					declare @NDC money
--					declare @IsIncludeNDC bit

--					--Блок переменных для определения стоимости еденицы
--					declare @UOM_In_Order nvarchar(25)
--					declare @Count_In_Order real
--					declare @TotalQunatity real

--					--Присваиваются значения переменным, из таблицы OrderDetails, из последнего по дате заказа
--					SELECT TOP 1 @Sum_In_Order=[Sum],@NDC=NDC, @IsIncludeNDC=NDC, @UOM_In_Order=Unit_of_Measure_in_Order
--								 ,@Count_In_Order=Quantity, @OrderNumber=OrderNumber,@OrderDate=OrderDate 
--					FROM OrdersDetails WHERE MaterialID=@MaterailID AND OrderDate<=GETDATE()
--					ORDER BY OrderDate DESC

--					--Определяется сумма товаров в заказе без НДС
--					declare @ClearPrice money
--					SET @ClearPrice = dbo.GetClearPrice(@IsIncludeNDC,@Sum_In_Order,@NDC)

--					--Определяется общее количество едениц товара в заказе, даже если в заказе указана упаковка
--					SET @TotalQunatity = @Count_In_Order * dbo.GetCountFromPackage(@UOM_In_Order)

--					--Определяется цена на еденицу товара
--					SET @Price_per_Unit = ROUND(@ClearPrice/@TotalQunatity,2)
--				END
--			ELSE
--				BEGIN
--				--Если заказов не существует, тогда цене за штуку, номеру заказа и дате присваивается значение NULL
--					SET @Price_per_Unit = NULL
--					SET @OrderNumber = NULL
--					SET @OrderDate = NULL
--				END

--			--Добавление данных в таблицу
--			INSERT INTO MaterialssueLog VALUES
--			(GETDATE()
--			,@MaterailID
--			,(SELECT Unit_of_Measure FROM Materials WHERE MaterialID=@MaterailID)	--присваивается значение ед-цы измрения, из таблицы с материалами
--			, @Quantity
--			, @Price_per_Unit
--			, ROUND(@Quantity*@Price_per_Unit,2)
--			,@ConsigneeContractorID
--			, @OrderNumber
--			, @OrderDate)

--			SET @Mes='Data has been inserted'
--		END
--	ELSE
--		BEGIN
--			SET @Mes='MaterialID has been not found'
--		END
--END

--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction GetClearPrice Script Date: 08.03.2024 05:21:35 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE PROCEDURE CreateCalcML
--				@CalcNumber nvarchar(10),
--				@CalcType nvarchar(10),
--				@BeginDate DATE,
--				@EndDate DATE,
--				@Mes nvarchar(50) OUTPUT --возвращает результат выполнения или код ошибки

--AS
--BEGIN
--	--Проверка, существует-ли калькуляция с таким же номером и типом
--	IF ((SELECT COUNT(*) FROM CalculationMaterialList WHERE CalcNumber=@CalcNumber AND CalcType=@CalcType)=0)
--		BEGIN
--			--Если не существует, тогда добавляются данные
--			--Сумма стоимости материалов не добавляется, т.к. будет обновляться в процессе добавления материалов
--			INSERT INTO CalculationMaterialList (CalcNumber,CalcType,BeginDate,EndDate) VALUES
--			(@CalcNumber,@CalcType,@BeginDate,@EndDate)
--			SET @Mes='Calc has been created successfully'	
--		END
--	ELSE
--		BEGIN
--		--Если существует, тогда данные не добавляются
--			SET @Mes='Calc with this number and type already exists'
--		END
--END

--CREATE VIEW ShowCalcML AS

--SELECT    T1.CalcNumber AS Number, T1.CalcType AS Type, T1.MaterialID AS ID, T2.MaterialName
--		, T2.Qty_UoM_in_UoMiO AS Count_Basic_Unit_of_Measure_In_Package, T2.Unit_of_Measure_in_CML AS Basic_Unit_of_Measure
--		, T1.Quantity AS Count_In_Basic_UoM, ROUND(T1.Quantity/T2.Qty_UoM_in_UoMiO,2) AS Count_In_UoM,T2.Unit_of_Measure AS Unit_of_Measure
--		, T1.Price_per_Unit_Of_Measure, ROUND((ROUND(T1.Quantity/T2.Qty_UoM_in_UoMiO,2))*T1.Price_per_Unit_Of_Measure,2) AS [SUM]
--		, T2.Weight_in_Tonns AS Single_weight_in_tonns,ROUND((ROUND(T1.Quantity/T2.Qty_UoM_in_UoMiO,5))*T2.Weight_in_Tonns,5) AS Summary_weight_in_Tonns
--		, T1.OrdersData AS OrdersInfo
--FROM CalculationMaterialListDetails T1
--LEFT OUTER JOIN Materials T2 ON T1.MaterialID=T2.MaterialID

--USE BRAcc;

--GO
--/****** Object:  UserDefinedFunction GetClearPrice Script Date: 08.03.2024 05:21:35 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--CREATE PROCEDURE AddMatToCalcMLbyID
--				@CalcNumber nvarchar(10),
--				@CalcType nvarchar(10),
--				@MaterialID INT,
--				@Quantity real,
--				@Mes nvarchar(50) OUTPUT --возвращает результат выполнения или код ошибки

--AS
--BEGIN
--	--Проверка, существует-ли калькуляция с таким же номером и типом
--	IF ((SELECT COUNT(*) FROM CalculationMaterialList WHERE CalcNumber=@CalcNumber AND CalcType=@CalcType)<>0)
--		BEGIN
--				--Проверка, существует-ли материал с таким ID
--			IF ((SELECT COUNT(*) FROM Materials WHERE MaterialID=@MaterialID)<>0)
--				BEGIN

--					--создаётся блок переменных, данные которых будут добавлены в таблицу
--					declare @BeginDate DATE
--					declare @EndDate DATE
--					declare @UOM_in_CML nvarchar(25)
--					declare @Price_per_Unit money
--					declare @OrdersData nvarchar(210)

--					--Присваиваются начальные и конечные даты выполнения работ
--					SELECT @BeginDate=BeginDate, @EndDate=EndDate FROM CalculationMaterialList WHERE CalcNumber=@CalcNumber AND CalcType=@CalcType

--					--Присваиваются ед-цы измерения в калькуляциях
--					SELECT @UOM_in_CML = Unit_of_Measure_in_CML FROM Materials WHERE MaterialID=@MaterialID

--					--Проверка, существуют-ли заказы с данным материалом
--					IF ((SELECT COUNT(*) FROM OrdersDetails WHERE MaterialID=@MaterialID)<>0)
--						BEGIN
--							--Если заказы существуют, то определяется цена для материала
--							IF (@BeginDate=@EndDate OR (SELECT COUNT(*) FROM OrdersDetails WHERE MaterialID=@MaterialID AND OrderDate BETWEEN @BeginDate AND @EndDate)<=1)
--								BEGIN
--									-- Если даты равны; или за рассматриваемый период есть только 1 заказ или заказов нет вообще (за рассматриваемый период) 
--									SELECT TOP 1
--									@OrdersData = CONCAT (T1.OrderNumber,' : ',T1.OrderDate)
--									,@Price_per_Unit=(dbo.GetClearPrice(T1.[Sum],T1.NDC,T2.IsIncludeNDC)/(T1.Quantity*dbo.GetCountFromPackage(T1.Unit_of_Measure_in_Order)))
--									FROM OrdersDetails T1
--									LEFT OUTER JOIN OrdersMain T2 ON T1.OrderNumber = T2.OrderNumber AND T1.OrderDate = T2.OrderDate
--									WHERE MaterialID=@MaterialID AND T1.OrderDate<=@EndDate
--									ORDER BY T1.OrderDate DESC

--								END
--							ELSE
--								BEGIN
--									-- Если даты не равны, данные будут браться из заказов за данный период
--									EXECUTE dbo.GetMiddleClearPriceById @MaterialID, @BeginDate, @EndDate,@Price_per_Unit OUTPUT, @OrdersData OUTPUT 

--								END
--						END
--					ELSE
--					--Если заказов с материалом не существует
--						BEGIN
--							SET @Price_per_Unit=0
--							SET @OrdersData='Orders with this material has been not found'
--							SET @Mes='Orders with this material has been not found'	
--						END

--						INSERT INTO CalculationMaterialListDetails VALUES
--						(@CalcNumber, @CalcType,@MaterialID, @UOM_in_CML, @Quantity, @Price_per_Unit, @OrdersData)
--				END
--			ELSE
--				BEGIN
--					SET @Mes='Material with this ID does not exists'
--				END
--		END
--	ELSE
--		BEGIN
--		--Если не существует, тогда данные не добавляются
--			SET @Mes='Calc with this number or type does not exists'	
--		END
--END


--CREATE VIEW ShowMIL AS

--SELECT    T1.LogNumber AS Number, T1.LogDate,T1.LogTime
--		, T2.MaterialName, T1.Unit_of_Measure AS UOM, T1.Quantity, T1.Price_per_Unit, T1.[Sum]
--		, T3.ContractorName AS ContractorName, T1.OrderNumber, T1.OrderDate
--FROM MaterialssueLog T1
--LEFT OUTER JOIN Materials T2 ON T1.MaterialID=T2.MaterialID
--LEFT OUTER JOIN Contractors T3 ON T1.ConsigneeContractorID=T3.ContractorID

--CREATE VIEW ShowMILForApp AS

--SELECT    T1.LogNumber AS Number, T1.LogDate,T1.LogTime
--		, T2.MaterialName, T1.Unit_of_Measure AS UOM, T1.Quantity
--		, T3.ContractorName AS ContractorName
--FROM MaterialssueLog T1
--LEFT OUTER JOIN Materials T2 ON T1.MaterialID=T2.MaterialID
--LEFT OUTER JOIN Contractors T3 ON T1.ConsigneeContractorID=T3.ContractorID

DROP VIEW ShowOrdersForApp;

USE BRAcc;
--CREATE VIEW ShowOrdersForApp AS
--SELECT ROW_NUMBER() OVER (ORDER BY T1.OrderNumber) AS PosNumber,T1.OrderNumber AS Number, FORMAT(T1.OrderDate,'dd/MM/yyyy') AS Date, T2.ContractorName, FORMAT(T1.TotalPrice,'N', 'de-de') AS TotalPrice FROM OrdersMain T1
--LEFT OUTER JOIN Contractors T2 ON T1.ContractorID=T2.ContractorID;

CREATE VIEW ShowOrdersDetailsForApp AS
SELECT ROW_NUMBER() OVER (PARTITION BY OrderNumber ORDER BY OrderNumber) AS PosNumber,T2.MaterialName, T1.Unit_of_Measure_in_Order, T1.Quantity, T1.Price_per_Unit, T1.[Sum], T1.NDC FROM OrdersDetails T1
LEFT OUTER JOIN Materials T2 ON T1.MaterialID=T2.MaterialID