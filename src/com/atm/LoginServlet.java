package com.atm;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.sql.*;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("LoginServlet called");

        String cardNumber = request.getParameter("cardNumber");
        String pin = request.getParameter("pin");

        System.out.println("Card: " + cardNumber);
        System.out.println("PIN: " + pin);

        if (cardNumber == null || pin == null ||
            cardNumber.trim().isEmpty() || pin.trim().isEmpty()) {
            response.sendRedirect("index.html?error=empty");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            if (con == null) {
                response.sendRedirect("index.html?error=dbfail");
                return;
            }

            ps = con.prepareStatement(
                "SELECT * FROM cards WHERE card_number=? AND card_pin=SHA2(?,256) AND is_active=1 AND is_blocked=0"
            );

            // CRITICAL: Set parameters BEFORE executeQuery
            ps.setString(1, cardNumber.trim());
            ps.setString(2, pin.trim());

            rs = ps.executeQuery();

            if (rs.next()) {
                System.out.println("Login SUCCESS");
                HttpSession session = request.getSession(true);
                session.setAttribute("cardNumber", cardNumber.trim());
                response.sendRedirect("atm_menu.html");
            } else {
                System.out.println("Login FAILED");
                response.sendRedirect("index.html?error=invalid");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.html?error=dbfail");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
