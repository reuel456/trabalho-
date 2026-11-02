
PASSO 3 & 4: Executar a Procedure e Mostrar a Trigger
O que você faz na tela pública (em 3 cliques):

Roda o SELECT do status inicial:

SQL
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;
Roda a Procedure:

SQL
CALL sp_registrar_viagem(1, 1, 1, 450);
Roda o SELECT do status novamente para provar a mudança:

SQL
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;
O que você lê na sua tela privada para explicar:

"Reparem que o veículo ID 1 estava 'Disponivel'. Ao chamar a Procedure sp_registrar_viagem, o sistema valida se ele pode rodar e insere a nova viagem. Em segundo plano, a nossa TRIGGER dispara de forma automática (AFTER INSERT) e atualiza o status do caminhão para 'Em Viagem' sem necessidade de um UPDATE manual."

PASSO 5: Provar a Segurança DCL (Usuário Restrito)
O que você faz na tela pública:

Troca a aba da conexão no MySQL Workbench para a conta 'operador_patios'.

Roda a consulta da View (funciona).

Roda o comando DELETE (mostra o erro em vermelho na tela).

O que você lê na sua tela privada para explicar:

"Por fim, troquei para o perfil do operador de pátio para testar o DCL. Ele consegue consultar a View perfeitamente, mas quando tenta executar um DELETE para apagar dados, o MySQL bloqueia a ação disparando 'Access Denied', provando a aplicação do princípio do menor privilégio com o comando GRANT."
