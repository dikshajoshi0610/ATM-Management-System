package com.atm;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import javax.servlet.*;
import javax.servlet.http.*;

public class MiniStatementServlet extends HttpServlet {

    // Handles both GET and POST (deposit/withdraw redirect here via GET)
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("cardNumber") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String cardNumber = (String) session.getAttribute("cardNumber");
        ArrayList<String[]> data = new ArrayList<>();

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "SELECT transaction_date, transaction_type, amount " +
                "FROM transactions " +
                "WHERE account_id = (SELECT account_id FROM cards WHERE card_number=?) " +
                "ORDER BY transaction_date DESC LIMIT 10"
            );
            ps.setString(1, cardNumber);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String[] row = new String[3];
                row[0] = rs.getString("transaction_date");
                row[1] = rs.getString("transaction_type");
                row[2] = rs.getString("amount");
                data.add(row);
            }
            rs.close();
            ps.close();

            request.setAttribute("data", data);
            request.getRequestDispatcher("mini-statement.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
