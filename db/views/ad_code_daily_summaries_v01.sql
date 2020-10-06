SELECT days.start::date, acvu.index, acvu.value, COUNT(*),
       SUM((adverts.spend_lower_bound + adverts.spend_upper_bound) / 2) AS approximate_spend
FROM (SELECT start, start + '23 hours 59 minutes 59 seconds' AS end
      FROM generate_series(
                   '2020-06-01'::timestamptz,
                   '2020-12-31'::timestamptz, '1 day'
               ) AS start
     ) AS days
         JOIN adverts ON
    adverts.ad_creation_time BETWEEN days.start AND days.end
         JOIN ad_code_value_usages acvu on adverts.id = acvu.advert_id
WHERE adverts.host_id IS NOT NULL
GROUP BY days.start, acvu.index, acvu.value
ORDER BY COUNT(*) DESC, days.start
