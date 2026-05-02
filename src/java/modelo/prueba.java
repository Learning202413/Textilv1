package modelo;

import org.mindrot.jbcrypt.BCrypt;

public class prueba { // El nombre coincide con prueba.java

    public static void main(String[] args) {
        // La contraseña en texto plano que quieres cifrar
        String contrasenaPlana = "admin";

        // Generar el hash usando BCrypt
        String contrasenaCifrada = BCrypt.hashpw(contrasenaPlana, BCrypt.gensalt());

        System.out.println("Contraseña original: " + contrasenaPlana);
        System.out.println("Contraseña cifrada (BCrypt): " + contrasenaCifrada);
    }
}