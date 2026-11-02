================================================================================
PASSO 1: CONSULTA DA VIEW
================================================================================
💻 [NO MYSQL]: 
SELECT * FROM vw_viagens_em_andamento;

🗣️ [SUA EXPLICAÇÃO]:
"Professora, aqui eu rodo a View 'vw_viagens_em_andamento'. Ela resume a consulta 
de 4 tabelas com INNER JOIN e mostra direto quem está na estrada com os dados já 
formatados."

================================================================================
PASSO 2: TESTE DA FUNCTION
================================================================================
💻 [NO MYSQL]: 
SELECT fn_calcular_frete(500, 2000) AS valor_frete_calculado;

🗣️ [SUA EXPLICAÇÃO]:
"Agora eu rodo a Function 'fn_calcular_frete'. Ela pega a distância (500 km) e o 
peso (2000 kg) e me devolve o valor exato do frete em R$ direto no SELECT."

================================================================================
PASSO 3 E 4: PROCEDURE + TRIGGER (GATILHO AUTOMÁTICO)
================================================================================
💻 [NO MYSQL - PARTE A]: 
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;

🗣️ [SUA EXPLICAÇÃO]:
"Reparem que o caminhão ID 1 está atualmente 'Disponivel'."

💻 [NO MYSQL - PARTE B]: 
CALL sp_registrar_viagem(1, 1, 1, 450);

🗣️ [SUA EXPLICAÇÃO]:
"Vou rodar a Procedure 'sp_registrar_viagem'. Ela valida a disponibilidade do 
caminhão, calcula o frete com a Function e insere a viagem."

💻 [NO MYSQL - PARTE C]: 
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;

🗣️ [SUA EXPLICAÇÃO]:
"Olhem o efeito reflexo: ao consultar o caminhão 1 de novo, o status mudou sozinho 
para 'Em Viagem'. Quem fez isso foi a nossa Trigger, sem eu precisar rodar nenhum 
UPDATE manual."

================================================================================
PASSO 5: TESTE DE SEGURANÇA (DCL)
================================================================================
💻 [NO MYSQL - PARTE A]: (Na conexão 'operador_patios')
SELECT * FROM vw_viagens_em_andamento;

🗣️ [SUA EXPLICAÇÃO]:
"Troquei para o usuário 'operador_patios'. Ele consulta a View sem problemas 
porque demos a permissão GRANT SELECT."

💻 [NO MYSQL - PARTE B]: 
DELETE FROM veiculos WHERE id_veiculo = 1;

🗣️ [SUA EXPLICAÇÃO]:
"Mas se ele tenta rodar um DELETE para apagar o caminhão... o MySQL bloqueia na 
hora com 'Access Denied'. Isso prova que o nosso controle de segurança DCL está 
funcionando."
