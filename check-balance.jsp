<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Session check
    String cardNum = (String) session.getAttribute("cardNumber");
    if (cardNum == null) {
        response.sendRedirect("index.html");
        return;
    }
    String balance = (String) request.getAttribute("balance");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Check Balance</title>
    <style>
        :root {
            --bg: #f0f0f0; --text: #000; --card-bg: #fff; --border: #000;
            --button-bg: #e0e0e0; --button-text: #000; --button-hover: #c0c0c0;
            --muted: #6c757d; --muted-hover: #444;
        }
        .dark-mode {
            --bg: #121212; --text: #f0f0f0; --card-bg: #1e1e1e; --border: #444;
            --button-bg: #333; --button-text: #fff; --button-hover: #555;
            --muted: #777; --muted-hover: #999;
        }
        body {
            margin: 0; font-family: Arial, sans-serif;
            background-color: var(--bg); color: var(--text);
            display: flex; justify-content: center; align-items: center; height: 100vh;
            transition: background-color 0.3s, color 0.3s;
        }
        .card {
            width: 320px; border: 2px solid var(--border); padding: 30px;
            text-align: center; background-color: var(--card-bg);
            box-shadow: 0 0 15px rgba(0,0,0,0.15); border-radius: 8px;
        }
        .card h2 { margin: 0 0 20px 0; border-bottom: 2px solid var(--border); padding-bottom: 12px; }
        .balance-display {
            font-size: 32px; font-weight: bold; margin: 20px 0;
            color: #28a745;
        }
        .dark-mode .balance-display { color: #43c475; }
        .card-info { font-size: 14px; color: var(--muted); margin-bottom: 20px; }
        .btn {
            display: inline-block; margin: 8px; padding: 10px 20px;
            text-decoration: none; border-radius: 5px; cursor: pointer;
            border: 1px solid var(--border); font-size: 14px; font-weight: bold;
            background-color: var(--button-bg); color: var(--button-text);
        }
        .btn:hover { background-color: var(--button-hover); }
        .back-btn { background-color: var(--muted); color: #fff; }
        .back-btn:hover { background-color: var(--muted-hover); }
        .switch {
            position: absolute; top: 20px; right: 20px;
            display: inline-block; width: 60px; height: 30px;
        }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider {
            position: absolute; cursor: pointer; background-color: #EA3680;
            border-radius: 30px; top: 0; left: 0; right: 0; bottom: 0; transition: 0.4s;
        }
        .slider:before {
            content: "🌙"; position: absolute; left: 8px; bottom: 4px;
            font-size: 16px; transition: 0.4s;
        }
        input:checked + .slider { background-color: #216370; }
        input:checked + .slider:before { content: "☀️"; transform: translateX(28px); }
    </style>
</head>
<body>
    <label class="switch">
        <input type="checkbox" id="toggleSwitch">
        <span class="slider"></span>
    </label>
    <div class="card">
        <h2>CHECK BALANCE</h2>
        <div class="card-info">Card: **** **** **** <%= cardNum.length() >= 4 ? cardNum.substring(cardNum.length()-4) : cardNum %></div>
        <% if (balance != null) { %>
            <div class="balance-display">&#x20B9; <%= String.format("%.2f", Double.parseDouble(balance)) %></div>
            <p>Available Balance</p>
        <% } else { %>
            <p style="color:red;">Balance not available.</p>
        <% } %>
        <br>
        <a href="atm_menu.html" class="btn back-btn">&#8592; Back to Menu</a>
    </div>
    <script>
        const toggleSwitch = document.getElementById('toggleSwitch');
        const applyTheme = (d) => { document.body.classList.toggle('dark-mode', d); toggleSwitch.checked = d; };
        applyTheme(localStorage.getItem('atm-dark-mode') === '1');
        toggleSwitch.addEventListener('change', () => {
            const isDark = toggleSwitch.checked;
            applyTheme(isDark);
            localStorage.setItem('atm-dark-mode', isDark ? '1' : '0');
        });
    </script>
</body>
</html>
