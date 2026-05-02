package controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import modelo.Usuario;
import modelo.UsuarioDAO;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet de Login.
 * Ubicación: controlador/LoginServlet.java
 * HU08: Autenticación al Sistema
 *
 * Mapeos:
 *   GET  /login  → muestra login.jsp
 *   POST /login  → valida credenciales y redirige según rol
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    /** Redireccionamiento por rol (HU09) */
    private static final Map<String, String> RUTA_POR_ROL = new HashMap<>();
    static {
        RUTA_POR_ROL.put("ADMINISTRADOR",   "/dashboard");
        RUTA_POR_ROL.put("JEFE_ALMACEN",    "/inventario");
        RUTA_POR_ROL.put("JEFE_PRODUCCION", "/dashboard");
        RUTA_POR_ROL.put("TIZADOR",         "/dashboard");
        RUTA_POR_ROL.put("SUPERVISOR",      "/dashboard");
        RUTA_POR_ROL.put("MAQUINISTA",      "/dashboard");
    }

    // ── GET ───────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Si ya hay sesión activa, redirigir al dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuarioSesion") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
    }

    // ── POST ──────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Validación básica de campos vacíos
        if (username == null || username.isBlank()
                || password == null || password.isBlank()) {
            req.setAttribute("error", "Ingresa usuario y contraseña.");
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            return;
        }

        // Verificar credenciales contra BD (BCrypt interno en DAO)
        Usuario usuario = usuarioDAO.validarLogin(username, password);

        if (usuario == null) {
            req.setAttribute("error", "Usuario o contraseña incorrectos.");
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            return;
        }

        // Crear sesión y almacenar usuario
        HttpSession session = req.getSession(true);
        session.setAttribute("usuarioSesion", usuario);
        session.setMaxInactiveInterval(60 * 30); // 30 minutos de inactividad

        // Redirigir según rol (HU09)
        String destino = RUTA_POR_ROL.getOrDefault(
                usuario.getNombreRol(), "/dashboard");
        resp.sendRedirect(req.getContextPath() + destino);
    }
}
