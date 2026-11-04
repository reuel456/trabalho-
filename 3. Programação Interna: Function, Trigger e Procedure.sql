-- ============================================================================
-- PROJETO BANCO DE DADOS: SISTEMA DE TRANSPORTADORA (transportadora_db)
-- Script Completo DDL, DML, Programmability (Function, Trigger, Procedure) e DCL
-- ============================================================================

-- 1. CRIAÇÃO E SELEÇÃO DO BANCO DE DADOS
CREATE DATABASE IF NOT EXISTS transportadora_db;
USE transportadora_db;

-- ----------------------------------------------------------------------------
-- 2. DDL - ESTRUTURA DAS TABELAS
-- ----------------------------------------------------------------------------

-- Tabela de Motoristas
CREATE TABLE IF NOT EXISTS motoristas (
    id_motorista INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnh VARCHAR(20) NOT NULL UNIQUE,
    status ENUM('Ativo', 'Inativo') DEFAULT 'Ativo'
);

-- Tabela de Veículos
CREATE TABLE IF NOT EXISTS veiculos (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL UNIQUE,
    modelo VARCHAR(50) NOT NULL,
    capacidade_kg DECIMAL(10,2) NOT NULL,
    status ENUM('Disponivel', 'Em Viagem', 'Manutencao') DEFAULT 'Disponivel'
);

-- Tabela de Cargas
CREATE TABLE IF NOT EXISTS cargas (
    id_carga INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(150) NOT NULL,
    peso_kg DECIMAL(10,2) NOT NULL,
    valor_declarado DECIMAL(10,2) NOT NULL
);

-- Tabela de Viagens (Sem a coluna distancia_km)
CREATE TABLE IF NOT EXISTS viagens (
    id_viagem INT AUTO_INCREMENT PRIMARY KEY,
    id_motorista INT NOT NULL,
    id_veiculo INT NOT NULL,
    id_carga INT NOT NULL,
    data_saida DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_frete DECIMAL(10,2) NOT NULL,
    status_viagem ENUM('Em Andamento', 'Concluida', 'Cancelada') DEFAULT 'Em Andamento',
    FOREIGN KEY (id_motorista) REFERENCES motoristas(id_motorista),
    FOREIGN KEY (id_veiculo) REFERENCES veiculos(id_veiculo),
    FOREIGN KEY (id_carga) REFERENCES cargas(id_carga)
);

-- ----------------------------------------------------------------------------
-- 3. DML - CARGA DE DADOS DE TESTE
-- ----------------------------------------------------------------------------

INSERT INTO motoristas (nome, cnh) VALUES 
('Carlos Silva', '12345678900'),
('Ana Oliveira', '98765432100');

INSERT INTO veiculos (placa, modelo, capacidade_kg, status) VALUES 
('ABC-1234', 'Volvo FH 540', 25000.00, 'Disponivel'),
('XYZ-5678', 'Scania R450', 20000.00, 'Disponivel');

INSERT INTO cargas (descricao, peso_kg, valor_declarado) VALUES 
('Carga de Soja', 15000.00, 80000.00),
('Eletrônicos', 5000.00, 150000.00);

-- ----------------------------------------------------------------------------
-- 4. VIEW GERENCIAL
-- ----------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_viagens_em_andamento AS
SELECT 
    v.id_viagem,
    m.nome AS motorista,
    vec.placa AS placa_veiculo,
    c.descricao AS carga,
    c.peso_kg,
    v.valor_frete,
    v.data_saida
FROM viagens v
INNER JOIN motoristas m ON v.id_motorista = m.id_motorista
INNER JOIN veiculos vec ON v.id_veiculo = vec.id_veiculo
INNER JOIN cargas c ON v.id_carga = c.id_carga
WHERE v.status_viagem = 'Em Andamento';

-- ----------------------------------------------------------------------------
-- 5. PROGRAMMABILITY (FUNCTION, TRIGGER E PROCEDURE)
-- ----------------------------------------------------------------------------

DELIMITER $$

-- FUNCTION: Calcula o frete com base no peso da carga (R$ 0.50 por kg)
CREATE FUNCTION fn_calcular_frete(p_peso DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (p_peso * 0.50);
END$$

-- TRIGGER: Atualiza o status do veículo para 'Em Viagem' automaticamente após o INSERT
CREATE TRIGGER trg_atualizar_status_veiculo
AFTER INSERT ON viagens
FOR EACH ROW
BEGIN
    UPDATE veiculos 
    SET status = 'Em Viagem' 
    WHERE id_veiculo = NEW.id_veiculo;
END$$

-- PROCEDURE: Valida o veículo, busca o peso da carga, chama a Function e grava a viagem
-- (Sem o parâmetro de distância)
CREATE PROCEDURE sp_registrar_viagem(
    IN p_id_motorista INT,
    IN p_id_veiculo INT,
    IN p_id_carga INT
)
BEGIN
    DECLARE v_status_veiculo VARCHAR(20);
    DECLARE v_peso DECIMAL(10,2);
    DECLARE v_frete DECIMAL(10,2);

    -- 1. Verifica status do veículo
    SELECT status INTO v_status_veiculo 
    FROM veiculos 
    WHERE id_veiculo = p_id_veiculo;

    -- 2. Validação de segurança
    IF v_status_veiculo != 'Disponivel' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Veículo indisponível no momento!';
    ELSE
        -- 3. Obtém o peso da carga cadastrada
        SELECT peso_kg INTO v_peso 
        FROM cargas 
        WHERE id_carga = p_id_carga;

        -- 4. Invoca a Function para calcular o frete
        SET v_frete = fn_calcular_frete(v_peso);

        -- 5. Insere a nova viagem
        INSERT INTO viagens (id_motorista, id_veiculo, id_carga, valor_frete)
        VALUES (p_id_motorista, p_id_veiculo, p_id_carga, v_frete);
    END IF;
END$$

DELIMITER ;

-- ----------------------------------------------------------------------------
-- 6. DCL - USUÁRIO E PERMISSÕES DE SEGURANÇA
-- ----------------------------------------------------------------------------

CREATE USER IF NOT EXISTS 'operador_patios'@'localhost' IDENTIFIED BY 'senha123';
GRANT SELECT ON transportadora_db.vw_viagens_em_andamento TO 'operador_patios'@'localhost';
GRANT EXECUTE ON PROCEDURE transportadora_db.sp_registrar_viagem TO 'operador_patios'@'localhost';
FLUSH PRIVILEGES;

-- ============================================================================
-- ROTEIRO DE DEMONSTRAÇÃO DO ALUNO 3 (EXECUÇÃO AO VIVO)
-- ============================================================================

-- PASSO 1: Mostrar a View de viagens
SELECT * FROM vw_viagens_em_andamento;

-- PASSO 2: Testar a Function isoladamente (Ex: Peso de 2000 kg)
SELECT fn_calcular_frete(2000) AS frete_calculado;

-- PASSO 3 & 4: Testar a Procedure e comprovar o disparo da Trigger
-- 1. Verifica status inicial do veículo 1 (Mostra 'Disponivel')
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;

-- 2. Executa a Procedure (Motorista 1, Veículo 1, Carga 1)
CALL sp_registrar_viagem(1, 1, 1);

-- 3. Verifica o status do veículo 1 novamente (Trigger alterou para 'Em Viagem')
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;

-- PASSO 5: Testar bloqueio DCL (Conectado como 'operador_patios')
-- SELECT na View funciona:
-- SELECT * FROM vw_viagens_em_andamento;

-- DELETE é bloqueado pelo MySQL (Access Denied):
-- DELETE FROM veiculos WHERE id_veiculo = 1;
