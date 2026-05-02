# Usamos una imagen oficial de Tomcat con Java 23 (o la versión que uses)
FROM tomcat:10.1.54-jdk21-corretto

# Borramos la app por defecto de Tomcat (opcional, pero buena práctica)
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copiamos tu archivo .war compilado a la carpeta webapps de Tomcat
# NOTA: Cambia el nombre "proyecto_textil.war" si tu archivo se llama distinto
COPY dist/proyecto_textil.war /usr/local/tomcat/webapps/ROOT.war

# Exponemos el puerto que usa Tomcat
EXPOSE 8080

# Comando para iniciar Tomcat
CMD ["catalina.sh", "run"]