-- Purpose: core fraud metrics, used by the notebooks and the dashboard
-- Input:   applications_clean
-- Output:  views metrics_overall, metrics_by_month, metrics_by_segment

-- 1. Overall: one row
CREATE OR REPLACE VIEW metrics_overall AS
SELECT
    COUNT(*)                         AS applications,
    SUM(is_fraud)                    AS fraud_count,
    ROUND(100.0 * AVG(is_fraud), 2)  AS fraud_rate_pct
FROM applications_clean;

-- 2. By month: one row per month (volume and fraud rate)
CREATE OR REPLACE VIEW metrics_by_month AS
SELECT
    month,
    COUNT(*)                         AS applications,
    SUM(is_fraud)                    AS fraud_count,
    ROUND(100.0 * AVG(is_fraud), 2)  AS fraud_rate_pct
FROM applications_clean
GROUP BY month
ORDER BY month;

-- 3. By segment: long format (segment_type, segment_value) so the
--    dashboard can filter any segment with one control
CREATE OR REPLACE VIEW metrics_by_segment AS
WITH segments AS (
    SELECT 'channel' AS segment_type, channel AS segment_value,
           COUNT(*) AS applications, SUM(is_fraud) AS fraud_count
    FROM applications_clean GROUP BY channel

    UNION ALL

    SELECT 'device_os', device_os,
           COUNT(*), SUM(is_fraud)
    FROM applications_clean GROUP BY device_os

    UNION ALL

    SELECT 'age_group', CAST(age_group AS VARCHAR),
           COUNT(*), SUM(is_fraud)
    FROM applications_clean GROUP BY age_group
)
SELECT
    segment_type,
    segment_value,
    applications,
    fraud_count,
    ROUND(100.0 * fraud_count / applications, 2)                                   AS fraud_rate_pct,
    ROUND(100.0 * applications / (SELECT COUNT(*) FROM applications_clean), 2)     AS share_of_applications_pct
FROM segments
ORDER BY segment_type, fraud_rate_pct DESC;