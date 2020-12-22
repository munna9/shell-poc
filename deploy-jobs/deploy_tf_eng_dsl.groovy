pipelineJob('Engineering Datascience') {

  logRotator {
    numToKeep(10)
  }
  parameters {
    gitParam('GIT_BRANCH_NAME') {
      description 'The Git branch to checkout'
      type 'BRANCH'
      defaultValue 'origin/master'
    }
    choiceParam('INFRA', ['datascience','engineering'], 'Infrastructure to be deployed')
    choiceParam('ACTION', ['create','destroy'], 'terraform action - create will perform init,plan and apply')
    choiceParam('STACK', ['network','eks'], 'Infrastructure stack to be deployed')
    stringParam('TERRAFORM_VERSION', 'default', 'loads terraform if not default')
    stringParam('BACKEND_PARAM', '', 'Backend file used for this deployment')
    stringParam('PARAM_DIR', '', 'Directory the parameter file resides in')
    stringParam('PARAM', '', 'terraform parameter file used for this deployment (w/o extension)')
    stringParam('TERRAFORM_WORKSPACE', 'default', 'Specify the workspace used for terraform')
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
      scriptPath('deploy-jobs/deploy_terraform/engineering.groovy')
      lightweight(false)
    }
  }
}
