# Java Web App with Unit Tests
** Author: Vesna Milovanovic **

### App Description
  A Simple Web App built with Java & Maven.
 
  Test Cases:
  - Test Main Page - index.jsp
  - Test Login page - home.jsp

### Prerequisities for App Development

 - Java 17.0.1
 - JWebUnit - Framework used with JUnit to test the web application.
 - Apache Tomcat 9.0.56
 - Apache Maven 3.8.4 
 - AWS Elastic Beanstalk (for testing purposes)
 - IntelliJ - IDE for app development
 
## Tech Stack
 - Java
 - Git
 - Terraform
 - Ansible
 - Jenkins
 - Docker
 - AWS
 
 ## Part 1 - Freestyle Job
 **Assignment** Jenkins Freestyle Job -> Build Docker Image -> Deploy 
 
	### Prerequisities 
   - Ubuntu Server (EC2 instance)
   - Jenkins
   - Docker
 
   Source Code: https://github.com/codingvesna/webapp
   
   Docker Image: https://hub.docker.com/r/vesnam/webapp
   
   ### Steps
  1. Create Dockerfile 
  ```
	FROM tomcat:9
	EXPOSE 8080
	ADD target/devops.war /usr/local/tomcat/webapps
 ```
  2. Create docker-compose.yml 
```
version: "3.9"
services:
   app:
      image: vesnam/webapp:latest
      container_name: java-web-app
      ports:
         - '8081:8080'
      volumes:
         - /var/run/docker.sock:/var/run/docker.sock
         - logvolume01:/var/log
volumes:
   logvolume01: {}
```
  
  3. Jenkins - Java & Maven setup, add env_path
  
  4. Jenkins - Plugins Installation 
     - CloudBees Docker Build and Publish plugin
	 - Docker plugin
	 - Docker Pipeline
	 - docker-build-step
	 - Docker Compose Build Step 
	 
  5. Create Freestyle Jenkins Job
     - Checkout from SCM `https://github.com/codingvesna/webapp.git`
	 - Build Project with Maven -> package `devops.war` in `target` folder
	 - Credentials and repo name for publishing a Docker Image on DockerHub
	 - Add docker compose build step in Jenkins
	 - Post-build: archive the artifacts	 
  
  6. Serve the web page 
  
     `http://localhost:8081/devops/`
	 
     `http://localhost:8081/devops/index.jsp`
	 
	 `http://localhost:8081/devops/home.jsp`
	 
   localhost -> EC2 public_ip_addr
 
**Process Overview:** Pull the source code from GitHub, integrate GitHub with Jenkins, integrate Docker with Jenkins, start build phase.

**Result:** built docker image, run the container from image and serve web pages