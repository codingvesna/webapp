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
git 
**Result:** built docker image, run the container from image and serve web pages

## Part 2 - Pipeline

Source Code: https://github.com/codingvesna/webapp/tree/pipeline

Docker Image: https://hub.docker.com/repository/docker/vesnam/webapp-pipeline

### Steps

1. Dockerfile
```
FROM tomcat:9
EXPOSE 8080
ADD target/*.war /usr/local/tomcat/webapps
```

2. docker-compose.yml
```
version: "3.9"
services:
   app:
      image: vesnam/webapp-pipeline
      container_name: ${container}
      ports:
         - '8081:8080'
      volumes:
         - /var/run/docker.sock:/var/run/docker.sock
         - logvolume03:/var/log
volumes:
   logvolume03: {}
```
` container ` variable passed from Jenkinsfile upon completion

3. Jenkinsfile 

 - Create credentials for DockerHub - dockerhub
 - Define variables for Docker setup
 - CI/CD Pipeline : 
    - `code` -> pull code from a `github` repo
	- `build` -> clean workspace and compile (no compile in this case)
	- `test` -> unit testing, used `-Dskiptests` because Jenkins is slowly running
	- `package` -> build`.war` file and archive
	- `build docker image` -> build image from file
	- `deploy image` -> image deployed to DockerHub
	- `run container` -> run container from deployed image 
	- `cleanup` -> remove unused image
	
```
pipeline {
    environment {
        registry = "vesnam/webapp-pipeline"
        registryCredential = 'dockerhub'
        dockerImage = ''
        container = 'java-web-app-pipeline'
    }
    agent any
    tools {
        maven 'M3'
    }
    stages {
        stage('code') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/pipeline']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/codingvesna/webapp.git']]])
            }
        }

        stage('build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('test') {
            steps {
                sh 'mvn test -DskipTests'
            }
        }

        stage('package') {
            steps {
                script {
                  sh 'mvn package -DskipTests'
                }
                archiveArtifacts artifacts: 'target/*.war', followSymlinks: false
            }
        }

        stage('build docker image'){
            steps  {
                script {
                //     sh 'docker build -t vesnam/webapp-pipeline .'
                    dockerImage = docker.build registry
                }

            }

        }
        stage('deploy image') {
            steps{
                script {
                    docker.withRegistry( 'https://registry.hub.docker.com/', registryCredential ) {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('run container') {
            steps {
                sh 'docker-compose up -d --build'
            }
        }

        stage('cleanup') {
            steps{
//                 sh 'docker stop $container'
//                 sh 'docker rm $container'
                sh 'docker rmi $registry'
            }
        }


    }
}
```
4. Check response 
  
     `curl http://localhost:8081/webapp/`
	 
5. Serve the web page 
  
     `http://localhost:8081/webapp/`
	 

## Part 3 - Multi Stage Docker Build

Source Code: https://github.com/codingvesna/webapp/tree/multi-stage

Docker Image: https://hub.docker.com/r/vesnam/webapp_multi_stage

### Steps

1. Create Dockerfile

```
FROM maven:3.8.4-jdk-11 AS build
WORKDIR /app
COPY src src
COPY pom.xml .
RUN mvn package

FROM tomcat:9
# copying from stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps
EXPOSE 8080
```
**EXPLAINED**

This is a `two-stage` build as there are two `FROM` statements.

The `build` (maven) stage is the base stage for the first build. This is used to build the `war` file for the app.

The `tomcat` stage is the second and final base image for the build. The `war` file generated in the `build` stage is copied over to this stage using
`COPY --from=build` syntax.

2. docker-compose 
```
version: "3.9"
services:
   app:
      image: vesnam/webapp_multi_stage:latest
      container_name: java-web-app-multi
      ports:
         - '8081:8080'
      volumes:
         - /var/run/docker.sock:/var/run/docker.sock
         - logvolume02:/var/log
volumes:
   logvolume02: {}
```

3. Create Jenkins Freestyle Job 

Repeat the steps from Part 1 --> Step 5 

** Next Step - update ** create pipeline

4. Serve the web page 
  
     `http://localhost:8081/app/`
