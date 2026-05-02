package modelo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Singleton de conexión a MySQL.
 * Coloca este archivo en: modelo/ConexionDB.java
 */
public class ConexionDB {

    private static final String URL    = "jdbc:mysql://127.0.0.1:3306/textil_db?useSSL=false&serverTimezone=America/Lima&allowPublicKeyRetrieval=true";
    private static final String USUARIO = "root";       // Cambia por tu usuario MySQL
    private static final String CLAVE   = "";   // Cambia por tu contraseña MySQL

    private ConexionDB() {}

    public static Connection obtenerConexion() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL no encontrado. Verifica mysql-connector-j en WEB-INF/lib", e);
        }
        return DriverManager.getConnection(URL, USUARIO, CLAVE);
    }
}
