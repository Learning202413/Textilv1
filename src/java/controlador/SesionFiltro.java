package controlador;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import modelo.Usuario;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Filtro de seguridad de sesión.
 * Ubicación: controlador/SesionFiltro.java
 * Protege todos los Servlets excepto login y recursos estáticos.
 */
@WebFilter("/*")
public class SesionFiltro implements Filter {

    /** Rutas que NO requieren autenticación */
    private static final Set<String> RUTAS_PUBLICAS = new HashSet<>(Arrays.asList(
            "/login",
            "/login.jsp",
            "/index.html",
            "/css",
            "/js",
            "/img"
    ));

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        String contextPath = request.getContextPath();           // /PROYECTO
        String requestURI  = request.getRequestURI();
        String rutaRelativa = requestURI.substring(contextPath.length());

        // Recursos públicos o estáticos → pasar sin revisión
        if (esRutaPublica(rutaRelativa)) {
            chain.doFilter(req, res);
            return;
        }

        // Verificar sesión activa
        HttpSession session = request.getSession(false);
        boolean autenticado = (session != null)
                && (session.getAttribute("usuarioSesion") != null);

        if (!autenticado) {
            response.sendRedirect(contextPath + "/login");
            return;
        }

        // ── Control de acceso por rol (HU09) ──────────────────
        Usuario usuario = (Usuario) session.getAttribute("usuarioSesion");

        if (rutaRelativa.startsWith("/inventario") &&
                !tienePermiso(usuario, "JEFE_ALMACEN", "ADMINISTRADOR")) {
            response.sendRedirect(contextPath + "/dashboard?error=acceso");
            return;
        }

        if (rutaRelativa.startsWith("/gestion-usuarios") &&
                !tienePermiso(usuario, "ADMINISTRADOR")) {
            response.sendRedirect(contextPath + "/dashboard?error=acceso");
            return;
        }

        chain.doFilter(req, res);
    }

    private boolean esRutaPublica(String ruta) {
        for (String publica : RUTAS_PUBLICAS) {
            if (ruta.startsWith(publica)) return true;
        }
        return false;
    }

    private boolean tienePermiso(Usuario u, String... rolesPermitidos) {
        for (String rol : rolesPermitidos) {
            if (rol.equalsIgnoreCase(u.getNombreRol())) return true;
        }
        return false;
    }
}
