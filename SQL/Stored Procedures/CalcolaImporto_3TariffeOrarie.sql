/****** Object:  StoredProcedure [dbo].[CalcolaImporto_3TariffeOrarie]    Script Date: 24/06/2022 09:26:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalcolaImporto_3TariffeOrarie] (@data_uscita DATETIME, @ID_rfid VARCHAR(50))
AS
BEGIN

DECLARE @tariffa AS INT
SET @tariffa = (SELECT mod_tariffa FROM TConfig)

IF (@tariffa = 0) --> costo orario
BEGIN
		UPDATE TPagamenti
		SET importo =
		ROUND((SELECT costo_orario FROM Ttariffe WHERE giorno = CONVERT(DATE,GETDATE())) *
		(SELECT DATEDIFF(MINUTE,data_entrata,@data_uscita)*1.00/60 FROM TPagamenti WHERE importo IS NULL AND ID_rfid = @ID_rfid), 1)
		WHERE importo IS NULL AND ID_rfid = @ID_rfid
END

ELSE IF (@tariffa = 1) --> costo orario rotazione
BEGIN
		UPDATE TPagamenti
		SET importo =
		ROUND((SELECT costo_orario_rotazione FROM Ttariffe WHERE giorno = CONVERT(DATE,GETDATE())) *
		(SELECT DATEDIFF(MINUTE,data_entrata,@data_uscita)*1.00/60 FROM TPagamenti WHERE importo IS NULL AND ID_rfid = @ID_rfid), 1)
		WHERE importo IS NULL AND ID_rfid = @ID_rfid
END

ELSE IF (@tariffa = 2) --> costo orario forzato
BEGIN
		UPDATE TPagamenti
		SET importo =
		ROUND((SELECT costo_forzato FROM Ttariffe WHERE giorno = CONVERT(DATE,GETDATE())) *
		(SELECT DATEDIFF(MINUTE,data_entrata,@data_uscita)*1.00/60 FROM TPagamenti WHERE importo IS NULL AND ID_rfid = @ID_rfid), 1)
		WHERE importo IS NULL AND ID_rfid = @ID_rfid
END

END








