/****** Object:  View [dbo].[Affluenza_Giorno_Settimana_Scorsa]    Script Date: 24/06/2022 09:30:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Affluenza_Giorno_Settimana_Scorsa]
AS
SELECT somma_ore_permanenza AS affluenza_giorno_settimana_scorsa
FROM     dbo.Tempo_Giornaliero_Affluenza
WHERE  (giorno =
                      (SELECT giorno_di_oggi_settimana_scorsa
                       FROM      dbo.Giorno_Di_Oggi_Settimana_Scorsa))
GO

