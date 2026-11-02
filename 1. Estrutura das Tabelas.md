-- Cria o banco de dados caso ele ainda não exista no servidor
CREATE DATABASE IF NOT EXISTS transportadora_db;

-- Seleciona o banco 'transportadora_db' para que os próximos comandos sejam executados nele
USE transportadora_db;

-- Cria a tabela de Motoristas
CREATE TABLE motoristas (
    -- Cria a coluna 'id_motorista' como chave primária, inteira e com auto-incremento (1, 2, 3...)
    id_motorista INT AUTO_INCREMENT PRIMARY KEY,
    -- Define 'nome' como texto obrigatório (NOT NULL) de até 100 caracteres
    nome VARCHAR(100) NOT NULL,
    -- Define 'cnh' como texto único (não permite duas CNHs iguais) e obrigatório
    cnh VARCHAR(20) NOT NULL UNIQUE,
    -- Define 'status' limitando as opções a 'Ativo' ou 'Inativo', tendo 'Ativo' como padrão
    status ENUM('Ativo', 'Inativo') DEFAULT 'Ativo'
);

-- Cria a tabela de Veículos
CREATE TABLE veiculos (
    -- ID único do veículo, auto-incrementado e chave primária
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    -- Placa do caminhão, obrigatória e sem duplicidades no banco (UNIQUE)
    placa VARCHAR(10) NOT NULL UNIQUE,
    -- Modelo do caminhão (ex: Volvo FH 540)
    modelo VARCHAR(50) NOT NULL,
    -- Capacidade máxima de peso em quilos com até duas casas decimais
    capacidade_kg DECIMAL(10,2) NOT NULL,
    -- Status do caminhão com três estados possíveis; o padrão inicial é 'Disponivel'
    status ENUM('Disponivel', 'Em Viagem', 'Manutencao') DEFAULT 'Disponivel'
);

-- Cria a tabela de Cargas
CREATE TABLE cargas (
    -- ID único da carga, chave primária
    id_carga INT AUTO_INCREMENT PRIMARY KEY,
    -- Descrição da mercadoria transportada
    descricao VARCHAR(150) NOT NULL,
    -- Peso da carga em quilos
    peso_kg DECIMAL(10,2) NOT NULL,
    -- Valor financeiro declarado da mercadoria em reais
    valor_declarado DECIMAL(10,2) NOT NULL
);

-- Cria a tabela principal de Viagens
CREATE TABLE viagens (
    -- ID único da viagem registrada
    id_viagem INT AUTO_INCREMENT PRIMARY KEY,
    -- Chave estrangeira que receberá o ID do motorista
    id_motorista INT NOT NULL,
    -- Chave estrangeira que receberá o ID do veículo utilizado
    id_veiculo INT NOT NULL,
    -- Chave estrangeira que receberá o ID da carga transportada
    id_carga INT NOT NULL,
    -- Registra a data e hora de saída; se não informada, pega a data/hora atual (CURRENT_TIMESTAMP)
    data_saida DATETIME DEFAULT CURRENT_TIMESTAMP,
    -- Distância do percurso em quilômetros
    distancia_km DECIMAL(10,2) NOT NULL,
    -- Valor monetário cobrado pelo frete
    valor_frete DECIMAL(10,2) NOT NULL,
    -- Estado da viagem na estrada; começa por padrão como 'Em Andamento'
    status_viagem ENUM('Em Andamento', 'Concluida', 'Cancelada') DEFAULT 'Em Andamento',
    
    -- Estabelece que 'id_motorista' deve obrigatoriamente existir na tabela 'motoristas'
    FOREIGN KEY (id_motorista) REFERENCES motoristas(id_motorista),
    -- Estabelece que 'id_veiculo' deve obrigatoriamente existir na tabela 'veiculos'
    FOREIGN KEY (id_veiculo) REFERENCES veiculos(id_veiculo),
    -- Estabelece que 'id_carga' deve obrigatoriamente existir na tabela 'cargas'
    FOREIGN KEY (id_carga) REFERENCES cargas(id_carga)
);
