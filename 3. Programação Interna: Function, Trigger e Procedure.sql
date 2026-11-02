USE transportadora_db;

-- Muda o delimitador de instrução de ';' para '$$' para o MySQL compilar blocos contendo múltiplos ';'
DELIMITER $$

-- ============================================================================
-- STORED FUNCTION (Cálculo de Frete)
-- ============================================================================
-- Cria a função 'fn_calcular_frete' recebendo a distância e o peso como entrada
CREATE FUNCTION fn_calcular_frete(p_distancia DECIMAL(10,2), p_peso DECIMAL(10,2))
RETURNS DECIMAL(10,2)                            -- Declara que o resultado retornado será um número decimal com 2 casas
DETERMINISTIC                                    -- Informa ao MySQL que os mesmos dados de entrada geram sempre o mesmo resultado
BEGIN
    -- Retorna o valor calculado: R$ 2,00 por quilômetro mais R$ 0,10 por quilo de carga
    RETURN (p_distancia * 2.00) + (p_peso * 0.10);
END$$

-- ============================================================================
-- TRIGGER (Automação de Status do Veículo)
-- ============================================================================
-- Cria um gatilho 'trg_atualizar_status_veiculo' configurado para disparar DEPOIS de cada INSERT na tabela 'viagens'
CREATE TRIGGER trg_atualizar_status_veiculo
AFTER INSERT ON viagens
FOR EACH ROW
BEGIN
    -- Executa a atualização na tabela 'veiculos'
    UPDATE veiculos 
    -- Muda o status do caminhão para 'Em Viagem'
    SET status = 'Em Viagem' 
    -- Filtra a atualização usando o ID do veículo que ACABOU de ser inserido na viagem (através de 'NEW.id_veiculo')
    WHERE id_veiculo = NEW.id_veiculo;
END$$

-- ============================================================================
-- STORED PROCEDURE (Operação de Registro com Validação)
-- ============================================================================
-- Cria o procedimento 'sp_registrar_viagem' com 4 parâmetros de entrada (IN)
CREATE PROCEDURE sp_registrar_viagem(
    IN p_id_motorista INT,
    IN p_id_veiculo INT,
    IN p_id_carga INT,
    IN p_distancia_km DECIMAL(10,2)
)
BEGIN
    -- Declara variáveis internas temporárias para usar dentro do algoritmo
    DECLARE v_status_veiculo VARCHAR(20);
    DECLARE v_peso DECIMAL(10,2);
    DECLARE v_frete DECIMAL(10,2);

    -- Busca o status atual do veículo e salva dentro da variável 'v_status_veiculo'
    SELECT status INTO v_status_veiculo FROM veiculos WHERE id_veiculo = p_id_veiculo;

    -- Validação: Se o veículo NÃO estiver disponível...
    IF v_status_veiculo != 'Disponivel' THEN
        -- Aborta o procedimento e dispara um erro customizado na tela do usuário
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Veículo indisponível no momento!';
    ELSE
        -- Busca o peso da carga cadastrada e guarda na variável 'v_peso'
        SELECT peso_kg INTO v_peso FROM cargas WHERE id_carga = p_id_carga;
        
        -- Invoca a nossa Function criada anteriormente e guarda o resultado na variável 'v_frete'
        SET v_frete = fn_calcular_frete(p_distancia_km, v_peso);

        -- Grava o novo registro na tabela 'viagens' (isso dispara a TRIGGER em segundo plano!)
        INSERT INTO viagens (id_motorista, id_veiculo, id_carga, distancia_km, valor_frete)
        VALUES (p_id_motorista, p_id_veiculo, p_id_carga, p_distancia_km, v_frete);
    END IF;
END$$

-- Restaura o delimitador padrão do MySQL para ';'
DELIMITER ;
