# k8s agents
This folder contains resources required by K8s agents. 

[docker-daemon-config.yml](./docker-daemon-config.yml) is a ConfigMap used to mount inside `Docker in Docker` pods to mark the k3s container registry as insecure. Allowing pushes over http. 

## Building agent images for arm64

### Prerequisites for building ARM64 images
- `docker run --privileged --rm tonistiigi/binfmt --install all` installs the QEMU binaries
- `docker buildx create --name multiarch --platform linux/amd64,linux/arm64 --use`

Then build the image:
- `docker buildx build -f KubectlAgentDockerfile  -t hub.home.net/jenkins-agent-kubectl:latest . --platform linux/arm64 --load`
- `docker push hub.home.net/jenkins-agent-kubectl:latest`

