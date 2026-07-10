USE woodcraftDjota;
GO

-- Exercício 2: Tempo de Espera (Ociosidade) entre Etapas -------------------------------------------------------------

WITH TempoInicioEtapa AS (
	SELECT	*
		FROM [dbo].[HistoricoProducao]
)

-- O banco [dbo].[HistoricoProducao] não está populado. O que impossibilita a conclusão da atividade.