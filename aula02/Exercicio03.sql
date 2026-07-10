USE woodcraftDjota;
GO

-- Exercício 3: Fluxo Acumulado de Produção e Dependência -------------------------------------------------------------

WITH EtapasPorProduto AS (
	SELECT	pr.Id,
			pr.Nome,
			et.Descricao,
			et.NumeroEtapa,
			et.DuracaoMinutos,
			SUM(et.DuracaoMinutos) OVER (
				PARTITION BY pr.Id
				ORDER BY et.NumeroEtapa
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS DuracaoMinutosAcumulada,
			LAG(et.Descricao) OVER (
				PARTITION BY pr.Id
				ORDER BY et.NumeroEtapa
			) AS EtapaAnterior
		FROM [dbo].[Produto] as pr
			JOIN [dbo].[EtapaFabricacao] as et
				ON pr.Id = et.IdProduto
)
SELECT	Nome,
		NumeroEtapa,
		Descricao,
		DuracaoMinutos,
		DuracaoMinutosAcumulada,
		ISNULL(EtapaAnterior, '[Início da Fabricação]') AS EtapaAnteriorDescricao
	FROM EtapasPorProduto
	ORDER BY Nome, NumeroEtapa;
