pipeline {
    agent any

    parameters {
        string(name: 'WORKSPACE', defaultValue: 'development', description:'workspace to use in Terraform')
    }
    environment {
        TF_HOME = tool('Terraform v0.12.5')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"
    }
    stages {
        stage('InfrastructureInitiation'){
            steps {
            withCredentials([string(credentialsId: 'access_key', variable: 'aws_access_key'), string(credentialsId: 'secret_key', variable: 'aws_secret_access_key')])
            {
                dir('project1/')
                {
                    sh 'terraform --version'
                    sh "terraform init -input=false --backend-config='access_key=$aws_access_key' --backend-config='secret_key=$aws_secret_access_key'"
                    sh "echo \$PWD"
                    sh "whoami"
                }
            }
            }
        }
        stage('InfrastructurePlan'){
            steps {
                dir('project1/'){
                    script {
                        try {
                           sh "terraform workspace new ${params.WORKSPACE}"
                        } catch (err) {
                            sh "terraform workspace select ${params.WORKSPACE}"
                        }
                        sh "terraform plan -var 'access_key=$aws_access_key' -var 'secret_key=$aws_secret_access_key'" \
                        > status"
                    }
                }
            }
        }
        stage('InfrastructureApply'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'confirm apply', ok: 'Apply Config'
                        apply = true
                    } catch (err) {
                        apply = false
                        sh "terraform destroy -var 'access_key=$aws_access_key' -var 'secret_key=$aws_secret_access_key' -force"
                        currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('project1/'){
                            sh 'terraform apply'
                        }
                    }
                }
            }
        }
    }
}
