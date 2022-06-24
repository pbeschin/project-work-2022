/****** Object:  Table [dbo].[TPagamenti]    Script Date: 24/06/2022 09:33:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TPagamenti](
	[ID_storico] [int] IDENTITY(1,1) NOT NULL,
	[ID_rfid] [varchar](50) NULL,
	[data_entrata] [datetime] NULL,
	[data_uscita] [datetime] NULL,
	[importo] [decimal](5, 2) NULL,
	[pagato] [bit] NOT NULL,
 CONSTRAINT [PK_TPagamenti] PRIMARY KEY CLUSTERED 
(
	[ID_storico] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TPagamenti] ADD  CONSTRAINT [DF_TPagamenti_pagato]  DEFAULT ((0)) FOR [pagato]
GO

