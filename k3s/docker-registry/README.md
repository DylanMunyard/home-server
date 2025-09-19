# Container registry
Build and tag images:
```sh
docker tag jenkins-python:01 hub.home.net/jenkins-agent-python:01
docker push hub.home.net/jenkins-agent-python:01
```

Set `image: localhost:30500/jenkins-agent-python:01` inside deployments.

The different PVCs are compatible with k3s and AKS respectively. 