USE transportadora_db;

DELIMITER $$

CREATE PROCEDURE sp_registrar_viagem(
    IN p_id_motorista INT,
    IN p_id_veiculo INT,
    IN p_id_carga INT
)
BEGIN
    DECLARE v_status_veiculo VARCHAR(20);
    DECLARE v_peso DECIMAL(10,2);
    DECLARE v_frete DECIMAL(10,2);

    -- 1. Verifica se o veículo está disponível
    SELECT status INTO v_status_veiculo 
    FROM veiculos 
    WHERE id_veiculo = p_id_veiculo;

    IF v_status_veiculo != 'Disponivel' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Veículo indisponível no momento!';
    ELSE
        -- 2. Busca o peso da carga cadastrada
        SELECT peso_kg INTO v_peso 
        FROM cargas 
        WHERE id_carga = p_id_carga;

        -- 3. Calcula o frete via Function passando apenas o peso
        SET v_frete = fn_calcular_frete(v_peso);

        -- 4. Insere a nova viagem sem precisar passar a distância no CALL
        INSERT INTO viagens (id_motorista, id_veiculo, id_carga, valor_frete)
        VALUES (p_id_motorista, p_id_veiculo, p_id_carga, v_frete);
    END IF;
END$$

DELIMITER ;
