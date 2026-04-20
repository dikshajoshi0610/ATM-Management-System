USE atm_management;


CREATE TABLE IF NOT EXISTS transactions (
    transaction_id      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_id          INT UNSIGNED NOT NULL,
    card_id             INT UNSIGNED,
    transaction_type    ENUM(
                            'deposit',
                            'withdrawal',
                            'balance_inquiry',
                            'pin_change',
                            'transfer_out',
                            'transfer_in'
                        ) NOT NULL,
    amount              DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    balance_before      DECIMAL(15, 2) NOT NULL,
    balance_after       DECIMAL(15, 2) NOT NULL,
    status              ENUM('success','failed','pending')
                        NOT NULL DEFAULT 'success',
    description         VARCHAR(255),
    transaction_date    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reference_number    VARCHAR(30) NOT NULL UNIQUE,

    PRIMARY KEY (transaction_id),

    INDEX idx_account_date (account_id, transaction_date),
    INDEX idx_card_id (card_id),
    INDEX idx_txn_date (transaction_date),
    INDEX idx_reference (reference_number),

    CONSTRAINT fk_txn_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_txn_card
        FOREIGN KEY (card_id) REFERENCES cards(card_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


DROP TRIGGER IF EXISTS trg_txn_reference;

DELIMITER $$
CREATE TRIGGER trg_txn_reference
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.reference_number IS NULL OR NEW.reference_number = '' THEN
        SET NEW.reference_number = CONCAT(
            'TXN',
            DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'),
            LPAD(FLOOR(RAND() * 99999), 5, '0')
        );
    END IF;
END$$
DELIMITER ;


INSERT INTO transactions 
(account_id, card_id, transaction_type, amount, balance_before, balance_after, status, description)
VALUES
(1, 1, 'deposit',           10000.00, 40000.00, 50000.00, 'success', 'Cash deposit'),
(1, 1, 'withdrawal',         5000.00, 50000.00, 45000.00, 'success', 'ATM withdrawal'),
(1, 1, 'balance_inquiry',       0.00, 45000.00, 45000.00, 'success', 'Balance check'),
(2, 2, 'deposit',           20000.00, 55000.00, 75000.00, 'success', 'Cash deposit'),
(2, 2, 'withdrawal',        10000.00, 75000.00, 65000.00, 'success', 'ATM withdrawal'),
(3, 3, 'withdrawal',        15000.00,120000.00,105000.00, 'success', 'ATM withdrawal');


SELECT * FROM transactions;
