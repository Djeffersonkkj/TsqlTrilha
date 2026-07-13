USE woodcraftDjota;
GO

-- Exercício 2: Função Escalar (UDF) de Estimativa de Tempo de Produção -----------------------------------------------

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularTempoTotalFabricacaoMovel]
	(
		@IdProduto INT
	)
	RETURNS INT
	AS
	/*
		Documentacao
		Arquivo Fonte............:	Exercicio02.sql
		Objteivo.................:	Retornar o tempo em minutos que um produto leva para ser fabricado.
		Autor....................:	Djefferson dos Santos Lima
		Data.....................:	13/07/2026
		Ex.......................:
									SELECT	Nome,
											[dbo].[FNC_CalcularTempoTotalFabricacaoMovel](Id) as DuracaoFabricacao
										FROM [dbo].[Produto]
	*/
	BEGIN

		DECLARE @DuracaoEmMinutos INT;

		SELECT @DuracaoEmMinutos = SUM(DuracaoMinutos)
			FROM [dbo].[EtapaFabricacao]
			WHERE IdProduto = @IdProduto

		RETURN ISNULL(@DuracaoEmMinutos, 0)
	END;
GO
