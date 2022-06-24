/****** Object:  View [dbo].[Transazioni_Settimana_Scorsa]    Script Date: 24/06/2022 09:32:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*SELECT * FROM Transazioni_Questa_Settimana
SELECT * FROM Transazioni_Scorsa_Settimana*/
CREATE VIEW [dbo].[Transazioni_Settimana_Scorsa]
AS
SELECT DATEPART(WEEKDAY, CONVERT(DATE, data_uscita)) AS giorno, COUNT(pagato) AS n_transazioni
FROM     dbo.TPagamenti
WHERE  (DATEPART(WEEK, data_entrata) = DATEPART(WEEK, GETDATE()) - 1) AND (data_uscita IS NOT NULL)
GROUP BY CONVERT(DATE, data_uscita)
GO

