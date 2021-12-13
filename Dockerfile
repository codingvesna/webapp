FROM tomcat:9
EXPOSE 8080
ADD target/devops.war /usr/local/tomcat/webapps
CMD ["/opt/tomcat/bin/catalina.sh", "run"]