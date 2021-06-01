/*
    Question 3
    
    Given a table events, write an SQL (Oracle SQL or PL/SQL) solution that, for each event_type that has been registered
    more than once, returns the difference between the penultimate and the oldest value (in terms of
    time) . The table should be ordered by event_type (in ascending order)
    
    Solução proposta
    
    Identar várias subconsultas até chegar numa onde as informações necessárias para se fazer o cálculo estejam presentes.
    Como o "TIME" faz parte da PK da tabela evento (ele é unico dentro de um evento) e também é a coluna no qual se baseia
    o critério de mais antigo e penúltimo, optou-se por se fazer na primeira subconsulta um agrupamento por evento, trazendo
    o menor (primeiro) e o maior (último) "TIME". A partir do último, buscou-se o penúltimo. Depois disso fez-se uma
    subconsulta para buscar o "VALUE" do primeiro "TIME" e outra para o do penúltimo. E, finalmente, realizou-se a operação
    solicitada.
*/
SELECT r.event_type
     , (r.value_penultimate - r.value_oldest) AS value
  FROM (
SELECT y.*
     , (SELECT o.value
         FROM events o
        WHERE o.event_type = y.event_type
          AND o.time       = y.penultimate_time) AS value_penultimate -- Obter o valor do penúltimo evento.       
  FROM (
SELECT x.*
     , (SELECT max(p.time)
          FROM events p
         WHERE p.event_type = x.event_type 
           AND p.time       < x.last_time) AS penultimate_time -- Obter o "TIME" do penúltimo evento.
     , (SELECT o.value
         FROM events o
        WHERE o.event_type = x.event_type
          AND o.time       = x.oldest_time) AS value_oldest    -- Obter o valor do evento mais antigo.       
  FROM (
SELECT event_type
     , MIN(time) AS oldest_time -- Obter o "TIME" do evento mais antigo
     , MAX(time) AS last_time   -- Obter o "TIME" do último evento.
  FROM events
 GROUP BY event_type
HAVING COUNT(*) > 1 -- Trazer somente os eventos com mais de um registro.
     ) x
     ) y
     ) r
 ORDER BY r.event_type ASC