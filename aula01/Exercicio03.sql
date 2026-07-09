USE woodcraftDjota;

-- Exercício 3: Entrada de Insumos via JSON e Validação ---------------------------------------------------------------

DECLARE @InsumosJSON NVARCHAR(MAX) = N' [
	{"IdMateriaPrima": 1, "QuantidadeAdicional": 50},
    {"IdMateriaPrima": 2, "QuantidadeAdicional": 200},
    {"IdMateriaPrima": 3, "QuantidadeAdicional": 15}
]';

CREATE TABLE #NovosInsumos (
	IdMateriaPrima INT,
	QuantidadeAdicional INT
);

INSERT INTO #NovosInsumos (IdMateriaPrima, QuantidadeAdicional)
	SELECT	IdMateriaPrima,
			QuantidadeAdicional
		FROM OPENJSON(@InsumosJSON)
			WITH (
				IdMateriaPrima INT '$.IdMateriaPrima',
				QuantidadeAdicional INT '$.QuantidadeAdicional'

			);

DECLARE @InsumosNaoCadastrados TABLE (IdMateriaPrima INT);

INSERT INTO @InsumosNaoCadastrados (IdMateriaPrima)
	SELECT IdMateriaPrima
		FROM #NovosInsumos temp
			LEFT JOIN [dbo].[MateriaPrima] as mp WITH(NOLOCK)
				ON temp.IdMateriaPrima = mp.Id
		WHERE mp.Id is null

IF EXISTS (SELECT TOP 1 1 FROM @InsumosNaoCadastrados)
	BEGIN
		WHILE EXISTS (SELECT TOP 1 1 FROM @InsumosNaoCadastrados)
			BEGIN
				DECLARE @IdMateriaPrimaAtual INT = (SELECT TOP 1 IdMateriaPrima FROM @InsumosNaoCadastrados)
				PRINT('Erro: O insumo de ID [' + CAST(@IdMateriaPrimaAtual AS VARCHAR(10)) + '] não existe no catálogo do sistema.');

				DELETE FROM @InsumosNaoCadastrados
					WHERE IdMateriaPrima = @IdMateriaPrimaAtual;
			END

		DELETE FROM #NovosInsumos;

		RETURN;
	END

WHILE EXISTS (SELECT TOP 1 1 FROM #NovosInsumos)
	BEGIN
		DECLARE @IdMateriaPrimaContextoAtual INT,
				@QuantidadeAdicionalAtual INT,
				@NomeInsumoAtual VARCHAR(100)
			
		SELECT	TOP 1
				@IdMateriaPrimaContextoAtual = temp.IdMateriaPrima,
				@QuantidadeAdicionalAtual = temp.QuantidadeAdicional,
				@NomeInsumoAtual = ma.Nome
			FROM #NovosInsumos as temp
				JOIN [dbo].[MateriaPrima] as ma
					ON temp.IdMateriaPrima = ma.Id

		UPDATE [dbo].[EstoqueMateriaPrima]
			SET	QuantidadeFisica = QuantidadeFisica + @QuantidadeAdicionalAtual
			WHERE IdMateriaPrima = @IdMateriaPrimaContextoAtual

		INSERT INTO [dbo].[MovimentacaoEstoqueMateriaPrima] (IdEstoqueMateriaPrima, IdTipoMovimentacao, DataMovimentacao, Quantidade)
			VALUES (@IdMateriaPrimaContextoAtual, 1, GETDATE(), @QuantidadeAdicionalAtual)

		DELETE TOP(1) FROM #NovosInsumos

		PRINT('Estoque do insumo [' + @NomeInsumoAtual + 'atualizado. Quantidade adicionada: ' + CAST(@QuantidadeAdicionalAtual AS VARCHAR(10)))
	END

DROP TABLE IF EXISTS #NovosInsumos;

SELECT * FROM MovimentacaoEstoqueMateriaPrima

SELECT * FROM EstoqueMateriaPrima
