/*
    Question 3
    
    Given a table events, write an SQL (Oracle SQL or PL/SQL) solution that, for each event_type that has been registered
    more than once, returns the difference between the penultimate and the oldest value (in terms of
    time) . The table should be ordered by event_type (in ascending order)
    
    Solu��o proposta
    
    Identar v�rias subconsultas at� chegar numa onde as informa��es necess�rias para se fazer o c�lculo estejam presentes.
    Como o "TIME" faz parte da PK da tabela evento (ele � unico dentro de um evento) e tamb�m � a coluna no qual se baseia
    o crit�rio de mais antigo e pen�ltimo, optou-se por se fazer na primeira subconsulta um agrupamento por evento, trazendo
    o menor (primeiro) e o maior (�ltimo) "TIME". A partir do �ltimo, buscou-se o pen�ltimo. Depois disso fez-se uma
    subconsulta para buscar o "VALUE" do primeiro "TIME" e outra para o do pen�ltimo. E, finalmente, realizou-se a opera��o
    solicitada.
*/
SELECT r.event_type
     , (r.value_penultimate - r.value_oldest) AS value
  FROM (
SELECT y.*
     , (SELECT o.value
         FROM events o
        WHERE o.event_type = y.event_type
          AND o.time       = y.penultimate_time) AS value_penultimate -- Obter o valor do pen�ltimo evento.       
  FROM (
SELECT x.*
     , (SELECT max(p.time)
          FROM events p
         WHERE p.event_type = x.event_type 
           AND p.time       < x.last_time) AS penultimate_time -- Obter o "TIME" do pen�ltimo evento.
     , (SELECT o.value
         FROM events o
        WHERE o.event_type = x.event_type
          AND o.time       = x.oldest_time) AS value_oldest    -- Obter o valor do evento mais antigo.       
  FROM (
SELECT event_type
     , MIN(time) AS oldest_time -- Obter o "TIME" do evento mais antigo
     , MAX(time) AS last_time   -- Obter o "TIME" do �ltimo evento.
  FROM events
 GROUP BY event_type
HAVING COUNT(*) > 1 -- Trazer somente os eventos com mais de um registro.
     ) x
     ) y
     ) r
 ORDER BY r.event_type ASC