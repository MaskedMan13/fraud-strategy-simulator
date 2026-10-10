-- Purpose: sanity checks on the metric views. Every "failures" value must be 0.
-- Input:   metrics_overall, metrics_by_month, metrics_by_segment

SELECT 'monthly counts sum to total' AS check_name,
       CASE WHEN (SELECT SUM(applications) FROM metrics_by_month)
               = (SELECT applications FROM metrics_overall)
            THEN 0 ELSE 1 END AS failures

UNION ALL

SELECT 'segment counts sum to total',
       COUNT(*)
FROM (SELECT segment_type, SUM(applications) AS total
      FROM metrics_by_segment GROUP BY segment_type)
WHERE total <> (SELECT applications FROM metrics_overall)

UNION ALL

SELECT 'segment shares sum to 100%',
       COUNT(*)
FROM (SELECT segment_type, SUM(share_of_applications_pct) AS total_share
      FROM metrics_by_segment GROUP BY segment_type)
WHERE ABS(total_share - 100) > 0.1   -- small tolerance for rounding

UNION ALL

SELECT 'fraud rates between 0 and 100',
       COUNT(*)
FROM metrics_by_segment
WHERE fraud_rate_pct < 0 OR fraud_rate_pct > 100;