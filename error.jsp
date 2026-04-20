<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Error</title>
    <style>
        :root { --bg: #f0f0f0; --text: #000; --card-bg: #fff; --border: #000; }
        .dark-mode { --bg: #121212; --text: #f0f0f0; --card-bg: #1e1e1e; --border: #444; }
        body {
            font-family: Arial, sans-serif; display: flex; justify-content: center;
            align-items: center; height: 100vh; margin: 0;
            background-color: var(--bg); color: var(--text);
            transition: background-color 0.3s, color 0.3s;
        }
        .card {
            background-color: var(--card-bg); border: 2px solid var(--border);
            border-radius: 8px; padding: 30px 40px; text-align: center;
            box-shadow: 0 0 15px rgba(0,0,0,0.15); max-width: 400px;
        }
        .card h2 { color: #dc3545; }
        .error-icon { font-size: 48px; }
        a {
            display: inline-block; margin-top: 16px; padding: 10px 20px;
            background: #6c757d; color: #fff; text-decoration: none;
            border-radius: 5px;
        }
        a:hover { background: #444; }
    </style>
</head>
<body>
    <div class="card">
        <div class="error-icon">⚠️</div>
        <h2>An Error Occurred</h2>
        <p><%= request.getAttribute("error") != null ? request.getAttribute("error") : "An unexpected error occurred." %></p>
        <a href="atm_menu.html">&#8592; Back to Menu</a>
        &nbsp;
        <a href="index.html">&#8962; Home</a>
    </div>
    <script>
        const applyTheme = (d) => document.body.classList.toggle('dark-mode', d);
        applyTheme(localStorage.getItem('atm-dark-mode') === '1');
    </script>
</body>
</html>
