/****** Object:  View [dbo].[Transazioni_Giornaliere_Affluenza]    Script Date: 24/06/2022 09:31:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Transazioni_Giornaliere_Affluenza]
AS
SELECT CONVERT(DATE, data_entrata) AS giorno, COUNT(pagato) AS tot_transazioni_giornaliere
FROM TPagamenti
GROUP BY CONVERT(DATE, data_entrata)
GO

