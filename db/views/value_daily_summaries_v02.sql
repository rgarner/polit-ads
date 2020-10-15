----
-- Get the daily_values first and *then* join the ad_code_value_descriptions through ad_codes.
-- This is the biggest hint we can give the query planner, which otherwise will seq scan adverts.
-- The difference is in the order of magnitude of several minutes vs 15 seconds.
SELECT daily_values.campaign_id,
       daily_values.campaign_slug,
       daily_values.index,
       daily_values.value,
       acvd.value_name,
       daily_values.start,
       daily_values.count,
       daily_values.approximate_spend
FROM (SELECT campaigns.id AS campaign_id,
             campaigns.slug AS campaign_slug,
             u.index,
             u.value,
             days.start::date                                                           AS start,
             COUNT(*)                                                                   AS count,
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
               JOIN campaigns ON funding_entities.campaign_id = campaigns.id
      WHERE adverts.host_id IS NOT NULL
      GROUP BY campaigns.id, days.start, u.index, u.value
      ORDER BY COUNT(*) DESC, days.start) AS daily_values
         JOIN ad_codes ON ad_codes.campaign_id = daily_values.campaign_id AND ad_codes.index = daily_values.index
         LEFT JOIN ad_code_value_descriptions acvd on ad_codes.id = acvd.ad_code_id AND acvd.value = daily_values.value
