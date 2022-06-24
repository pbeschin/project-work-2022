/****** Object:  View [dbo].[Transazioni_Media]    Script Date: 24/06/2022 09:32:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Transazioni_Media]
AS
SELECT AVG(tot_transazioni_giornaliere) AS media_transazioni
FROM Transazioni_Giornaliere_Affluenza
GO

