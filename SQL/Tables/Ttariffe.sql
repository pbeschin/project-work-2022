/****** Object:  Table [dbo].[Ttariffe]    Script Date: 24/06/2022 09:34:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Ttariffe](
	[giorno] [date] NULL,
	[costo_orario] [decimal](5, 2) NULL,
	[costo_orario_rotazione] [decimal](5, 2) NULL,
	[costo_forzato] [decimal](5, 2) NULL
) ON [PRIMARY]
GO

