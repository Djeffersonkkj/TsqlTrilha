USE woodcraftDjota;

-- Exercício 1: Validador de Status de Pedido -------------------------------------------------------------------------

-- 1. Declare uma variável chamada @IdPedido do tipo INT e atribua um valor a ela (ex: 1, 2 ou 99).

DECLARE @IdPedido INT = 67;

-- 2. O script deve consultar a tabela Pedido para obter as informações do pedido associado a este ID.

SELECT *
	FROM [dbo].[Pedido] WITH(NOLOCK)
	WHERE Id = @IdPedido;

-- 3. Utilizando a estrutura IF...ELSE, implemente as seguintes validações:
-- a) Caso o pedido não exista: Exiba a mensagem: "Erro: Pedido de ID [X] não encontrado no sistema."
IF NOT EXISTS ( SELECT TOP 1 1 FROM [dbo].[Pedido] WITH(NOLOCK) WHERE Id = @IdPedido)
	BEGIN
		PRINT('Erro, Pedido de ID [' + CAST(@IdPedido AS VARCHAR(10)) + '] não encontrado no sistema.');
	END

-- b) Caso o pedido exista e ainda não tenha sido entregue (DataEntrega é NULL): Exiba a mensagem: 
-- "Pedido [X] pendente de entrega. Prazo prometido: [DataPromessa]."
IF EXISTS ( SELECT TOP 1 1 FROM [dbo].[Pedido] WITH(NOLOCK) WHERE Id = @IdPedido AND DataEntrega is null)
	BEGIN
		PRINT('Pedido [' + CAST(@IdPedido AS VARCHAR(10)) + '] pendente de entrega.');
	END

-- c) Caso o pedido já tenha sido entregue (DataEntrega não é NULL): Exiba a mensagem:
-- "Pedido [X] entregue com sucesso em: [DataEntrega]."

IF EXISTS ( SELECT TOP 1 1 FROM [dbo].[Pedido] WITH(NOLOCK) WHERE Id = @IdPedido AND DataEntrega is not null)
	BEGIN
		PRINT('Pedido [' + CAST(@IdPedido AS VARCHAR(10)) + '] entregue com sucesso.');
	END

-- Exercício 2: Notificação de Pedidos Atrasados ----------------------------------------------------------------------

DECLARE @PedidosAtrasados TABLE		(
										IdPedido INT, 
										NomeCliente VARCHAR(100),
										DiasAtraso INT
									);

INSERT INTO @PedidosAtrasados (IdPedido, NomeCliente, DiasAtraso)
	SELECT	pe.Id,
			cl.Nome,
			DATEDIFF(DAY,pe.DataPromessa, GETDATE())
		FROM [dbo].[Pedido] as pe WITH(NOLOCK)
			JOIN [dbo].[Cliente] as cl WITH(NOLOCK)
				ON pe.IdCliente = cl.Id
		WHERE pe.DataEntrega is null AND pe.DataPromessa < GETDATE();


SELECT * FROM @PedidosAtrasados;

WHILE EXISTS (SELECT TOP 1 1 FROM @PedidosAtrasados)
	BEGIN
		DECLARE @IdAtual INT = (SELECT TOP 1 Id FROM [dbo].[Pedido]);

		IF EXISTS (SELECT TOP 1 1 FROM @PedidosAtrasados WHERE IdPedido = @IdAtual )
			BEGIN
				DECLARE @NomeCliente VARCHAR(100),
						@DiasAtraso INT;

				SELECT	TOP 1
						@NomeCliente = pa.NomeCliente,
						@DiasAtraso = pa.DiasAtraso
					FROM @PedidosAtrasados as pa
					WHERE pa.IdPedido = @IdAtual;

				PRINT ('ALERTA: O Pedido ID [' + CAST(@IdAtual AS VARCHAR(10)) + '] do cliente [' + @NomeCliente + '] está atrasado em [' + CAST(@DiasAtraso AS VARCHAR(10)) + '] dias.')
			END

		DELETE FROM @PedidosAtrasados
			WHERE IdPedido = @IdAtual;
	END


-- Exercício 3: Entrada de Insumos via JSON e Validação ---------------------------------------------------------------

DECLARE @InsumosJSON NVARCHAR(MAX) = N' [
	{"IdMateriaPrima": 1, "QuantidadeAdicional": 50},
    {"IdMateriaPrima": 2, "QuantidadeAdicional": 200},
    {"IdMateriaPrima": 3, "QuantidadeAdicional": 15},
	{"IdMateriaPrima": 67, "QuantidadeAdicional": 15}
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
			VALUES (@IdMateriaPrimaAtual, 1, GETDATE(), @QuantidadeAdicionalAtual)

		DELETE TOP(1) FROM #NovosInsumos

		PRINT('Estoque do insumo [' + @NomeInsumoAtual + 'atualizado. Quantidade adicionada: ' + @QuantidadeAdicionalAtual)
	END

DROP TABLE IF EXISTS #NovosInsumos;

SELECT * FROM MovimentacaoEstoqueMateriaPrima


