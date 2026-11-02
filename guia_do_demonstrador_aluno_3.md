# 📖 GUIA DE DEMONSTRAÇÃO PRÁTICA (SGBD MYSQL)
**Papel:** Aluno 3 — Execução e Validação do Sistema (`transportadora_db`)  
**Ambiente:** MySQL Workbench | Modelo Relacional de Gestão de Transportes  

---

## 🖥️ Configuração do Ambiente de Apresentação (Dois Monitores)

1. Conecte o segundo monitor/projetor e pressione **`Windows + P`** -> Selecione **Estender**.
2. **Tela Pública (Projetor/Banca):** Deixe aberto o **MySQL Workbench** com o arquivo `06_roteiro_apresentacao.sql` e fonte ampliada (`Ctrl` + `Scroll`).
3. **Tela Privada (Seu Notebook):** Deixe este arquivo Markdown aberto para consulta imediata de código, falas executivas e respostas técnicas.

---

## 🟢 ETAPA 1: Consulta da View Relacional (Estado Inicial)

* **Objetivo:** Demonstrar a abstração e simplificação de consultas complexas através de uma visão lógica (`VIEW`).
* **Instrução na Tela Publicada:** Executar o script de consulta da View gerencial.

```sql
SELECT * FROM vw_viagens_em_andamento;
```

* **Defesa Técnica Executiva:**
> *"Iniciamos a demonstração consultando a `VIEW` gerencial `vw_viagens_em_andamento`. Do ponto de vista arquitetural, a View encapsula um `INNER JOIN` de quatro tabelas (`viagens`, `motoristas`, `veiculos` e `cargas`). Isso abstrai a complexidade do modelo relacional para a camada de aplicação, entregando um relatório otimizado e formatado em tempo real."*

---

## 🟢 ETAPA 2: Execução de Stored Function (Cálculo Escalar)

* **Objetivo:** Demonstrar a aplicação de regras de negócio financeiras diretamente na camada de banco de dados.
* **Instrução na Tela Publicada:** Executar a chamada da função determinística dentro de um `SELECT`.

```sql
SELECT fn_calcular_frete(500, 2000) AS valor_frete_calculado;
```

* **Defesa Técnica Executiva:**
> *"Agora validamos a Stored Function determinística `fn_calcular_frete`. Ela recebe dois parâmetros escalares ($500\text{ km}$ e $2000\text{ kg}$) e processa a regra de precificação interna no SGBD. A vantagem dessa abordagem é garantir a padronização do cálculo financeiro em todo o sistema, sem depender da lógica da aplicação consumidora."*

---

## 🟢 ETAPA 3 & 4: Stored Procedure e Disparo de Trigger (Automação Reflexa)

* **Objetivo:** Demonstrar o processamento de transações com validação de dados e a automação de eventos via gatilhos (`TRIGGER`).
* **Instrução na Tela Publicada:** Executar os 3 comandos sequenciais para comprovação de estado.

```sql
-- 1. Verificação do estado inicial da entidade Veículo
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;

-- 2. Invocação da Stored Procedure de despacho
CALL sp_registrar_viagem(1, 1, 1, 450);

-- 3. Validação da mutação de estado automatizada pela Trigger
SELECT id_veiculo, placa, status FROM veiculos WHERE id_veiculo = 1;
```

* **Defesa Técnica Executiva:**
> *"Nesta etapa, demonstramos a integridade transacional. Primeiro, verificamos que o veículo de `id_veiculo = 1` possui o status `'Disponivel'`. Ao invocar a Stored Procedure `sp_registrar_viagem`, o SGBD valida a disponibilidade do recurso, invoca a Function para precificação e persiste a nova viagem.*
>
> *Na sequência, reconsultamos a tabela de veículos e observamos que o status mudou automaticamente para `'Em Viagem'`. Essa mutação foi executada pela `TRIGGER` acoplada ao evento `AFTER INSERT`, utilizando a pseudo-tabela `NEW.id_veiculo`. Isso garante a consistência do estado da frota sem a necessidade de requisições manuais de `UPDATE`."*

---

## 🟢 ETAPA 5: Teste de Segurança e Controle de Acesso (DCL)

* **Objetivo:** Comprovar a implementação do Princípio do Menor Privilégio (*Principle of Least Privilege*) na camada de banco de dados.
* **Instrução na Tela Publicada:** Alterar a conexão para a conta `operador_patios` e rodar os comandos de consulta e exclusão.

```sql
-- 1. Leitura autorizada na View
SELECT * FROM vw_viagens_em_andamento;

-- 2. Tentativa de mutação destrutiva (Bloqueio de Segurança)
DELETE FROM veiculos WHERE id_veiculo = 1;
```

* **Defesa Técnica Executiva:**
> *"Por fim, validamos a camada de segurança Data Control Language (DCL). Conectados com o perfil de privilégios restritos `operador_patios`, executamos com sucesso a consulta da View, conforme concedido via `GRANT SELECT`.*
>
> *Entretanto, ao tentar executar a instrução DML `DELETE`, o SGBD recusa a operação emitindo o erro `Access Denied`. Isso comprova que a política de concessão e revogação de acessos previne alterações não autorizadas e vazamento de permissões críticas no banco de dados."*

---

## 💡 Matriz de Respostas Rápidas para a Arguição da Banca

| Tópico Solicitado | Resposta Técnica Executiva |
| :--- | :--- |
| **Escopo do `DELIMITER $$`** | *"É uma instrução do cliente MySQL que altera temporariamente o caractere de término de instrução, permitindo a compilação de blocos lógicos estruturados (`BEGIN...END`) que contêm múltiplos ponto-e-vírgula internos."* |
| **Diferença: Function vs Procedure** | *"A Function é determinística ou escalar, retorna um único valor e é executada inline dentro de comandos DML (`SELECT`). A Procedure é um conjunto de instruções para processamento de regras de negócio, suporta parâmetros de entrada/saída (`IN/OUT`) e é invocada via `CALL`."* |
| **Comportamento das Pseudo-tabelas `NEW` e `OLD`** | *"São estruturas de memória temporárias disponibilizadas no contexto da Trigger. `NEW` contém os valores atribuídos durante operações de `INSERT` ou `UPDATE`, enquanto `OLD` referencia o estado anterior do registro em operações de `UPDATE` ou `DELETE`."* |
| **Mecanismo de Validação da Procedure** | *"A Procedure utiliza controle de fluxo `IF/ELSE` e a instrução `SIGNAL SQLSTATE '45000'` para interromper a transação e lançar uma exceção personalizada caso o recurso (veículo) esteja indisponível."* |
| **Impacto de Performance de Triggers** | *"As Triggers executam de forma síncrona dentro da mesma transação. Elas garantem integridade, mas devem ser concisas para não estender o tempo de lock das tabelas envolvidas."* |