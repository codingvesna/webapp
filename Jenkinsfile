pipeline {
    environment {
        registry = "vesnam/webapp-pipeline"
        registryCredential = 'dockerhub'
        dockerImage = ''
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

        stage('cleanup') {
            steps{
                sh "docker rmi $registry"
            }
        }

        stage('run container') {
            steps {
                sh 'docker-compose up -d --build'
            }
        }
    }
}