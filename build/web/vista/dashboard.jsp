<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Usuario" %>
<%
    // Protección de sesión en JSP (doble seguridad además del Filtro)
    Usuario usuarioSesion = (Usuario) session.getAttribute("usuarioSesion");
    if (usuarioSesion == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String rol = usuarioSesion.getNombreRol();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard – Sistema Textil</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; display: flex; min-height: 100vh; }

    /* Sidebar */
    aside {
      width: 240px; background: #1a1a2e; color: #ccc;
      display: flex; flex-direction: column; flex-shrink: 0;
    }
    .sidebar-logo {
      padding: 1.5rem 1.2rem;
      border-bottom: 1px solid #2d2d50;
      color: #e2b96f; font-weight: 700; font-size: 1rem;
    }
    .sidebar-logo span { display: block; font-size: .72rem; color: #888; margin-top: .2rem; }
    nav { flex: 1; padding: .8rem 0; }
    nav a {
      display: flex; align-items: center; gap: .65rem;
      padding: .7rem 1.3rem; color: #bbb; text-decoration: none;
      font-size: .88rem; transition: background .15s;
    }
    nav a:hover, nav a.activo { background: #0f3460; color: #fff; }
    nav .separador { padding: .4rem 1.3rem; font-size: .7rem; color: #555; text-transform: uppercase; margin-top: .6rem; }

    /* Solo mostrar menús según rol */
    .rol-admin, .rol-almacen { display: none; }
    <% if ("ADMINISTRADOR".equals(rol)) { %> .rol-admin { display: block; } <% } %>
    <% if ("JEFE_ALMACEN".equals(rol) || "ADMINISTRADOR".equals(rol)) { %> .rol-almacen { display: block; } <% } %>

    /* Main */
    main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
    header {
      background: #fff; padding: .9rem 1.5rem;
      display: flex; align-items: center; justify-content: space-between;
      box-shadow: 0 1px 4px rgba(0,0,0,.08);
    }
    header h2 { font-size: 1rem; color: #1a1a2e; }
    .user-info { display: flex; align-items: center; gap: .8rem; font-size: .85rem; color: #555; }
    .badge-rol {
      background: #0f3460; color: #fff;
      padding: .25rem .7rem; border-radius: 20px; font-size: .73rem; font-weight: 600;
    }
    .btn-salir {
      padding: .3rem .8rem; border: 1.5px solid #e74c3c; color: #e74c3c;
      border-radius: 6px; background: transparent; cursor: pointer;
      font-size: .8rem; transition: all .2s;
    }
    .btn-salir:hover { background: #e74c3c; color: #fff; }

    /* Cards */
    .contenido { flex: 1; padding: 1.5rem; overflow-y: auto; }
    .grid-cards {
      display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 1.1rem; margin-bottom: 1.5rem;
    }
    .card {
      background: #fff; border-radius: 12px; padding: 1.3rem 1.5rem;
      box-shadow: 0 2px 8px rgba(0,0,0,.07); cursor: pointer;
      transition: transform .15s, box-shadow .15s;
      text-decoration: none; display: block;
    }
    .card:hover { transform: translateY(-3px); box-shadow: 0 6px 18px rgba(0,0,0,.12); }
    .card-icon { font-size: 2rem; margin-bottom: .6rem; }
    .card-titulo { font-size: .9rem; font-weight: 700; color: #1a1a2e; }
    .card-desc   { font-size: .78rem; color: #777; margin-top: .3rem; }

    /* Alerta de error de acceso */
    .alerta-warn {
      background: #fef3c7; border: 1px solid #fcd34d; color: #92400e;
      border-radius: 8px; padding: .7rem 1rem; margin-bottom: 1rem; font-size: .87rem;
    }
  </style>
</head>
<body>

<!-- ── Sidebar ── -->
<aside>
  <div class="sidebar-logo">
    🧵 Textil Control
    <span>Sistema de Producción</span>
  </div>
  <nav>
    <a href="${pageContext.request.contextPath}/dashboard" class="activo">🏠 Dashboard</a>

    <div class="separador">Almacén</div>
    <div class="rol-almacen">
      <a href="${pageContext.request.contextPath}/inventario?accion=nuevo">📦 Registro de Tela</a>
      <a href="${pageContext.request.contextPath}/inventario">📋 Inventario</a>
    </div>

    <div class="separador rol-admin">Administración</div>
    <div class="rol-admin">
      <a href="${pageContext.request.contextPath}/gestion-usuarios">👥 Usuarios</a>
    </div>

    <div class="separador">Sistema</div>
    <a href="${pageContext.request.contextPath}/logout">🚪 Cerrar Sesión</a>
  </nav>
</aside>

<!-- ── Contenido Principal ── -->
<main>
  <header>
    <h2>Dashboard Principal</h2>
    <div class="user-info">
      <span>👤 <%= usuarioSesion.getNombreCompleto() %></span>
      <span class="badge-rol"><%= rol %></span>
      <form action="${pageContext.request.contextPath}/logout" method="POST" style="display:inline">
        <button type="submit" class="btn-salir">Salir</button>
      </form>
    </div>
  </header>

  <div class="contenido">

    <%-- Alerta de acceso denegado --%>
    <% if ("acceso".equals(request.getParameter("error"))) { %>
      <div class="alerta-warn">
        ⚠ No tienes permisos para acceder a esa sección.
      </div>
    <% } %>

    <%-- Mensaje de éxito --%>
    <% String msj = (String) session.getAttribute("mensajeExito");
       if (msj != null) { session.removeAttribute("mensajeExito"); %>
      <div style="background:#d1fae5;border:1px solid #6ee7b7;color:#065f46;border-radius:8px;padding:.7rem 1rem;margin-bottom:1rem;font-size:.87rem;">
        ✅ <%= msj %>
      </div>
    <% } %>

    <div class="grid-cards">

      <%-- Tarjeta siempre visible --%>
      <a href="${pageContext.request.contextPath}/inventario" class="card">
        <div class="card-icon">📦</div>
        <div class="card-titulo">Inventario de Tela</div>
        <div class="card-desc">Ver telas registradas</div>
      </a>

      <% if ("JEFE_ALMACEN".equals(rol) || "ADMINISTRADOR".equals(rol)) { %>
      <a href="${pageContext.request.contextPath}/inventario?accion=nuevo" class="card">
        <div class="card-icon">➕</div>
        <div class="card-titulo">Registrar Tela</div>
        <div class="card-desc">Ingreso nuevo de tela</div>
      </a>
      <% } %>

      <% if ("ADMINISTRADOR".equals(rol)) { %>
      <a href="${pageContext.request.contextPath}/gestion-usuarios" class="card">
        <div class="card-icon">👥</div>
        <div class="card-titulo">Gestión de Usuarios</div>
        <div class="card-desc">Perfiles y permisos (HU09)</div>
      </a>
      <% } %>

    </div>
  </div>
</main>

</body>
</html>
