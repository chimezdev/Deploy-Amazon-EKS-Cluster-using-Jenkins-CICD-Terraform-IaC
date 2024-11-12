
pipeline {
    agent any
    parameters {
        choice(
            name: 'action', 
            choices: ['apply', 'destroy'], 
            description: 'Select the Terraform action to perform'
        )
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-west-1"
    }

    // tools {
    //     // Install the Maven version configured as "M3" and add it to the path.
    //     maven "M3"
    // }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/dev']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/chimezdev/Deploy-Amazon-EKS-Cluster-using-Jenkins-CICD-Terraform-IaC']])
                }
            }
        }
        stage('Initializing Terraform') {
            steps {
                script {
                    dir('tf-aws-eks'){
                        sh 'terraform init'
                    }
                }
            }
        }
        stage('Validating Terraform') {
            steps {
                script {
                    dir('tf-aws-eks'){
                        sh 'terraform validate'
                    }
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    dir('tf-aws-eks'){
                        sh 'terraform plan -var-file=config/dev.tfvars'
                    }
                    input(message: "Are you sure to proceed?", ok: "Proceed")
                }
            }
        }
        stage('Creating/Destroying EKS Cluster') {
            steps {
                script {
                    dir('tf-aws-eks'){
                        sh "terraform ${params.action} -var-file=config/dev.tfvars -auto-approve"
                    }
                }
            }
        }
        stage('Deploying Nginx Application') {
            when {
                expression { params.action == 'apply' }  // Run only if 'apply' is selected
            }
            steps {
                script{
                    dir('manifest') {
                        sh 'aws eks update-kubeconfig --name palm-eks-cluster'
                        sh '''
                        if ! kubectl get namespace eks-nginx-app > /dev/null 2>&1; then
                            kubectl create namespace eks-nginx-app
                        else
                            echo "Namespace eks-nginx-app already exists."
                        fi
                        '''
                        sh 'kubectl apply -f deployment.yaml -n eks-nginx-app'
                        sh 'kubectl apply -f service.yaml -n eks-nginx-app'
                    }
                }
            }
        }
    }
}

