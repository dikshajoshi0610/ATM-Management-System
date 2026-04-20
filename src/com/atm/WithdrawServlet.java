package com.atm;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class WithdrawServlet extends HttpServlet {

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

            PreparedStatement ps = con.prepareStatement(
                "SELECT a.account_id, c.card_id, a.balance FROM accounts a " +
                "JOIN cards c ON a.account_id = c.account_id WHERE c.card_number=?"
            );
            ps.setString(1, cardNumber);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int    accountId = rs.getInt("account_id");
                int    cardId    = rs.getInt("card_id");
                double balance   = rs.getDouble("balance");
                rs.close();
                ps.close();

                if (balance >= amount) {
                    double before = balance;
                    double after  = balance - amount;

                    PreparedStatement update = con.prepareStatement(
                        "UPDATE accounts SET balance=? WHERE account_id=?"
                    );
                    update.setDouble(1, after);
                    update.setInt(2, accountId);
                    update.executeUpdate();
                    update.close();

                    PreparedStatement insert = con.prepareStatement(
                        "INSERT INTO transactions " +
                        "(account_id, card_id, transaction_type, amount, balance_before, balance_after, status, description) " +
                        "VALUES (?, ?, 'withdrawal', ?, ?, ?, 'success', 'ATM Withdrawal')"
                    );
                    insert.setInt(1, accountId);
                    insert.setInt(2, cardId);
                    insert.setDouble(3, amount);
                    insert.setDouble(4, before);
                    insert.setDouble(5, after);
                    insert.executeUpdate();
                    insert.close();

                    response.sendRedirect("miniStatement");

                } else {
                    request.setAttribute("error",
                        "Insufficient Balance. Available: \u20B9" + String.format("%.2f", balance));
                    request.getRequestDispatcher("error.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Account not found.");
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
