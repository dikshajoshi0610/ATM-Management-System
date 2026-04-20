USE atm_management;


DROP PROCEDURE IF EXISTS sp_authenticate;
DELIMITER $$

CREATE PROCEDURE sp_authenticate(
    IN p_card_number VARCHAR(19),
    IN p_pin_hash VARCHAR(255)
)
BEGIN
    DECLARE v_card_id INT;
    DECLARE v_stored_pin VARCHAR(255);
    DECLARE v_attempts INT;
    DECLARE v_blocked INT;

    SELECT card_id, card_pin, pin_attempts, is_blocked
    INTO v_card_id, v_stored_pin, v_attempts, v_blocked
    FROM cards
    WHERE card_number = p_card_number AND is_active = 1
    LIMIT 1;

    IF v_card_id IS NULL THEN
        SELECT 'CARD_NOT_FOUND' AS status;

    ELSEIF v_blocked = 1 THEN
        SELECT 'BLOCKED' AS status;

    ELSEIF v_stored_pin = p_pin_hash THEN
        UPDATE cards SET pin_attempts = 0 WHERE card_id = v_card_id;
        SELECT 'GRANTED' AS status;

    ELSE
        SET v_attempts = v_attempts + 1;

        IF v_attempts >= 3 THEN
            UPDATE cards SET pin_attempts = v_attempts, is_blocked = 1 WHERE card_id = v_card_id;
            SELECT 'BLOCKED' AS status;
        ELSE
            UPDATE cards SET pin_attempts = v_attempts WHERE card_id = v_card_id;
            SELECT 'DENIED' AS status;
        END IF;
    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_check_balance;
DELIMITER $$

CREATE PROCEDURE sp_check_balance(IN p_account_id INT)
BEGIN
    DECLARE v_balance DECIMAL(15,2);

    SELECT balance INTO v_balance 
    FROM accounts 
    WHERE account_id = p_account_id;

    IF v_balance IS NULL THEN
        SELECT 'ACCOUNT_NOT_FOUND' AS status;
    ELSE
        SELECT v_balance AS balance;
    END IF;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_withdraw;
DELIMITER $$

CREATE PROCEDURE sp_withdraw(
    IN p_account_id INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_balance DECIMAL(15,2);

    START TRANSACTION;

    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id
    FOR UPDATE;

    IF v_balance IS NULL THEN
        ROLLBACK;
        SELECT 'ACCOUNT_NOT_FOUND' AS result;

    ELSEIF p_amount <= 0 THEN
        ROLLBACK;
        SELECT 'INVALID_AMOUNT' AS result;

    ELSEIF v_balance < p_amount THEN
        ROLLBACK;
        SELECT 'INSUFFICIENT_FUNDS' AS result;

    ELSE
        UPDATE accounts 
        SET balance = balance - p_amount 
        WHERE account_id = p_account_id;

        INSERT INTO transactions
        (account_id, transaction_type, amount, balance_before, balance_after, status)
        VALUES
        (p_account_id, 'withdrawal', p_amount, v_balance, v_balance - p_amount, 'success');

        COMMIT;

        SELECT 'SUCCESS' AS result, v_balance - p_amount AS balance;
    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_deposit;
DELIMITER $$

CREATE PROCEDURE sp_deposit(
    IN p_account_id INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_balance DECIMAL(15,2);

    START TRANSACTION;

    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id
    FOR UPDATE;

    IF v_balance IS NULL THEN
        ROLLBACK;
        SELECT 'ACCOUNT_NOT_FOUND' AS result;

    ELSEIF p_amount <= 0 THEN
        ROLLBACK;
        SELECT 'INVALID_AMOUNT' AS result;

    ELSE
        UPDATE accounts 
        SET balance = balance + p_amount 
        WHERE account_id = p_account_id;

        INSERT INTO transactions
        (account_id, transaction_type, amount, balance_before, balance_after, status)
        VALUES
        (p_account_id, 'deposit', p_amount, v_balance, v_balance + p_amount, 'success');

        COMMIT;

        SELECT 'SUCCESS' AS result, v_balance + p_amount AS balance;
    END IF;

END$$
DELIMITER ;