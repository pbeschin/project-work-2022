/****** Object:  StoredProcedure [dbo].[CalcolaCostiOrari_Affluenza_Transazioni]    Script Date: 24/06/2022 09:24:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalcolaCostiOrari_Affluenza_Transazioni]
AS
BEGIN
EXEC CalcolaCostoOrario --> calcola il costo orario ordinario
EXEC CalcolaCostoOrarioRotazione --> calcoa il costo orario a rotazione
UPDATE TConfig SET mod_tariffa = 0 --> imposto a 'costo ordinario' il campo mod_tariffa della tabella TConfig: in questo modo siamo sicuri che, se il giorno prima la tariffa è stata impostata a forzato, il giorno dopo essendo il campo ancora settato a forzato e nella tabella Ttariffe non ancora popolato il record del costo_forzato, il calcolo dell'importo non vada in errore
END