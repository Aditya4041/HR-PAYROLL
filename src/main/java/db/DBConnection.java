package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

	//private static final String URL = "jdbc:oracle:thin:@127.0.0.1:1521:xe";
	//private static final String URL = "jdbc:oracle:thin:@192.168.1.117:1521:xe";
	private static final String URL = "jdbc:oracle:thin:@192.168.1.75:1521:xe";
    private static final String USER = "system";
    private static final String PASSWORD = "info123";

    static {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
