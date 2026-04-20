USE atm_management;


CREATE TABLE IF NOT EXISTS atm_sessions (
    session_id     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    card_id        INT UNSIGNED NOT NULL,
    account_id     INT UNSIGNED NOT NULL,
    login_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    logout_time    DATETIME,
    session_status ENUM('active','logged_out','timed_out','card_blocked') NOT NULL DEFAULT 'active',
    ip_address     VARCHAR(45),
    atm_machine_id VARCHAR(50),

    PRIMARY KEY (session_id),

    CONSTRAINT fk_session_card
    FOREIGN KEY (card_id) REFERENCES cards(card_id),

    CONSTRAINT fk_session_account
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE atm_sessions;
SET FOREIGN_KEY_CHECKS = 1;


INSERT INTO atm_sessions 
(card_id, account_id, login_time, logout_time, session_status, atm_machine_id)
VALUES
(1, 1, '2024-01-01 10:00:00', '2024-01-01 10:10:00', 'logged_out', 'ATM-DELHI-001'),
(2, 2, '2024-01-04 14:00:00', '2024-01-04 14:08:00', 'logged_out', 'ATM-MUMBAI-002'),
(3, 3, '2024-01-06 09:00:00', '2024-01-06 09:05:00', 'logged_out', 'ATM-PUNE-003');


SELECT * FROM atm_sessions;
