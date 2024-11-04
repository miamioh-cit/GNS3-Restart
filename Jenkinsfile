pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = 'roseaw/powercliimage'
        DOCKER_IMAGE_TAG = 'latest'
        VCENTER_CREDENTIALS_ID = 'ServiceUser'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG} ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'roseaw-dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                        sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Restart VMs') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: env.VCENTER_CREDENTIALS_ID, usernameVariable: 'VCENTER_USER', passwordVariable: 'VCENTER_PASS')]) {
                        sh """
                        docker run --rm \
                            -e VCENTER_USER=\$VCENTER_USER \
                            -e VCENTER_PASS=\$VCENTER_PASS \
                            ${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_TAG} \
                            pwsh -File /usr/src/app/Restart-VMs.ps1 -vCenterServer 'vcenter.regional.miamioh.edu' -vCenterUser \$VCENTER_USER -vCenterPass \$VCENTER_PASS
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend color: "good", message: "Build Completed Successfully: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        unstable {
            slackSend color: "warning", message: "Build Unstable: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend color: "danger", message: "Build Failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        }
    }
}
