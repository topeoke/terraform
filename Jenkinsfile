pipeline {
    agent any

    parameters {
        string(name: 'WORKSPACE', defaultValue: 'development', description:'workspace to use in Terraform')
    }
    environment {
        TF_HOME = tool('Terraform v0.12.5')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"
        ACCESS_KEY = credentials('aws_access_key')
        ACCESS_SECRET_KEY = credentials('aws_access_secret_key')

    }
    stages {
        stage('InfrastructureInitiation'){
            steps {
                dir('project1/'){
                    sh "echo $ACCESS_KEY"
                    sh "echo $ACCESS_SECRET_KEY"
                    sh 'terraform --version'
                    sh "terraform init -input=false -plugin-dir=/var/jenkins_home \
                     -var='aws_access_key=$ACCESS_KEY' -var='aws_secret_access_key=$ACCESS_SECRET_KEY'"
                    sh "echo \$PWD"
                    sh "whoami"
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
                        sh "terraform plan -var 'aws_access_key=$ACCESS_KEY' -var 'aws_access_secret_key=$ACCESS_SECRET_KEY' \
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
                        sh "terraform destroy -var 'aws_access_key=$ACCESS_KEY' -var 'aws_secret_key=$ACCESS_SECRET_KEY' -force"
                        currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                        dir('/'){
                            sh 'terraform apply'
                        }
                    }
                }
            }
        }
    }
}
