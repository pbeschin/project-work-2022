/****** Object:  StoredProcedure [dbo].[CalcolaCostoOrarioRotazione]    Script Date: 29/06/2022 11:37:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalcolaCostoOrarioRotazione]
AS
BEGIN
DECLARE @transazioni_media AS INT
DECLARE @transazioni_giorno_settimana_scorsa AS INT
DECLARE @costo_orario_rotazione_oggi AS DECIMAL (5,2)
DECLARE @costo_orario_rotazione_scorso AS DECIMAL (5,2)
DECLARE @costo_minimo AS DECIMAL(5,2) 

SET @transazioni_media = (SELECT media_transazioni FROM Transazioni_Media)
SET @transazioni_giorno_settimana_scorsa = (SELECT  transazioni_giorno_settimana_scorsa FROM Transazioni_Giorno_Settimana_Scorsa)
SET @costo_orario_rotazione_oggi = 0
SET @costo_orario_rotazione_scorso = (SELECT costo_orario_rotazione_settimana_scorsa FROM Costo_Orario_Rotazione_Settimana_Scorsa)
SET @costo_minimo = 0.50

PRINT('Transazioni medie: ' + CONVERT(VARCHAR, @transazioni_media))
PRINT('Transazioni settimana scorsa: ' + CONVERT(VARCHAR,@transazioni_giorno_settimana_scorsa))
PRINT('-------------------------------------------------------------------------------------------')
------------------------------------------------------------------------------------------------------------------------------------------

--se le transazioni della scorsa settimana sono state minori rispetto alla media

IF (@transazioni_giorno_settimana_scorsa < @transazioni_media)
BEGIN
	PRINT('Transazioni settimana scorsa minore della media')
	DECLARE @differenza AS INT
	SET @differenza = (100*(@transazioni_media - @transazioni_giorno_settimana_scorsa)/(@transazioni_media))
	PRINT('Differenza: -' + CONVERT(VARCHAR, @differenza) + '%')
	--se la differenza tra le transazioni della settimana scorsa e le transazioni medie è fino al -25% 
	IF (@differenza <= 25)
		BEGIN
			PRINT('Differenza tra transazioni settimana scorsa e transazioni medie è fino al -25% ')
			SET @costo_orario_rotazione_oggi = @costo_orario_rotazione_scorso - (@costo_orario_rotazione_scorso*0.25)
			PRINT('Costo orario rotazioni oggi:  ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))
		END
	--se la differenza tra le transazioni della settimana scorsa e le transazioni medie è fino al -50% 
	ELSE IF (@differenza <= 50)
		BEGIN
			PRINT('Differenza tra transazioni settimana scorsa e transazioni medie è fino al -50% ')
			SET @costo_orario_rotazione_oggi = @costo_orario_rotazione_scorso - (@costo_orario_rotazione_scorso*0.50)
			PRINT('Costo orario rotazioni oggi:  ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))
		END
	--se la differenza tra le transazioni della settimana scorsa e le transazioni medie è fino al -75% 
	ELSE IF (@differenza <= 75)
		BEGIN
			PRINT('Differenza tra transazioni settimana scorsa e transazioni medie è fino al -75% ')
			SET @costo_orario_rotazione_oggi = @costo_orario_rotazione_scorso - (@costo_orario_rotazione_scorso*0.75)
			PRINT('Costo orario rotazioni oggi:  ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))
		END
	--se il costo orario raggiunge il minimo
	 IF(@costo_orario_rotazione_oggi < @costo_minimo)	
		BEGIN
			PRINT('Costo orario raggiunto il minimo')
			SET @costo_orario_rotazione_oggi = @costo_minimo
			PRINT('Costo orario oggi: ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))
		END

	--inserimento costo orario nella data di oggi
	UPDATE Ttariffe SET costo_orario_rotazione = @costo_orario_rotazione_oggi WHERE giorno = CONVERT(DATE, GETDATE())
END
------------------------------------------------------------------------------------------------------------------------------------------

--se le transazioni della scorsa settimana sono state maggiori rispetto alla media

ELSE IF (@transazioni_giorno_settimana_scorsa > @transazioni_media)
BEGIN
	PRINT('Transazioni settimana scorsa maggiore della media')
	DECLARE @differenza1 AS INT
	SET @differenza = (100*(@transazioni_giorno_settimana_scorsa - @transazioni_media)/(@transazioni_giorno_settimana_scorsa))
	PRINT('Differenza: -' + CONVERT(VARCHAR, @differenza1) + '%')
	--se la differenza tra le transazioni della settimana scorsa e le transazioni medie è fino al +25% 
	IF (@differenza1 <= 25)
		BEGIN
			PRINT('Differenza tra transazioni settimana scorsa e transazioni medie è fino al +25% ')
			SET @costo_orario_rotazione_oggi = @costo_orario_rotazione_scorso + (@costo_orario_rotazione_scorso*0.25)
			PRINT('Costo orario rotazioni oggi:  ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))
		END
	--se la differenza tra le transazioni della settimana scorsa e le transazioni medie è fino al +50% 
	ELSE IF (@differenza <= 50)
		BEGIN
			PRINT('Differenza tra transazioni settimana scorsa e transazioni medie è fino al +50% ')
			SET @costo_orario_rotazione_oggi = @costo_orario_rotazione_scorso + (@costo_orario_rotazione_scorso*0.50)
			PRINT('Costo orario rotazioni oggi:  ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))
		END
	--se la differenza tra le transazioni della settimana scorsa e le transazioni medie è fino al +75% 
	ELSE IF (@differenza <= 75)
		BEGIN
			PRINT('Differenza tra transazioni settimana scorsa e transazioni medie è fino al +75% ')
			SET @costo_orario_rotazione_oggi = @costo_orario_rotazione_scorso + (@costo_orario_rotazione_scorso*0.75)
			PRINT('Costo orario rotazioni oggi:  ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))
		END

	--inserimento costo orario nella data di oggi
	UPDATE Ttariffe SET costo_orario_rotazione = @costo_orario_rotazione_oggi WHERE giorno = CONVERT(DATE, GETDATE())
END

------------------------------------------------------------------------------------------------------------------------------------------

--se le transazioni della scorsa settimana sono state uguali rispetto alla media

ELSE IF (@transazioni_giorno_settimana_scorsa = @transazioni_media)
BEGIN
	PRINT('Transazioni settimana scorsa uguali alla media')
	SET @costo_orario_rotazione_oggi = @costo_orario_rotazione_scorso
	PRINT('Costo orario rotazioni oggi:  ' + CONVERT(VARCHAR,@costo_orario_rotazione_oggi))

    --inserimento costo orario nella data di oggi
	UPDATE Ttariffe SET costo_orario_rotazione = @costo_orario_rotazione_oggi WHERE giorno = CONVERT(DATE, GETDATE())
END

END