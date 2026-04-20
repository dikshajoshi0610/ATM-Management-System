USE atm_management;


CREATE TABLE IF NOT EXISTS cards (
    card_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_id   INT UNSIGNED NOT NULL,
    card_number  VARCHAR(19) NOT NULL UNIQUE,
    card_pin     VARCHAR(255) NOT NULL,
    pin_attempts TINYINT NOT NULL DEFAULT 0,
    is_blocked   TINYINT(1) NOT NULL DEFAULT 0,
    expiry_date  DATE NOT NULL,
    cvv          VARCHAR(255) NOT NULL,
    is_active    TINYINT(1) NOT NULL DEFAULT 1,
    issued_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (card_id),

    CONSTRAINT fk_cards_account
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE cards;
SET FOREIGN_KEY_CHECKS = 1;


INSERT INTO cards (account_id, card_number, card_pin, expiry_date, cvv) VALUES
(1, '7017812694109897', SHA2('1920', 256), '2028-12-31', SHA2('452', 256)),
(2, '4111111111111112', SHA2('2345', 256), '2027-06-30', SHA2('123', 256)),
(3, '4111111111111113', SHA2('3456', 256), '2029-03-31', SHA2('789', 256));


SELECT * FROM cards;