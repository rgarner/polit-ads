SELECT ad_codes.id AS ad_code_id,
       ad_codes.campaign_id,
       ad_codes.index,
       ad_codes.slug,
       ad_codes.name,
       ad_codes.quality,
       utm_campaign_values.value,
       MIN(ad_creation_time) AS first_used,
       COUNT(*),
       ROUND((COUNT(*) / SUM(COUNT(*)) OVER w_campaign_index) * 100, 2) AS percentage
FROM "ad_codes"
         JOIN utm_campaign_values on utm_campaign_values.index = ad_codes.index
         JOIN adverts ON "adverts".id = utm_campaign_values.advert_id
WHERE "ad_codes"."campaign_id" = 2
GROUP BY ad_codes.id, utm_campaign_values.value
    WINDOW w_campaign_index AS (PARTITION BY campaign_id, ad_codes.index)
ORDER BY "ad_codes"."quality" DESC
