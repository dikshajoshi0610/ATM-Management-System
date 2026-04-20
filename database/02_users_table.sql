USE atm_management;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE transactions;
TRUNCATE TABLE atm_sessions;
TRUNCATE TABLE cards;
TRUNCATE TABLE accounts;
TRUNCATE TABLE users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS users (
    user_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    phone          VARCHAR(15)  NOT NULL,
    address        TEXT,
    date_of_birth  DATE,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active      TINYINT(1) NOT NULL DEFAULT 1,

    PRIMARY KEY (user_id)
);

INSERT INTO users (full_name, email, phone, address, date_of_birth)
VALUES 
('Rahul Sharma', 'rahul@example.com', '9876543210', 'Delhi', '1995-05-10'),
('Priya Singh', 'priya@example.com', '9123456780', 'Mumbai', '1996-08-15'),
('Amit Verma', 'amit@example.com', '9988776655', 'Pune', '1994-03-20');

SELECT * FROM users;
