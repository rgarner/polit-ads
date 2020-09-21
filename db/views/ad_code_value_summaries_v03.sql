SELECT ad_codes.id AS ad_code_id,
       ad_codes.campaign_id,
       ad_codes.index,
       ad_codes.slug,
       ad_codes.name,
       ad_codes.quality,
       ad_code_value_usages.value,
       MIN(ad_creation_time) AS first_used,
       COUNT(*),
       ROUND((COUNT(*) / SUM(COUNT(*)) OVER w_campaign_index) * 100, 2) AS percentage
FROM "ad_codes"
         JOIN ad_code_value_usages on ad_code_value_usages.index = ad_codes.index
         JOIN adverts ON "adverts".id = ad_code_value_usages.advert_id
WHERE "ad_codes"."campaign_id" = 2
GROUP BY ad_codes.id, ad_code_value_usages.value
    WINDOW w_campaign_index AS (PARTITION BY campaign_id, ad_codes.index)
ORDER BY "ad_codes"."quality" DESC
