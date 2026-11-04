USE transportadora_db;

-- Altera o delimitador padrão para evitar conflito com os ponto-e-vírgulas internos
DELIMITER $$

-- ============================================================================
-- 1. STORED FUNCTION (Cálculo Escalar do Frete)
-- ============================================================================
-- Recebe o peso da carga e calcula o frete proporcional (ex: R$ 0.50 por kg)
CREATE FUNCTION fn_calcular_frete(p_peso DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (p_peso * 0.50);
END$$

-- ============================================================================
-- 2. TRIGGER (Automação de Status do Veículo)
-- ============================================================================
-- Dispara automaticamente DEPOIS de inserir uma viagem para atualizar o caminhão
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
-- Valida o veículo, busca o peso da carga, chama a Function e grava a viagem.
CREATE PROCEDURE sp_registrar_viagem(
    IN p_id_motorista INT,
    IN p_id_veiculo INT,
    IN p_id_carga INT
)
BEGIN
    DECLARE v_status_veiculo VARCHAR(20);
    DECLARE v_peso DECIMAL(10,2);
    DECLARE v_frete DECIMAL(10,2);

    -- 1. Verifica o status do veículo selecionado
    SELECT status INTO v_status_veiculo 
    FROM veiculos 
    WHERE id_veiculo = p_id_veiculo;

    -- 2. Validação: se o veículo não estiver disponível, cancela a operação
    IF v_status_veiculo != 'Disponivel' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Veículo indisponível no momento!';
    ELSE
        -- 3. Busca o peso da carga informada
        SELECT peso_kg INTO v_peso 
        FROM cargas 
        WHERE id_carga = p_id_carga;

        -- 4. Invoca a Function para calcular o valor do frete
        SET v_frete = fn_calcular_frete(v_peso);

        -- 5. Insere o registro da viagem
        INSERT INTO viagens (id_motorista, id_veiculo, id_carga, valor_frete)
        VALUES (p_id_motorista, p_id_veiculo, p_id_carga, v_frete);
    END IF;
END$$

-- Restaura o delimitador padrão do MySQL
DELIMITER ;
