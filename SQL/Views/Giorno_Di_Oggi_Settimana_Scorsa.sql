/****** Object:  View [dbo].[Giorno_Di_Oggi_Settimana_Scorsa]    Script Date: 24/06/2022 09:31:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Giorno_Di_Oggi_Settimana_Scorsa]
AS
SELECT giorno AS giorno_di_oggi_settimana_scorsa
FROM     dbo.Tempo_Giornaliero_Affluenza
WHERE  (DATEDIFF(DAYOFYEAR, giorno, CONVERT(DATE, GETDATE())) = 7)
GO

