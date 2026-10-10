-- Purpose: clean view of the raw applications
-- Input:   raw_applications
-- Output:  view applications_clean
-- Changes:
--   * Negative missing-value codes converted to NULL in 6 columns
--   * Missing-indicator flags added for the 3 heavily missing columns
--   * Columns renamed for readability; channel values relabeled
--   * device_fraud_count dropped (constant 0 in the Base variant)

CREATE OR REPLACE VIEW applications_clean AS
SELECT
    application_id,
    fraud_bool   AS is_fraud,
    month,

    -- Segment columns
    CASE source
        WHEN 'INTERNET' THEN 'internet'
        WHEN 'TELEAPP'  THEN 'phone'
    END          AS channel,
    device_os,
    customer_age AS age_group,

    -- Missing codes (negative values) converted to NULL
    CASE WHEN prev_address_months_count    < 0 THEN NULL ELSE prev_address_months_count    END AS prev_address_months_count,
    CASE WHEN current_address_months_count < 0 THEN NULL ELSE current_address_months_count END AS current_address_months_count,
    CASE WHEN bank_months_count            < 0 THEN NULL ELSE bank_months_count            END AS bank_months_count,
    CASE WHEN session_length_in_minutes    < 0 THEN NULL ELSE session_length_in_minutes    END AS session_length_in_minutes,
    CASE WHEN device_distinct_emails_8w    < 0 THEN NULL ELSE device_distinct_emails_8w    END AS device_distinct_emails_8w,
    CASE WHEN intended_balcon_amount       < 0 THEN NULL ELSE intended_balcon_amount       END AS intended_balance_amount,

    -- Missing-indicator flags (missingness may itself be predictive)
    CASE WHEN prev_address_months_count < 0 THEN 1 ELSE 0 END AS prev_address_missing,
    CASE WHEN bank_months_count         < 0 THEN 1 ELSE 0 END AS bank_months_missing,
    CASE WHEN intended_balcon_amount    < 0 THEN 1 ELSE 0 END AS intended_balance_missing,

    -- All remaining columns unchanged
    * EXCLUDE (
        application_id, fraud_bool, month, source, device_os, customer_age,
        prev_address_months_count, current_address_months_count, bank_months_count,
        session_length_in_minutes, device_distinct_emails_8w, intended_balcon_amount,
        device_fraud_count
    )
FROM raw_applications;