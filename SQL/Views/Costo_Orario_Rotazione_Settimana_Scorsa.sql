/****** Object:  View [dbo].[Costo_Orario_Rotazione_Settimana_Scorsa]    Script Date: 24/06/2022 09:30:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Costo_Orario_Rotazione_Settimana_Scorsa]
AS
SELECT giorno, costo_orario_rotazione AS costo_orario_rotazione_settimana_scorsa
FROM     dbo.Ttariffe
WHERE  (DATEDIFF(DAYOFYEAR, giorno, CONVERT(DATE, GETDATE())) = 7)
GO

