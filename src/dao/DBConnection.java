package dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL =
        "jdbc:mysql://mysql:3306/currencydb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final String USER = "root";
    private static final String PASSWORD = "root";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            System.err.println("MySQL Driver not found!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() {

        int retries = 10;

        while (retries-- > 0) {
            try {
                System.out.println("Trying to connect to MySQL...");
                return DriverManager.getConnection(URL, USER, PASSWORD);

            } catch (Exception e) {
                System.out.println("MySQL not ready, retrying in 3 seconds...");
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException ie) {
                    ie.printStackTrace();
                }
            }
        }

        System.err.println("Unable to connect to MySQL after multiple attempts.");
        return null;   // return null instead of throwing exception
    }
}
