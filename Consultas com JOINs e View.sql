-- Seleciona o banco correto
USE transportadora_db;

-- ============================================================================
-- INNER JOIN (Cruzando 4 Tabelas com Agregação)
-- ============================================================================
SELECT 
    m.id_motorista,                                -- Pega o ID do motorista
    m.nome AS motorista,                          -- Pega o nome do motorista e renomeia a coluna para 'motorista'
    COUNT(v.id_viagem) AS total_viagens,          -- Conta quantas viagens esse motorista realizou
    COALESCE(SUM(v.valor_frete), 0.00) AS total_faturado  -- Soma os fretes e troca NULL por 0.00 se não fez viagens
FROM motoristas m                                  -- Define a tabela 'motoristas' como 'm' (tabela principal)
INNER JOIN viagens v ON m.id_motorista = v.id_motorista  -- Cruza 'motoristas' com 'viagens' onde o ID do motorista for igual nas duas
GROUP BY m.id_motorista, m.nome;                   -- Agrupa os resultados por motorista para fazer a contagem/soma por pessoa

-- ============================================================================
-- LEFT JOIN (Procurando veículos sem viagens cadastradas)
-- ============================================================================
SELECT 
    vec.id_veiculo,                               -- Pega o ID do caminhão
    vec.placa,                                    -- Pega a placa do caminhão
    vec.modelo,                                   -- Pega o modelo
    v.id_viagem                                   -- Tenta pegar o ID da viagem correspondente
FROM veiculos vec                                 -- Tabela da ESQUERDA ('veiculos')
LEFT JOIN viagens v ON vec.id_veiculo = v.id_veiculo  -- Cruza com 'viagens', mantendo TODOS os veículos na lista
WHERE v.id_viagem IS NULL;                        -- Filtra apenas os veículos em que a coluna da viagem ficou vazia (NULL), provando ociosidade

-- ============================================================================
-- VIEW GERENCIAL (Viagens em Andamento)
-- ============================================================================
-- Cria ou substitui uma 'tabela virtual' chamada 'vw_viagens_em_andamento'
CREATE OR REPLACE VIEW vw_viagens_em_andamento AS
SELECT 
    v.id_viagem,                                  -- ID da viagem
    m.nome AS motorista,                          -- Nome do motorista em vez do número do ID
    vec.placa AS placa_veiculo,                   -- Placa do caminhão
    c.descricao AS carga,                         -- Descrição da mercadoria
    v.distancia_km,                               -- Quilometragem do percurso
    v.valor_frete,                                -- Valor em R$ do frete
    v.data_saida                                  -- Data/hora de saída
FROM viagens v                                    -- Partindo da tabela viagens
INNER JOIN motoristas m ON v.id_motorista = m.id_motorista  -- Cruza para pegar o nome do motorista
INNER JOIN veiculos vec ON v.id_veiculo = vec.id_veiculo    -- Cruza para pegar a placa do caminhão
INNER JOIN cargas c ON v.id_carga = c.id_carga              -- Cruza para pegar os dados da carga
WHERE v.status_viagem = 'Em Andamento';           -- Filtra mantendo na View apenas as cargas atualmente em transporte
