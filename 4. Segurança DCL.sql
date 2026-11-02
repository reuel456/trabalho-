USE transportadora_db;

-- Cria o usuário 'operador_patios' no MySQL caso ele não exista, definindo sua senha
CREATE USER IF NOT EXISTS 'operador_patios'@'localhost' IDENTIFIED BY 'senha123';

-- Concede o privilégio de realizar SELECT (consultas) APENAS na View 'vw_viagens_em_andamento'
GRANT SELECT ON transportadora_db.vw_viagens_em_andamento TO 'operador_patios'@'localhost';

-- Concede o privilégio de executar (EXECUTE) a Procedure 'sp_registrar_viagem'
GRANT EXECUTE ON PROCEDURE transportadora_db.sp_registrar_viagem TO 'operador_patios'@'localhost';

-- Atualiza a tabela de privilégios do MySQL imediatamente para aplicar os novos acessos
FLUSH PRIVILEGES;
