/****** Object:  View [dbo].[Costo_Orario_Settimana_Scorsa]    Script Date: 24/06/2022 09:30:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Costo_Orario_Settimana_Scorsa]
AS
SELECT giorno, costo_orario AS costo_orario_settimana_scorsa
FROM Ttariffe
WHERE (DATEDIFF(DAYOFYEAR, giorno, CONVERT(DATE, GETDATE())) = 7)
GO

