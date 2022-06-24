/****** Object:  View [dbo].[Transazioni_Giorno_Settimana_Scorsa]    Script Date: 24/06/2022 09:32:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Transazioni_Giorno_Settimana_Scorsa]
AS
SELECT tot_transazioni_giornaliere AS transazioni_giorno_settimana_scorsa
FROM     Transazioni_Giornaliere_Affluenza
WHERE  (giorno =
                      (SELECT giorno_di_oggi_settimana_scorsa
                       FROM      dbo.Giorno_Di_Oggi_Settimana_Scorsa))
GO

