pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'roseaw-dockerhub'
        POWERCLI_IMAGE = 'roseaw/powerCLIimage' // Replace with your Docker image
        IMAGE_TAG = 'latest' // Or specify a particular version/tag
    }

    stages {
        stage('Restart VMs') {
            steps {
                script {
                    // Login to Docker Hub (or your Docker registry)
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }

                    // Define VMs to restart
                    def vmList = "284-01,284-02,284-03,284-04,284-05,284-06,284-07,284-08,284-09,284-10,284-11,284-12,284-13,284-14,284-15,284-16,284-17,386-00,386-01,358-01"

                    // Run the Docker container to execute the PowerCLI script
                    sh """
                    docker run --rm -v /path/to/your/scripts:/scripts ${env.POWERCLI_IMAGE}:${env.IMAGE_TAG} pwsh -File /scripts/YourScriptName.ps1 -VmList '$vmList'
                    """

                    // Logout from Docker Hub
                    sh 'docker logout'
                }
            }
        }
    }
}
