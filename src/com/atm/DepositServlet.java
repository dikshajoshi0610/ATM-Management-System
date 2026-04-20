package com.atm;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class DepositServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("cardNumber") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String cardNumber = (String) session.getAttribute("cardNumber");
        String amountStr = request.getParameter("amount");

        double amount;
        try {
            amount = Double.parseDouble(amountStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid amount entered.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        if (amount <= 0) {
            request.setAttribute("error", "Amount must be greater than zero.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // Get account_id, card_id and current balance
            PreparedStatement selectPs = con.prepareStatement(
                "SELECT a.account_id, a.balance, c.card_id FROM accounts a " +
                "JOIN cards c ON a.account_id = c.account_id WHERE c.card_number=?"
            );
            selectPs.setString(1, cardNumber);
            ResultSet rs = selectPs.executeQuery();

            if (rs.next()) {
                int accountId = rs.getInt("account_id");
                double before  = rs.getDouble("balance");
                int cardId     = rs.getInt("card_id");
                rs.close();
                selectPs.close();

                // Update balance
                PreparedStatement updatePs = con.prepareStatement(
                    "UPDATE accounts SET balance = balance + ? WHERE account_id = ?"
                );
                updatePs.setDouble(1, amount);
                updatePs.setInt(2, accountId);
                updatePs.executeUpdate();
                updatePs.close();

                // Insert transaction record
                PreparedStatement insertPs = con.prepareStatement(
                    "INSERT INTO transactions (account_id, card_id, transaction_type, amount, " +
                    "balance_before, balance_after, status, description) " +
                    "VALUES (?, ?, 'deposit', ?, ?, ?, 'success', 'ATM Deposit')"
                );
                insertPs.setInt(1, accountId);
                insertPs.setInt(2, cardId);
                insertPs.setDouble(3, amount);
                insertPs.setDouble(4, before);
                insertPs.setDouble(5, before + amount);
                insertPs.executeUpdate();
                insertPs.close();

                response.sendRedirect("miniStatement");
            } else {
                request.setAttribute("error", "Account not found!");
                request.getRequestDispatcher("error.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
