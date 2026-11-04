USE transportadora_db;

DELIMITER $$

-- ============================================================================
-- 1. FUNCTION: Cálculo do Frete baseado APENAS no Peso (ex: R$ 0,50 por kg)
-- ============================================================================
CREATE FUNCTION fn_calcular_frete(p_peso DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    -- Retorna R$ 0,50 para cada kg de carga
    RETURN (p_peso * 0.50);
END$$

-- ============================================================================
-- 2. PROCEDURE: Registra a Viagem sem o parâmetro de Distância
-- ============================================================================
CREATE PROCEDURE sp_registrar_viagem(
    IN p_id_motorista INT,
    IN p_id_veiculo INT,
    IN p_id_carga INT
)
BEGIN
    -- Variáveis internas temporárias
    DECLARE v_status_veiculo VARCHAR(20);
    DECLARE v_peso DECIMAL(10,2);
    DECLARE v_frete DECIMAL(10,2);

    -- 1. Verifica o status atual do veículo
    SELECT status INTO v_status_veiculo 
    FROM veiculos 
    WHERE id_veiculo = p_id_veiculo;

    -- 2. Validação de segurança: Veículo precisa estar disponível
    IF v_status_veiculo != 'Disponivel' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Veículo indisponível para despacho!';
    ELSE
        -- 3. Obtém o peso da carga cadastrada
        SELECT peso_kg INTO v_peso 
        FROM cargas 
        WHERE id_carga = p_id_carga;

        -- 4. Invoca a Function para calcular o frete com base apenas no peso
        SET v_frete = fn_calcular_frete(v_peso);

        -- 5. Insere a viagem no banco (sem a coluna de distância)
        INSERT INTO viagens (id_motorista, id_veiculo, id_carga, valor_frete)
        VALUES (p_id_motorista, p_id_veiculo, p_id_carga, v_frete);
    END IF;
END$$

DELIMITER ;
