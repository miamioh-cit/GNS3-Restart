pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'roseaw/powercliimage'
        DOCKER_IMAGE_TAG = 'latest'
        VCENTER_CREDENTIALS_ID = 'roseaw-vsphere-creds'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG} ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    // Login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'roseaw-dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                    }

                    // Push Docker image to Docker Hub
                    sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG}"
                }
            }
        }
        stage('Restart VMs') {
            steps {
                script {
                    // Retrieve vSphere credentials from Jenkins
                    withCredentials([usernamePassword(credentialsId: env.VCENTER_CREDENTIALS_ID, usernameVariable: 'VCENTER_USER', passwordVariable: 'VCENTER_PASS')]) {
                        // Run the Docker container to execute the PowerCLI script
                        sh """
                        docker run --rm ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG} pwsh -File /usr/src/app/Restart-VMs.ps1 -vCenterServer 'vcenter.regional.miamioh.edu'
                        """
                    }
                }
            }
        }
    }
}
