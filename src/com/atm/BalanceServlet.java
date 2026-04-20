package com.atm;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class BalanceServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("cardNumber") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String cardNumber = (String) session.getAttribute("cardNumber");

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "SELECT a.balance FROM accounts a " +
                "JOIN cards c ON a.account_id = c.account_id WHERE c.card_number=?"
            );
            ps.setString(1, cardNumber);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                double balance = rs.getDouble("balance");
                rs.close();
                ps.close();
                request.setAttribute("balance", String.valueOf(balance));
                request.getRequestDispatcher("check-balance.jsp").forward(request, response);
            } else {
                rs.close();
                ps.close();
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
