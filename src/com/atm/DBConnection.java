package com.atm;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static Connection getConnection() {
        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/atm_management?useSSL=false&serverTimezone=UTC",
                "root",
                "Keyboard1180"
            );

        } catch (Exception e) {
            e.printStackTrace();
        }

        return con;
    }
}