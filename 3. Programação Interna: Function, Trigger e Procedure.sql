USE transportadora_db;

-- Altera o delimitador padrão para compilar os blocos internos
DELIMITER $$

-- ============================================================================
-- 1. STORED FUNCTION (Cálculo de Frete com Distância e Peso)
-- ============================================================================
-- Recebe a distância e o peso para aplicar a regra matemática do frete:
-- R$ 2,00 por quilômetro + R$ 0,10 por quilo transportado.
CREATE FUNCTION fn_calcular_frete(p_distancia DECIMAL(10,2), p_peso DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (p_distancia * 2.00) + (p_peso * 0.10);
END$$

-- ============================================================================
-- 2. TRIGGER (Automação do Status do Veículo)
-- ============================================================================
-- Atualiza o status do caminhão para 'Em Viagem' de forma automática logo após o INSERT.
CREATE TRIGGER trg_atualizar_status_veiculo
AFTER INSERT ON viagens
FOR EACH ROW
BEGIN
    UPDATE veiculos 
    SET status = 'Em Viagem' 
    WHERE id_veiculo = NEW.id_veiculo;
END$$

-- ============================================================================
-- 3. STORED PROCEDURE (Validação e Registro de Viagem)
-- ============================================================================
-- Recebe apenas os IDs de motorista, veículo e carga.
-- A distância é obtida internamente ou repassada para a Function.
CREATE PROCEDURE sp_registrar_viagem(
    IN p_id_motorista INT,
    IN p_id_veiculo INT,
    IN p_id_carga INT
)
BEGIN
    -- Variáveis internas temporárias
    DECLARE v_status_veiculo VARCHAR(20);
    DECLARE v_peso DECIMAL(10,2);
    DECLARE v_distancia DECIMAL(10,2);
    DECLARE v_frete DECIMAL(10,2);

    -- 1. Consulta e armazena o status atual do veículo escolhido
    SELECT status INTO v_status_veiculo 
    FROM veiculos 
    WHERE id_veiculo = p_id_veiculo;

    -- 2. Validação: se o veículo não estiver disponível, aborta a execução
    IF v_status_veiculo != 'Disponivel' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Veículo indisponível no momento!';
    ELSE
        -- 3. Busca o peso da carga cadastrada na tabela de cargas
        SELECT peso_kg INTO v_peso 
        FROM cargas 
        WHERE id_carga = p_id_carga;

        -- 4. Define a distância estimada internamente (ex: 450 km)
        SET v_distancia = 450.00;

        -- 5. Invoca a Stored Function passando DISTÂNCIA e PESO
        SET v_frete = fn_calcular_frete(v_distancia, v_peso);

        -- 6. Grava a nova viagem na tabela
        INSERT INTO viagens (id_motorista, id_veiculo, id_carga, valor_frete)
        VALUES (p_id_motorista, p_id_veiculo, p_id_carga, v_frete);
    END IF;
END$$

-- Restaura o delimitador padrão do MySQL
DELIMITER ;
