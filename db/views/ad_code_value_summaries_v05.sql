SELECT ac.id AS ad_code_id,
       fe.campaign_id,
       u.index,
       u.value,
       ac.name,
       ac.quality,
       MIN(ad_creation_time) AS first_used,
       MAX(ad_creation_time) AS last_used,
       COUNT(*),
       ROUND((COUNT(*) / SUM(COUNT(*)) OVER w_campaign_index) * 100, 2) AS percentage,
       SUM((a.spend_lower_bound + a.spend_upper_bound) / 2) AS approximate_spend
FROM ad_code_value_usages u
         JOIN adverts a on u.advert_id = a.id
         JOIN funding_entities fe on a.funding_entity_id = fe.id
         JOIN campaigns c on fe.campaign_id = c.id
         JOIN ad_codes ac on c.id = ac.campaign_id AND ac.index = u.index
GROUP BY fe.campaign_id, u.index, u.value, ac.id
    WINDOW w_campaign_index AS (PARTITION BY fe.campaign_id, u.index)
