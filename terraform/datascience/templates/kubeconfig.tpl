apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${ENDPOINT}
    certificate-authority-data: ${CLUSTER_AUTHOTIRY_DATA}
  name: ${NAME}
contexts:
- context:
    cluster: ${NAME}
    user: ${NAME}
  name: ${NAME}
current-context: ${NAME}
users:
- name: ${NAME}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - ${AWS_REGION}
      - eks
      - get-token
      - --cluster-name
      - ${CLUSTER_NAME}
      command: aws
      env:
      - name: AWS_PROFILE
        value: ${AWS_PROFILE}
