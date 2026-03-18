pipeline {
    agent any

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
            steps {
                git 'https://github.com/garyboiskin/spring-boot-cluster-deploy.git'
            }
        }

        stage('Build JAR') {
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
            steps {
                sh 'docker push $REGISTRY/$PROJECT_ID/$CONTAINER_REGISTR/$IMAGE_NAME:$BUILD_NUMBER'
            }
        }

        stage('Deploy to GKE') {
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