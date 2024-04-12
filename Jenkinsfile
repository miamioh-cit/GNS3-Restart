pipeline {
    agent any

    environment {
        // Define the Docker image name and tag
        DOCKER_IMAGE_NAME = 'roseaw/powercliimage'
        DOCKER_IMAGE_TAG = 'latest'
        
        // Define the vCenter credentials ID
        VCENTER_CREDENTIALS_ID = 'taylorw8-vsphere'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image from Dockerfile
                    sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG} ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    // Login to Docker Hub with credentials
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
                        // Set environment variables and run the Docker container to execute the PowerCLI script
                        sh """
                        docker run --rm \
                            -e VCENTER_USER_ENV=\$VCENTER_USER \
                            -e VCENTER_PASS_ENV=\$VCENTER_PASS \
                            ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG} \
                            pwsh -File /usr/src/app/Restart-VMs.ps1 -vCenterServer 'vcenter.regional.miamioh.edu' -vCenterUser \$VCENTER_USER_ENV -vCenterPass \$VCENTER_PASS_ENV
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            // Send success notification to Slack
            slackSend color: "good", message: "Build Completed Successfully: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        unstable {
            // Send warning notification to Slack
            slackSend color: "warning", message: "Build Unstable: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            // Send failure notification to Slack
            slackSend color: "danger", message: "Build Failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}

