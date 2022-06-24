/****** Object:  View [dbo].[Tempo_Giornaliero_Affluenza]    Script Date: 24/06/2022 09:31:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[Tempo_Giornaliero_Affluenza]
as
SELECT CONVERT(DATE, data_entrata) AS giorno, 


CONVERT(time(0), DATEADD(SECOND,
						(
						SELECT SUM(DATEDIFF(SECOND, data_entrata, data_uscita)) AS somma_secondi_permanenza 
						 FROM TPagamenti T2
						 where CONVERT(DATE, T1.data_entrata) = CONVERT(DATE, T2.data_entrata) 
						 GROUP BY CONVERT(DATE, data_entrata)
						 )
						 , 0)) AS somma_ore_permanenza
FROM TPagamenti T1
GROUP BY CONVERT(DATE, data_entrata)
GO

