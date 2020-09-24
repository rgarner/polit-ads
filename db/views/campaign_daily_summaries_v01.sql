SELECT campaigns.id AS campaign_id,
       campaigns.name,
       days.start::date,
       COUNT(*)::integer AS count,
       SUM(ROUND((adverts.spend_lower_bound + adverts.spend_upper_bound) / 2, 2)) AS approximate_spend
FROM (select start, start + '23 hours 59 minutes 59 seconds' AS end
      from generate_series(
                   '2020-01-01'::timestamp,
                   '2021-01-01'::timestamp, '1 day'
               ) AS start
     ) AS days
         JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
         JOIN funding_entities ON funding_entities.id = adverts.funding_entity_id
         JOIN campaigns ON campaigns.id = funding_entities.campaign_id
GROUP BY days.start, campaigns.id
ORDER BY campaigns.id
