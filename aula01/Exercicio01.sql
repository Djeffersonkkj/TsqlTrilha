USE woodcraftDjota;

-- Exercício 1: Validador de Status de Pedido -------------------------------------------------------------------------

-- 1. Declare uma variável chamada @IdPedido do tipo INT e atribua um valor a ela (ex: 1, 2 ou 99).

DECLARE @IdPedido INT = 3;

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
		DECLARE @DataPromessa DATE = (SELECT TOP 1 DataPromessa FROM [dbo].[Pedido] WITH(NOLOCK) WHERE Id = @IdPedido);
		PRINT('Pedido [' + CAST(@IdPedido AS VARCHAR(10)) + '] pendente de entrega. Prazo prometido: ' + CAST(@DataPromessa AS VARCHAR(20)));
	END

-- c) Caso o pedido já tenha sido entregue (DataEntrega não é NULL): Exiba a mensagem:
-- "Pedido [X] entregue com sucesso em: [DataEntrega]."

IF EXISTS ( SELECT TOP 1 1 FROM [dbo].[Pedido] WITH(NOLOCK) WHERE Id = @IdPedido AND DataEntrega is not null)
	BEGIN
		DECLARE @DataEntrega DATE = (SELECT TOP 1 DataEntrega FROM [dbo].[Pedido] WITH(NOLOCK) WHERE Id = @IdPedido);
		PRINT('Pedido [' + CAST(@IdPedido AS VARCHAR(10)) + '] entregue com sucesso em: ' + CAST(@DataEntrega AS VARCHAR(20)));
	END
