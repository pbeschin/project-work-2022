/****** Object:  View [dbo].[Tempo_Medio_Affluenza]    Script Date: 24/06/2022 09:31:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Tempo_Medio_Affluenza]
AS
SELECT CONVERT(time(0), DATEADD(SECOND,
                      (SELECT AVG(DATEDIFF(SECOND, data_entrata, data_uscita)) AS secondi_medi_permanenza
                       FROM      dbo.TPagamenti), 0)) AS tempo_medio_affluenza
GO

