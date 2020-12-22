pipelineJob('Database') {

  logRotator {
    numToKeep(10)
  }
  parameters {
    gitParam('GIT_BRANCH_NAME') {
      description 'The Git branch to checkout'
      type 'BRANCH'
      defaultValue 'origin/master'
    }
    stringParam('TERRAFORM_VERSION', 'default', 'loads terraform if not default')
    choiceParam('ACTION', ['create','destroy'], 'terraform action - create will perform init,plan and apply')
    stringParam('PARAM', '', 'tearaform parameter file used for this operation (w/o extension)')
    stringParam('TERRAFORM_WORKSPACE', 'default', 'Specify the workspace used for terraform')
    choiceParam('STACK', ['network','eks'], 'Infrastructure stack to be deployed')

    credentialsParam('DB_Credentials') {
      type('io.jenkins.plugins.credentials.secretsmanager.factory.username_password.AwsUsernamePasswordCredentials')
      required()
      description('Password for Database as stored in AWS Secrets Manager')
    }
    booleanParam('AUTO', false, 'Sets the auto-approve option for all operations')
  }
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url('https://gitlab.ep.shell.com/stage/mgmt/infra/ncloud/ncloud-devops.git')
            credentials('gitlab-token-user')
          }
          branches('${GIT_BRANCH_NAME}')
        }
      }
      scriptPath('deploy-jobs/deploy_terraform/database.groovy')
      lightweight(false)
    }
  }
}
