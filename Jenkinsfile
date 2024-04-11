pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'roseaw-dockerhub'
        VCENTER_CREDENTIALS_ID = 'roseaw-vsphere-creds' // VMware vSphere credentials ID
        POWERCLI_IMAGE = 'roseaw/powercliimage' // Use your actual Docker image name
        IMAGE_TAG = 'latest' // Specify the image tag you want to use
    }

    stages {
        stage('Restart VMs') {
            steps {
                script {
                    // Retrieve Docker Hub credentials from Jenkins
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        // Login to Docker Hub
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }

                    // Retrieve vSphere credentials from Jenkins
                    withCredentials([usernamePassword(credentialsId: env.VCENTER_CREDENTIALS_ID, usernameVariable: 'VCENTER_USER', passwordVariable: 'VCENTER_PASS')]) {
                        // Define VMs to restart
                        def vmList = "284-01,284-02,284-03,284-04,284-05,284-06,284-07,284-08,284-09,284-10,284-11,284-12,284-13,284-14,284-15,284-16,284-17,386-00,386-01,358-01"

                        // Run the Docker container to execute the PowerCLI script
                        sh """
                        docker run --rm ${env.POWERCLI_IMAGE}:${env.IMAGE_TAG} pwsh -File /usr/src/app/Restart-VMs.ps1 -VmList '$vmList' -vCenterServer 'your_vcenter_server'
                        """
                    }

                    // Logout from Docker Hub
                    sh 'docker logout'
                }
            }
        }
    }
}
