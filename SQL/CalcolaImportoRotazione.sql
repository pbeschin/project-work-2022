/****** Object:  StoredProcedure [dbo].[CalcolaImportoRotazione]    Script Date: 24/06/2022 09:27:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalcolaImportoRotazione] (@data_uscita DATETIME, @ID_rfid VARCHAR(50))
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
		ROUND((SELECT costo_orario_rotazione FROM Ttariffe WHERE giorno = CONVERT(DATE,GETDATE())) *
		(SELECT DATEDIFF(MINUTE,data_entrata,@data_uscita)*1.00/60 FROM TPagamenti WHERE importo IS NULL AND ID_rfid = @ID_rfid), 1)
		WHERE importo IS NULL AND ID_rfid = @ID_rfid
	END
END