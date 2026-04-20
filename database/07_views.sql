USE atm_management;


CREATE OR REPLACE VIEW vw_user_account_card AS
SELECT
    u.user_id,
    u.full_name,
    u.email,
    u.phone,
    a.account_id,
    a.account_number,
    a.account_type,
    a.balance,
    a.currency,
    c.card_id,
    c.card_number,
    c.expiry_date,
    c.is_blocked,
    c.pin_attempts
FROM users u
JOIN accounts a ON a.user_id = u.user_id
JOIN cards c ON c.account_id = a.account_id
WHERE u.is_active = 1
  AND a.is_active = 1     -- ✅ FIXED
  AND c.is_active = 1;


CREATE OR REPLACE VIEW vw_mini_statement AS
SELECT *
FROM (
    SELECT
        t.transaction_id,
        t.account_id,
        t.transaction_type,
        t.amount,
        t.balance_before,
        t.balance_after,
        t.status,
        t.description,
        t.reference_number,
        t.transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY t.account_id
            ORDER BY t.transaction_date DESC
        ) AS rn
    FROM transactions t
) sub
WHERE rn <= 10;


CREATE OR REPLACE VIEW vw_account_balance AS
SELECT
    a.account_id,
    a.account_number,
    u.full_name,
    a.balance,
    a.currency,
    a.account_type
FROM accounts a
JOIN users u ON u.user_id = a.user_id
WHERE a.is_active = 1;   


SELECT * FROM vw_user_account_card;
SELECT * FROM vw_mini_statement;
SELECT * FROM vw_account_balance;

SELECT 'Views created successfully!' AS status;
