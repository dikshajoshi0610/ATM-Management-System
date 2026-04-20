package com.atm;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class ChangePinServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("cardNumber") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String cardNumber = (String) session.getAttribute("cardNumber");
        String oldPin     = request.getParameter("oldPin");
        String newPin     = request.getParameter("newPin");
        String confirmPin = request.getParameter("confirmPin");

        // Validation
        if (oldPin == null || newPin == null || confirmPin == null ||
            oldPin.isEmpty() || newPin.isEmpty() || confirmPin.isEmpty()) {
            request.setAttribute("error", "All PIN fields are required.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        if (!newPin.equals(confirmPin)) {
            request.setAttribute("error", "New PIN and Confirm PIN do not match!");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        if (!newPin.matches("\\d{4}")) {
            request.setAttribute("error", "PIN must be exactly 4 digits!");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        if (oldPin.equals(newPin)) {
            request.setAttribute("error", "New PIN cannot be the same as old PIN!");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();

            // Verify old PIN
            PreparedStatement verifyPs = con.prepareStatement(
                "SELECT * FROM cards WHERE card_number=? AND card_pin=SHA2(?,256) AND is_active=1 AND is_blocked=0"
            );
            verifyPs.setString(1, cardNumber);
            verifyPs.setString(2, oldPin);
            ResultSet rs = verifyPs.executeQuery();

            if (!rs.next()) {
                rs.close();
                verifyPs.close();
                request.setAttribute("error", "Invalid old PIN! Please try again.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }
            rs.close();
            verifyPs.close();

            // Update to new PIN
            PreparedStatement updatePs = con.prepareStatement(
                "UPDATE cards SET card_pin=SHA2(?,256) WHERE card_number=?"
            );
            updatePs.setString(1, newPin);
            updatePs.setString(2, cardNumber);
            updatePs.executeUpdate();
            updatePs.close();

            response.sendRedirect("atm_menu.html?msg=pin_changed");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
