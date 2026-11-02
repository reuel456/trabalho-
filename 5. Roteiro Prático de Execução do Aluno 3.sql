-- Garante o uso do banco
USE transportadora_db;

-- PASSO 1: Executa a View mostrando as viagens atuais
SELECT * FROM vw_viagens_em_andamento;

-- PASSO 2: Testa a Function isoladamente para demonstrar o cálculo no SELECT
SELECT fn_calcular_frete(500, 2000) AS valor_frete_calculado;

-- PASSO 3 & 4: Demostração da Procedure + Trigger
-- 1. Consulta o status inicial do veículo 1 (Mostra que ele está 'Disponivel')
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;

-- 2. Invoca a Procedure criando a viagem de 450 km
CALL sp_registrar_viagem(1, 1, 1, 450);

-- 3. Consulta novamente o veículo 1 e prova que a Trigger trocou o status para 'Em Viagem' sozinha
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;

-- PASSO 5: Teste DCL no usuário 'operador_patios'
-- Comando permitido (Retorna a lista de viagens da View com sucesso):
SELECT * FROM vw_viagens_em_andamento;

-- Comando bloqueado (Retorna 'Access Denied' provando a segurança do banco):
DELETE FROM veiculos WHERE id_veiculo = 1;
