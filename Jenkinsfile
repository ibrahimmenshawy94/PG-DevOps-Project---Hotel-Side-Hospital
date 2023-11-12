pipeline {
    agent any

    environment {
        // Define the GitHub repository URL
        GITHUB_REPO = 'https://github.com/ibrahimmenshawy94/PG-DevOps-Project---Hotel-Side-Hospital.git'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout the code from the GitHub repository
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: GITHUB_REPO]]])
                }
            }
        }

        stage('Init') {
            steps {
                // Initializes Terraform
                sh 'terraform init'
            }
        }

        stage('Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                    // Applies Terraform configuration with AWS credentials
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}


