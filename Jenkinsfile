pipeline {


    agent {
        docker {
            // Using Node 24.14.0 on Alpine 3.23 as requested
            image 'maven:3.9.9-eclipse-temurin-21'
        }
    }
    tools {
        // 'M3' must be configured in Manage Jenkins > Global Tool Configuration
        maven 'M3'
    }
//    agent any{
//        docker { image 'node:24.14.0-alpine3.23' }
//        tools {
//            maven 'M3' // 'M3' should match the name from Global Tool Configuration
//              }
//        }
//    agent {
//            docker { image 'node:24.14.0-alpine3.23' }
//        }

    environment {
        PROJECT_ID = 'spring-boot-demo-490202'
        IMAGE_NAME = 'my-spring-app'
        CLUSTER_NAME = 'spring-boot-cluster'
        ZONE = 'us-central1-c'
        REGISTRY = "us-central1-docker.pkg.dev"
        CONTAINER_REGISTRY = "container-registry"
        BUILD_NUMBER = "latest"
    }

    stages {

        stage('Checkout') {
         agent any
            steps {
                git 'https://github.com/garyboiskin/spring-boot-cluster-deploy.git'
            }
        }

        stage('Build JAR') {
         agent any
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $REGISTRY/$PROJECT_ID/$CONTAINER_REGISTR/$IMAGE_NAME:$BUILD_NUMBER .'
            }
        }

        stage('Authenticate to GCP') {
         agent any
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud config set project $PROJECT_ID
                        gcloud auth configure-docker
                    '''
                }
            }
        }

        stage('Push Image') {
         agent any
            steps {
                sh 'docker push $REGISTRY/$PROJECT_ID/$CONTAINER_REGISTR/$IMAGE_NAME:$BUILD_NUMBER'
            }
        }

        stage('Deploy to GKE') {
         agent any
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

                        kubectl set image deployment/spring-boot-app \
                        spring-boot-app=$REGISTRY/$PROJECT_ID/$CONTAINER_REGISTR/$IMAGE_NAME:$BUILD_NUMBER

                        kubectl rollout status deployment/spring-boot-app
                    '''
                }
            }
        }
    }
}