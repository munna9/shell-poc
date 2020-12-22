pipeline {
  agent {
    node {
      label 'jenkins-jenkins-slave'
    }
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
        dir('terraform/'+params.INFRA+'/'+params.STACK) {
          sh  """#!/bin/bash
             curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
             mv aws-iam-authenticator /usr/bin/aws-iam-authenticator
             chmod +x /usr/bin/aws-iam-authenticator
             source /usr/local/bin/set_aws_creds
             terraform init -backend-config=../../backend-configs/${params.BACKEND_PARAM}.hcl
           """
        }
      }
    }
    stage("plan")
    {
      when { expression { params.ACTION == 'create' }}
      steps {
        dir('terraform/'+params.INFRA+'/'+params.STACK) {
          sh """#!/bin/bash
            set -euxo pipefail

            source /usr/local/bin/set_aws_creds
            terraform workspace new ${params.TERRAFORM_WORKSPACE}|| terraform workspace select ${params.TERRAFORM_WORKSPACE}
            terraform plan -var-file=./tfvars/${params.PARAM_DIR}/${params.PARAM}.tfvars -no-color -out plan.out | tee plan.txt
           """
           archiveArtifacts artifacts: 'plan.txt', fingerprint: true
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
            dir('terraform/'+params.INFRA+'/'+params.STACK) {
              sh """#!/bin/bash
                set -euxo pipefail

                source /usr/local/bin/set_aws_creds
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
              // Ask for the user to continue
              try {
                input(id: 'userInput', message: 'destroy stack - Continue?')
                } catch(err) {
                    currentBuild.result = 'ABORTED'
                  return
                }
              }
              dir('terraform/'+params.INFRA+'/'+params.STACK) {
                sh """#!/bin/bash
                  set -euxo pipefail

                  source /usr/local/bin/set_aws_creds
                  terraform workspace select ${params.TERRAFORM_WORKSPACE}
                  terraform destroy -no-color -var-file=./tfvars/${params.PARAM_DIR}/${params.PARAM}.tfvars -auto-approve
                """
              }
            }
        }
      }
    }
  }
