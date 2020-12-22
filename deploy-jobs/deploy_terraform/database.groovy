pipeline {
  agent {
    node {
      label 'jenkins-jenkins-slave'
    }
  }
  environment {
  // Creates variables DATABASE, DATABASE_USR=joe, DATABASE_PSW=password
  DATABASE = credentials("${DB_Credentials}")
}
  stages {
    stage("install terraform")
    {
      when { expression { params.TERRAFORM_VERSION != 'default' }}
      steps {
        dir('/tmp') {
          sh  """#!/bin/bash
            wget https://releases.hashicorp.com/terraform/${params.TERRAFORM_VERSION}/terraform_${params.TERRAFORM_VERSION}_linux_amd64.zip
            unzip terraform_${params.TERRAFORM_VERSION}_linux_amd64.zip
            mv terraform /usr/bin/terraform
            chmod +x /usr/bin/terraform
            terraform version
           """
        }
      }
    }
    stage("init")
    {
      steps {
        dir('terraform/database/'+params.STACK) {
          sh  """#!/bin/bash
             set -euxo pipefail

             curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
             mv aws-iam-authenticator /usr/bin/aws-iam-authenticator
             chmod +x /usr/bin/aws-iam-authenticator
             source /usr/local/bin/set_aws_creds
             terraform init -backend-config=../backend-configs/${params.PARAM}.hcl
           """
        }
      }
    }
    stage("plan")
    {
      when { expression { params.ACTION == 'create' }}
      steps {
        dir('terraform/database/'+params.STACK) {
          sh """#!/bin/bash
            set -euxo pipefail

            source /usr/local/bin/set_aws_creds
            terraform workspace new ${params.TERRAFORM_WORKSPACE}|| terraform workspace select ${params.TERRAFORM_WORKSPACE}
            export TF_VAR_database_username=${DATABASE_USR}
            export TF_VAR_database_password=${DATABASE_PSW}
            terraform plan -var-file=./tfvars/${params.PARAM}.tfvars -no-color -out plan.out
           """
        }
      }
    }
    stage("apply")
    {
      when { expression { params.ACTION == 'create' }}
      steps {
        script {
          if( !params.AUTO ) {
            // Ask for the user to continue - after he/she checked the change set if necessary
            try {
              input(id: 'userInput', message: 'creating new stack - Continue?')
              } catch(err) {
                  currentBuild.result = 'ABORTED'
                return
              }
            }
            dir('terraform/database/'+params.STACK) {
              sh """#!/bin/bash
                set -euxo pipefail

                source /usr/local/bin/set_aws_creds
                export TF_VAR_database_username=${DATABASE_USR}
                export TF_VAR_database_password=${DATABASE_PSW}
                terraform apply -no-color -input=false plan.out
              """
            }
          }
        }
      }
      stage("destroy")
      {
        when { expression { params.ACTION == 'destroy' }}
        steps {
          script {
            if( !params.AUTO ) {
              // Ask for the user to contiune
              try {
                input(id: 'userInput', message: 'destroy stack - Continue?')
                } catch(err) {
                    currentBuild.result = 'ABORTED'
                  return
                }
              }
              dir('terraform/database/'+params.STACK) {
                sh """#!/bin/bash
                  set -euxo pipefail

                  source /usr/local/bin/set_aws_creds
                  terraform workspace select ${params.TERRAFORM_WORKSPACE}
                  export TF_VAR_database_username=${DATABASE_USR}
                  export TF_VAR_database_password=${DATABASE_PSW}
                  terraform destroy -var-file=./tfvars/${params.PARAM}.tfvars -no-color -auto-approve
                """
              }
            }
        }
      }
    }
  }
