SELECT hosts.hostname,
       days.start::date,
       COUNT(*),
       SUM(ROUND((spend_lower_bound + spend_upper_bound) / 2, 2)) as approximate_spend
FROM (select start, start + '23 hours 59 minutes 59 seconds' AS end
      from generate_series(
                   '2020-07-01'::timestamptz,
                   '2020-12-31'::timestamptz, '1 day'
               ) AS start
     ) AS days
         JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
         JOIN hosts ON adverts.host_id = hosts.id
WHERE adverts.host_id IS NOT NULL
GROUP BY days.start, hosts.hostname
ORDER BY COUNT(*) DESC
