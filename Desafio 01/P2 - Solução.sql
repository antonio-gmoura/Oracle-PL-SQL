/*
    Pergunta 2
    
    Dada a tabela TABELA_PRAZO, escreva uma query ou procedure em Oracle que una os registros cujas faixas de CEP
    com mesmo prazo s�o consideradas �vizinhas�. Considera-se que duas faixas de CEP s�o
    �vizinhas�, quando o CEP_FIM da primeira adicionando 1 � igual CEP_INICIO da segunda, e
    ambas tem o mesmo prazo. O resultado deste processo deve ser inserido na tabela TABELA_PRAZO_COMPACTADO.

    Solu��o proposta
    
    Criar uma procedure para popular a TABELA_PRAZO_COMPACTADO a partir da TABELA_PRAZO. N�o ser� colocado tratamento
    de exce��o, mas era algo fact�vel.
*/
CREATE OR REPLACE PROCEDURE popular_prazo_compactado
AS
    prazo_compactado_record tabela_prazo_compactado%ROWTYPE;
BEGIN
    -- Limpar a tabela prazo compactado.
    DELETE tabela_prazo_compactado;
    -- Obter todos os registros da tabela prazo ordenados por CEP_INICIO
    FOR prazo_record IN (
        SELECT *
          FROM tabela_prazo
         ORDER BY cep_inicio
    ) LOOP
        -- Tratar o registro da prazo compactado que est� na mem�ria.
        IF (prazo_compactado_record.cep_inicio IS NOT NULL) THEN
            -- Verificar se s�o "Vizinhos".
            IF (((prazo_compactado_record.cep_fim + 1) = prazo_record.cep_inicio) AND
                 (prazo_compactado_record.prazo        = prazo_record.prazo)) THEN
                -- Atualizar o "CEP_FIM", se forem vizinhos.
                prazo_compactado_record.cep_fim := prazo_record.cep_fim;
            ELSE
                -- Se n�o h� "Vizinhan�a", inserir o registro que est� na memoria.
                INSERT INTO tabela_prazo_compactado VALUES prazo_compactado_record;
                -- E limpar para que seja carregado com os novos dados.
                prazo_compactado_record := NULL;
            END IF;
        END IF;
        -- Formatar o registro do prazo compactado se estiver vazio.
        -- Isso ocorre quando � o primeiro registro ou quando n�o h� "vizinhan�a".
        IF (prazo_compactado_record.cep_inicio IS NULL) THEN
            prazo_compactado_record.cep_inicio := prazo_record.cep_inicio;
            prazo_compactado_record.cep_fim    := prazo_record.cep_fim;
            prazo_compactado_record.prazo      := prazo_record.prazo;
        END IF;
    END LOOP;
    -- Inserir o �ltimo registro que ficou pendente, se houver.
    IF (prazo_compactado_record.cep_inicio IS NOT NULL) THEN 
        INSERT INTO tabela_prazo_compactado VALUES prazo_compactado_record;
    END IF;
    -- Efetivar transa��o.
    COMMIT;
END;
/
/*
    Criei essa segunda vers�o s� para ver como ficaria fazendo a manuten��o
    da TABELA_CEPS_COMPACTADO logo ap�s cada registro do TABELA_CEPS. Nesse
    caso teria de prever INSERT e UPDATE. 
*/
CREATE OR REPLACE PROCEDURE popular_prazo_compactado_v2
AS
    prazo_compactado_record tabela_prazo_compactado%ROWTYPE;
BEGIN
    -- Limpar a tabela prazo compactado.
    DELETE tabela_prazo_compactado;
    -- Obter todos os registros da tabela prazo.
    FOR prazo_record IN (
        SELECT *
          FROM tabela_prazo
         ORDER BY cep_inicio
    ) LOOP
        -- Buscar na tabela compactada um registro que atenda a regra "cep fim" e "prazo". Se achar, atualizar o "cep fim" com o "cep fim" corrente.
        UPDATE tabela_prazo_compactado
           SET cep_fim     = prazo_record.cep_fim
         WHERE cep_fim + 1 = prazo_record.cep_inicio
           AND prazo       = prazo_record.prazo;
        -- Se n�o achar o CEP vizinho, incluir o registro conforme est� na tabela original.
        IF (SQL%ROWCOUNT = 0) THEN
            prazo_compactado_record.cep_inicio := prazo_record.cep_inicio;
            prazo_compactado_record.cep_fim    := prazo_record.cep_fim;
            prazo_compactado_record.prazo      := prazo_record.prazo;
            INSERT INTO tabela_prazo_compactado VALUES prazo_compactado_record;
        END IF;
    END LOOP;
    -- Efetivar transa��es.
    COMMIT;
END;
/
BEGIN
    popular_prazo_compactado;
END;
/
BEGIN
    popular_prazo_compactado_v2;
END;
/
SELECT * FROM tabela_prazo_compactado ORDER BY DECODE(cep_inicio, 1000000, 1, 510101, 2, 510000, 3, 510068, 4, 810000, 5);
/
DELETE tabela_prazo_compactado