/****** Object:  StoredProcedure [dbo].[CalcolaCostoOrario]    Script Date: 29/06/2022 11:37:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalcolaCostoOrario]
AS
BEGIN



DECLARE @affluenza_media AS DECIMAL(6,2)
DECLARE @affluenza_giorno_settimana_scorsa AS DECIMAL(6,2)
DECLARE @costo_orario_oggi AS DECIMAL(5,2)
DECLARE @costo_orario_scorso AS DECIMAL(5,2)
DECLARE @costo_minimo AS DECIMAL(5,2) 

SET @affluenza_media = (SELECT DATEDIFF(MINUTE,0,(select * from Tempo_Medio_Affluenza)) AS Conversione_In_Minuti)
SET @affluenza_giorno_settimana_scorsa = (SELECT DATEDIFF(MINUTE,0,(select * from Affluenza_Giorno_Settimana_Scorsa)) AS Conversione_In_Minuti)
SET @costo_orario_oggi = 0
SET @costo_orario_scorso = (select costo_orario_settimana_scorsa from Costo_Orario_Settimana_Scorsa)
SET @costo_minimo = 0.50

PRINT('Affluenza media: ' + CONVERT(VARCHAR,@affluenza_media) + ' minuti')
PRINT('Affluenza settimana scorsa: ' + CONVERT(VARCHAR,@affluenza_giorno_settimana_scorsa) + ' minuti')
PRINT('-------------------------------------------------------------------------------------------')
------------------------------------------------------------------------------------------------------------------------------------------

--se l'affluenza della scorsa settimana è stata minore rispetto alla media

IF (@affluenza_giorno_settimana_scorsa < @affluenza_media)
BEGIN
	PRINT('Affluenza della scorsa settimana minore rispetto alla media')
	DECLARE @differenza AS DECIMAL(5,2)
	SET @differenza = (100*CONVERT(INT,(@affluenza_media - @affluenza_giorno_settimana_scorsa))/CONVERT(INT,@affluenza_media))
	PRINT('Differenza: -' + CONVERT(VARCHAR,@differenza) + '%')	
	--se la differenza tra l'affluenza della settimana scorsa e l'affluenza media è fino al -25%
	IF(@differenza <= 25)	
		BEGIN
			PRINT('Differenza tra affluenza della settimana scorsa e affluenza media è fino al -25%')
			SET @costo_orario_oggi = @costo_orario_scorso - (@costo_orario_scorso*0.25)
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_oggi))
		END
	--se la differenza tra l'affluenza della settimana scorsa e l'affluenza media è fino al -50%
	ELSE IF(@differenza <= 50)		
		BEGIN
			PRINT('Differenza tra affluenza della settimana scorsa e affluenza media è fino al -50%')
			SET @costo_orario_oggi = @costo_orario_scorso - (@costo_orario_scorso*0.50)
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_oggi))
		END
	--se la differenza tra l'affluenza della settimana scorsa e l'affluenza media è fino al -75%
	ELSE IF(@differenza <= 75)
		BEGIN
			PRINT('Differenza tra affluenza della settimana scorsa e affluenza media è fino al -75%')
			SET @costo_orario_oggi = @costo_orario_scorso - (@costo_orario_scorso*0.75)
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_oggi))
		END
	--se il costo orario raggiunge il minimo
	 IF(@costo_orario_oggi < @costo_minimo)	
		BEGIN
			PRINT('Costo orario raggiunto il minimo')
			SET @costo_orario_oggi = @costo_minimo
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_oggi))
		END
	
	--inserimento costo orario nella data di oggi
	INSERT INTO Ttariffe (giorno, costo_orario) VALUES(CONVERT(DATE, GETDATE()),@costo_orario_oggi)

END
------------------------------------------------------------------------------------------------------------------------------------------

--se l'affluenza della scorsa settimana è stata maggiore rispetto alla media

ELSE IF (@affluenza_giorno_settimana_scorsa > @affluenza_media)
BEGIN
	PRINT('Affluenza della scorsa settimana maggiore rispetto alla media')
	DECLARE @differenza1 AS DECIMAL(5,2)
	SET @differenza1 = (100*CONVERT(INT,(@affluenza_giorno_settimana_scorsa - @affluenza_media))/CONVERT(INT,@affluenza_giorno_settimana_scorsa))
	PRINT('Differenza1:  ' + CONVERT(VARCHAR,@differenza1) + '%')	
	--se la differenza tra l'affluenza della settimana scorsa e l'affluenza media è fino al +25%
	IF(@differenza1 <= 25)	
		BEGIN
			PRINT('Differenza1 tra affluenza della settimana scorsa e affluenza media è fino al +25%')
			SET @costo_orario_oggi = @costo_orario_scorso + (@costo_orario_scorso*0.25)
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_oggi))
		END
	--se la differenza tra l'affluenza della settimana scorsa e l'affluenza media è fino al +50%
	ELSE IF(@differenza1 <= 50)	
		BEGIN
			PRINT('Differenza1 tra affluenza della settimana scorsa e affluenza media è fino al +50%')
			SET @costo_orario_oggi = @costo_orario_scorso + (@costo_orario_scorso*0.50)
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_oggi))
		END
	--se la differenza tra l'affluenza della settimana scorsa e l'affluenza media è fino al +75%
	ELSE IF(@differenza1 <= 75)	
		BEGIN
			PRINT('Differenza1 tra affluenza della settimana scorsa e affluenza media è fino al +75%')
			SET @costo_orario_oggi = @costo_orario_scorso + (@costo_orario_scorso*0.75)
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_oggi))
		END
    
	--inserimento costo orario nella data di oggi
	UPDATE Ttariffe SET costo_orario = @costo_orario_oggi WHERE giorno = CONVERT(DATE, GETDATE())
END

------------------------------------------------------------------------------------------------------------------------------------------

--se l'affluenza della scorsa settimana è stata uguale rispetto alla media

ELSE IF (@affluenza_giorno_settimana_scorsa = @affluenza_media)
BEGIN
	PRINT('Transazioni settimana scorsa uguali alla media')
	SET @costo_orario_oggi = @costo_orario_scorso
	PRINT('Costo orario oggi:  ' + CONVERT(VARCHAR,@costo_orario_oggi))

    --inserimento costo orario nella data di oggi
	UPDATE Ttariffe SET costo_orario = @costo_orario_oggi WHERE giorno = CONVERT(DATE, GETDATE())
END


END