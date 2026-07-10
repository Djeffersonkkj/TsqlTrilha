USE woodcraftDjota;
GO

-- Exercício 1: Classificação de Etapas de Fabricação -----------------------------------------------------------------

WITH EtapasPorProduto AS (
	SELECT	pr.Id,
			pr.Nome,
			et.Descricao,
			et.NumeroEtapa,
			ROW_NUMBER() OVER (
				PARTITION BY pr.Id
				ORDER BY et.NumeroEtapa DESC
			) AS SequenciaEtapaDecrescente
		FROM [dbo].[Produto] as pr
			JOIN [dbo].[EtapaFabricacao] as et
				ON pr.Id = et.IdProduto
)
SELECT	*
	FROM EtapasPorProduto
	WHERE SequenciaEtapaDecrescente = 1;