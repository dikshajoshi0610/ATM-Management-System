<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList"%>
<%
    String cardNum = (String) session.getAttribute("cardNumber");
    if (cardNum == null) {
        response.sendRedirect("index.html");
        return;
    }
    ArrayList<String[]> data = (ArrayList<String[]>) request.getAttribute("data");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mini Statement</title>
    <style>
        :root {
            --bg: #f0f0f0; --text: #000; --card-bg: #fff; --border: #000;
            --muted: #6c757d; --muted-hover: #444;
            --table-header: #004080; --table-header-text: #fff;
            --table-row-even: #f2f2f2; --table-row-odd: #fff; --table-border: #000;
        }
        .dark-mode {
            --bg: #121212; --text: #f0f0f0; --card-bg: #1e1e1e; --border: #444;
            --muted: #777; --muted-hover: #999;
            --table-header: #295b98; --table-header-text: #fff;
            --table-row-even: #232f3f; --table-row-odd: #1b2430; --table-border: #3a3a3a;
        }
        body {
            margin: 0; font-family: Arial, sans-serif;
            background-color: var(--bg); color: var(--text);
            display: flex; justify-content: center; align-items: flex-start;
            padding-top: 60px; min-height: 100vh;
            transition: background-color 0.3s, color 0.3s;
        }
        .container {
            width: 90%; max-width: 650px; background-color: var(--card-bg);
            border: 2px solid var(--border); border-radius: 8px;
            box-shadow: 0 0 15px rgba(0,0,0,0.15); padding: 24px;
        }
        h2 { margin: 0 0 6px 0; text-align: center; }
        .card-info { text-align: center; color: var(--muted); font-size: 14px; margin-bottom: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid var(--table-border); padding: 10px 14px; text-align: left; }
        th { background-color: var(--table-header); color: var(--table-header-text); }
        tr:nth-child(even) { background-color: var(--table-row-even); }
        tr:nth-child(odd)  { background-color: var(--table-row-odd); }
        .amount-credit { color: #28a745; font-weight: bold; }
        .amount-debit  { color: #dc3545; font-weight: bold; }
        .dark-mode .amount-credit { color: #43c475; }
        .dark-mode .amount-debit  { color: #ff6b6b; }
        .actions { text-align: center; margin-top: 20px; }
        .btn {
            display: inline-block; margin: 6px; padding: 10px 20px;
            text-decoration: none; border-radius: 5px; cursor: pointer;
            border: 1px solid var(--border); font-size: 14px;
            background-color: var(--muted); color: #fff;
        }
        .btn:hover { background-color: var(--muted-hover); }
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
    <div class="container">
        <h2>MINI STATEMENT</h2>
        <div class="card-info">Card: **** **** **** <%= cardNum.length() >= 4 ? cardNum.substring(cardNum.length()-4) : cardNum %> &nbsp;|&nbsp; Last 10 Transactions</div>
        <% if (data != null && !data.isEmpty()) { %>
        <table>
            <tr>
                <th>Date &amp; Time</th>
                <th>Type</th>
                <th>Amount (&#x20B9;)</th>
            </tr>
            <% for (String[] row : data) {
                boolean isCredit = row[1] != null && row[1].equalsIgnoreCase("deposit");
            %>
            <tr>
                <td><%= row[0] %></td>
                <td><%= row[1] != null ? row[1].substring(0,1).toUpperCase() + row[1].substring(1) : "" %></td>
                <td class="<%= isCredit ? "amount-credit" : "amount-debit" %>">
                    <%= isCredit ? "+" : "-" %>&#x20B9;<%= row[2] %>
                </td>
            </tr>
            <% } %>
        </table>
        <% } else { %>
            <p style="text-align:center; padding:20px;">No transactions found.</p>
        <% } %>
        <div class="actions">
            <a href="atm_menu.html" class="btn">&#8592; Back to Menu</a>
        </div>
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
