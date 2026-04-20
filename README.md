# ATM Management System — Deployment Guide

## Prerequisites
- Apache Tomcat 9 or 10
- MySQL 8.0+
- Java 11+ (JRE for running; JDK only if recompiling)

---

## Step 1 — Set Up the Database

Open MySQL and run the scripts in order:

```sql
source database/01_create_database.sql;
source database/02_users_table.sql;
source database/03_accounts_table.sql;
source database/04_cards_table.sql;
source database/05_transactions_table.sql;
source database/06_atm_sessions_table.sql;
source database/07_views.sql;
source database/08_stored_procedures.sql;
```

---

## Step 2 — Update Database Credentials

Edit `src/com/atm/DBConnection.java` if your MySQL credentials differ:

```java
con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/atm_management?useSSL=false&serverTimezone=UTC",
    "root",        // ← your MySQL username
    "Keyboard1180" // ← your MySQL password
);
```

After editing, recompile:
```bash
javac -cp WEB-INF/lib/servlet-api.jar -d WEB-INF/classes src/com/atm/*.java
```

---

## Step 3 — Deploy to Tomcat

**Option A — Deploy WAR file (easiest):**
1. Copy `ATM_Project_Fixed.war` into `<TOMCAT_HOME>/webapps/`
2. Start Tomcat: `<TOMCAT_HOME>/bin/startup.sh`
3. Open: http://localhost:8080/ATM_Project_Fixed/

**Option B — Deploy folder:**
1. Copy the `ATM_Project/` folder into `<TOMCAT_HOME>/webapps/`
2. Start Tomcat
3. Open: http://localhost:8080/ATM_Project/

---

## Test Login Credentials

| Card Number        | PIN  |
|--------------------|------|
| 7017812694109897   | 1920 |
| 4111111111111112   | 2345 |
| 4111111111111113   | 3456 |

---

## Bugs Fixed in This Version

| File                       | Fix Applied |
|----------------------------|-------------|
| `LoginServlet.java`        | **Critical**: `executeQuery()` was called before `setString()` parameters were bound — every login failed |
| `LoginServlet.java`        | Redirects to `index.html?error=invalid/empty/dbfail` with user-friendly messages |
| `index.html`               | Reads error param from URL and shows styled error messages |
| `BalanceServlet.java`      | Added `finally` block to close DB; fixed query to use JOIN |
| `DepositServlet.java`      | Added session null check; added `finally` block |
| `WithdrawServlet.java`     | Added proper session guard and `finally` block |
| `ChangePinServlet.java`    | Added full validation, session guard, `finally` block |
| `MiniStatementServlet.java`| Added session guard and `finally` block |
| `LogoutServlet.java`       | Added `doPost()` so logout works from both GET and POST |
| `check-balance.jsp`        | Added `<%@ page %>` directive, session guard, formatted balance |
| `mini-statement.jsp`       | Added `import="java.util.ArrayList"` (would crash without it), session guard, color-coded transactions |
| `error.jsp`                | Improved UI with dark mode and two navigation links |

---

## Project Structure

```
ATM_Project/
├── index.html              ← Login page
├── atm_menu.html           ← ATM main menu
├── deposit.html            ← Deposit form
├── withdraw.html           ← Withdraw form
├── change-pin.html         ← Change PIN form
├── logout.html             ← Logout confirmation
├── check-balance.jsp       ← Balance display (JSP)
├── mini-statement.jsp      ← Transaction history (JSP)
├── error.jsp               ← Error page (JSP)
├── src/com/atm/            ← Java source files
│   ├── DBConnection.java
│   ├── LoginServlet.java
│   ├── BalanceServlet.java
│   ├── DepositServlet.java
│   ├── WithdrawServlet.java
│   ├── ChangePinServlet.java
│   ├── MiniStatementServlet.java
│   └── LogoutServlet.java
├── WEB-INF/
│   ├── web.xml             ← Servlet mappings
│   ├── classes/com/atm/   ← Compiled .class files
│   └── lib/
│       ├── mysql-connector-j-9.6.0.jar
│       └── servlet-api.jar
└── database/               ← SQL setup scripts (run in order 01→08)
```
