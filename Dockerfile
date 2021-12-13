FROM tomcat:9
EXPOSE 8081
ADD target/devops.war /usr/local/tomcat/webapps
