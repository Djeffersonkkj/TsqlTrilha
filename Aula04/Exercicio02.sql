USE woodcraftDjota;
GO

-- Exercício 2: Trigger de Auditoria de Prazo de Entrega --------------------------------------------------------------

-- Criando nova tabela LogAuditoriaPrazoPedido

CREATE TABLE LogAuditoriaPrazoPedido(
	Id					INT				IDENTITY(1 ,1),
	IdPedido			INT				NOT NULL,
	DataPromessaAntiga	DATE			NOT NULL,
	DataPromessaNova	DATE			NOT NULL,
	DataAlteracao		DATETIME		NOT NULL DEFAULT GETDATE(),
	Usuario				VARCHAR(100)	NOT NULL DEFAULT SYSTEM_USER
);
GO

-- Criando a trigger
CREATE OR ALTER	TRIGGER trg_AuditarPrazoPedido
	ON [dbo].[Pedido]
	AFTER UPDATE
	AS
	/*
		Documentacao
		Arquivo Fonte............:	Exercicio02.sql
		Objetivo.................:	Auditar alteracoes nos prazos dos pedidos
		Autor....................:	Djefferson dos Santos Lima
		Data.....................:	14/07/2026
		Exemplo..................:	
									BEGIN TRAN
										UPDATE [dbo].[Pedido]
											SET DataPromessa = GETDATE()
											WHERE IdCliente = 3 OR IdCliente = 2

										SELECT *
											FROM [dbo].[LogAuditoriaPrazoPedido]
									ROLLBACK TRAN

	*/
	BEGIN
		INSERT INTO [dbo].[LogAuditoriaPrazoPedido] (IdPedido, DataPromessaAntiga, DataPromessaNova)
			SELECT	i.Id,
					d.DataPromessa,
					i.DataPromessa
				FROM inserted as i
					JOIN deleted as d
						on i.Id = d.Id
				WHERE d.DataPromessa <> i.DataPromessa;
	END
	GO
