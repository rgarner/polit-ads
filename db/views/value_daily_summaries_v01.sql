SELECT funding_entities.campaign_id,
       u.index,
       u.value,
       days.start::date,
       COUNT(*),
       SUM(ROUND((adverts.spend_lower_bound + adverts.spend_upper_bound) / 2, 2)) AS approximate_spend
FROM (SELECT start, start + '23 hours 59 minutes 59 seconds' AS end
      FROM generate_series(
                   '2020-07-01'::timestamptz,
                   '2021-01-01'::timestamptz, '1 day'
               ) AS start
     ) AS days
         JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
         JOIN ad_code_value_usages u on adverts.id = u.advert_id
         JOIN funding_entities ON funding_entities.id = adverts.funding_entity_id
WHERE adverts.host_id IS NOT NULL
GROUP BY funding_entities.campaign_id, days.start, u.index, u.value
ORDER BY COUNT(*) DESC, days.start
