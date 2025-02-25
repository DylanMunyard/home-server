# Jenkins CI server
Install Jenkins, https://www.jenkins.io/doc/book/installing/kubernetes/

The YAML in this folder was generated from the following steps:
- `git clone https://github.com/scriptcamp/kubernetes-jenkins`
- Copy [jenkins.patch](./jenkins.patch) to the `kubernetes-jenkins` repo then apply the patch: `git am jenkins.patch`

## Agents
Create an ssh agent following the guide https://www.jenkins.io/doc/book/using/using-agents/#create-a-jenkins-ssh-credential. 

- Generate a SSH key pair `ssh-keygen -f ~/.ssh/jenkins_agent_key`
- Use `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp4ytKKw6Db/1dPaK3d9A98x33xPppLFaw7cFASp4TW dylan@dylan-arch` 

Appy the [docker-daemon-config.yml](kubernetes-agent/docker-daemon-config.yml). It's mounted by the Jenkins Kubernetes agent pod, to allow pushing to the docker-registry [running in-cluster](../docker-registry)

### Images
- [Python agent Dockerfile](./AgentPythonDockerfile) 