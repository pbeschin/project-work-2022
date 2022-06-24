/****** Object:  StoredProcedure [dbo].[CalcolaImporto]    Script Date: 24/06/2022 09:26:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalcolaImporto] (@data_uscita DATETIME, @ID_rfid VARCHAR(50))
AS
BEGIN

IF ((SELECT costo_forzato FROM Ttariffe WHERE giorno = CONVERT(DATE,GETDATE())) IS NOT NULL)
	BEGIN
		UPDATE TPagamenti
		SET importo =
		ROUND((SELECT costo_forzato FROM Ttariffe WHERE giorno = CONVERT(DATE,GETDATE())) *
		(SELECT DATEDIFF(MINUTE,data_entrata,@data_uscita)*1.00/60 FROM TPagamenti WHERE importo IS NULL AND ID_rfid = @ID_rfid), 1)
		WHERE importo IS NULL AND ID_rfid = @ID_rfid
	END
ELSE
	BEGIN
		UPDATE TPagamenti
		SET importo =
		ROUND((SELECT costo_orario FROM Ttariffe WHERE giorno = CONVERT(DATE,GETDATE())) *
		(SELECT DATEDIFF(MINUTE,data_entrata,@data_uscita)*1.00/60 FROM TPagamenti WHERE importo IS NULL AND ID_rfid = @ID_rfid), 1)
		WHERE importo IS NULL AND ID_rfid = @ID_rfid
	END
END

--EXEC CalcolaImporto @data_uscita = '2022-01-05 00:00:00.000', @ID_rfid = 'testFinalissimo'


