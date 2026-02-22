CREATE TABLE marca (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    pais_origem VARCHAR(100),
    ano_fundacao INT,
    website VARCHAR(255),
    logo_url VARCHAR(255),
    descricao TEXT,
    status VARCHAR(20) DEFAULT 'ATIVO',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE modelo (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    marca_id BIGINT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    tipo_carroceria VARCHAR(50),
    segmento VARCHAR(50),
    ano_inicio_fabricacao INT,
    ano_fim_fabricacao INT,
    tipo_combustivel_padrao VARCHAR(50),
    numero_portas INT,
    capacidade_passageiros INT,
    volume_porta_malas DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'ATIVO',
    FOREIGN KEY (marca_id) REFERENCES marca(id)
);

CREATE TABLE usuario (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nome_completo VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    cpf_cnpj VARCHAR(20) NOT NULL UNIQUE,
    telefone_principal VARCHAR(20),
    telefone_secundario VARCHAR(20),
    data_nascimento DATE,
    genero VARCHAR(20),
    foto_perfil_url VARCHAR(255),
    tipo_usuario VARCHAR(20) NOT NULL, -- COMPRADOR, VENDEDOR, AMBOS, ADMIN
    status_conta VARCHAR(20) DEFAULT 'ATIVA',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_ultimo_login TIMESTAMP,
    aceitou_termos BOOLEAN DEFAULT FALSE
);

CREATE TABLE endereco (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    cep VARCHAR(20) NOT NULL,
    pais VARCHAR(50) DEFAULT 'Brasil',
    tipo_endereco VARCHAR(20), -- RESIDENCIAL, COMERCIAL
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    principal BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)
);

CREATE TABLE veiculo (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    modelo_id BIGINT NOT NULL,
    proprietario_id BIGINT NOT NULL,
    ano_fabricacao INT NOT NULL,
    ano_modelo INT NOT NULL,
    cor VARCHAR(50),
    quilometragem INT NOT NULL,
    placa VARCHAR(10) UNIQUE,
    chassi VARCHAR(50) UNIQUE,
    renavam VARCHAR(50) UNIQUE,
    tipo_combustivel VARCHAR(50),
    tipo_cambio VARCHAR(50),
    blindado BOOLEAN DEFAULT FALSE,
    unico_dono BOOLEAN DEFAULT FALSE,
    ipva_pago BOOLEAN DEFAULT FALSE,
    licenciado BOOLEAN DEFAULT FALSE,
    observacoes TEXT,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'DISPONIVEL',
    FOREIGN KEY (modelo_id) REFERENCES modelo(id),
    FOREIGN KEY (proprietario_id) REFERENCES usuario(id)
);

CREATE TABLE acessorio (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(50),
    valor_estimado DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'ATIVO',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE veiculo_acessorio (
    veiculo_id BIGINT NOT NULL,
    acessorio_id BIGINT NOT NULL,
    data_instalacao DATE,
    PRIMARY KEY (veiculo_id, acessorio_id),
    FOREIGN KEY (veiculo_id) REFERENCES veiculo(id),
    FOREIGN KEY (acessorio_id) REFERENCES acessorio(id)
);

CREATE TABLE anuncio (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    veiculo_id BIGINT NOT NULL,
    vendedor_id BIGINT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descricao_detalhada TEXT,
    preco DECIMAL(15, 2) NOT NULL,
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP,
    status_anuncio VARCHAR(20) DEFAULT 'ATIVO',
    numero_visualizacoes INT DEFAULT 0,
    destaque BOOLEAN DEFAULT FALSE,
    permite_troca BOOLEAN DEFAULT FALSE,
    localizacao_anuncio VARCHAR(255),
    contato_preferencial VARCHAR(50),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (veiculo_id) REFERENCES veiculo(id),
    FOREIGN KEY (vendedor_id) REFERENCES usuario(id)
);

CREATE TABLE proposta (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    anuncio_id BIGINT NOT NULL,
    comprador_id BIGINT NOT NULL,
    valor_oferta DECIMAL(15, 2) NOT NULL,
    mensagem TEXT,
    data_proposta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_proposta VARCHAR(20) DEFAULT 'PENDENTE', -- ACEITA, RECUSADA, PENDENTE
    validade_proposta DATE,
    forma_pagamento_proposta VARCHAR(100),
    data_resposta TIMESTAMP,
    FOREIGN KEY (anuncio_id) REFERENCES anuncio(id),
    FOREIGN KEY (comprador_id) REFERENCES usuario(id)
);

CREATE TABLE venda (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    anuncio_id BIGINT NOT NULL,
    comprador_id BIGINT NOT NULL,
    vendedor_id BIGINT NOT NULL,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_final DECIMAL(15, 2) NOT NULL,
    metodo_pagamento VARCHAR(50),
    status_venda VARCHAR(20) DEFAULT 'CONCLUIDA',
    nota_fiscal VARCHAR(100),
    observacoes TEXT,
    comissao_plataforma DECIMAL(10, 2),
    data_confirmacao TIMESTAMP,
    FOREIGN KEY (anuncio_id) REFERENCES anuncio(id),
    FOREIGN KEY (comprador_id) REFERENCES usuario(id),
    FOREIGN KEY (vendedor_id) REFERENCES usuario(id)
);

CREATE TABLE pagamento (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    venda_id BIGINT NOT NULL,
    valor DECIMAL(15, 2) NOT NULL,
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metodo VARCHAR(50), -- CARTAO, PIX, BOLETO
    status VARCHAR(20), -- APROVADO, PENDENTE, RECUSADO
    codigo_transacao VARCHAR(100),
    gateway_pagamento VARCHAR(50),
    parcelas INT DEFAULT 1,
    data_vencimento DATE,
    comprovante_url VARCHAR(255),
    FOREIGN KEY (venda_id) REFERENCES venda(id)
);

CREATE TABLE avaliacao (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    venda_id BIGINT NOT NULL,
    avaliador_id BIGINT NOT NULL,
    avaliado_id BIGINT NOT NULL,
    nota INT CHECK (nota >= 1 AND nota <= 5),
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    visivel BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (venda_id) REFERENCES venda(id),
    FOREIGN KEY (avaliador_id) REFERENCES usuario(id),
    FOREIGN KEY (avaliado_id) REFERENCES usuario(id)
);

CREATE TABLE historico_preco (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    anuncio_id BIGINT NOT NULL,
    preco_anterior DECIMAL(15, 2),
    preco_novo DECIMAL(15, 2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(255),
    FOREIGN KEY (anuncio_id) REFERENCES anuncio(id)
);
