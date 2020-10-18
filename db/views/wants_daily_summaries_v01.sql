SELECT days.start::date, c.slug, wants_key, COUNT(*),
       SUM(ROUND((spend_upper_bound + spend_lower_bound) / 2, 2))::bigint AS approximate_spend
FROM
    (SELECT start, start + '23 hours 59 minutes 59 seconds' AS end
     FROM generate_series(
                  '2020-07-01'::timestamptz,
                  '2020-12-31'::timestamptz, '1 day'
              ) AS start) AS days
        JOIN adverts ON adverts.ad_creation_time BETWEEN days.start AND days.end
        JOIN hosts h on adverts.host_id = h.id
        JOIN campaigns c on h.campaign_id = c.id
GROUP BY c.slug, start, wants_key
