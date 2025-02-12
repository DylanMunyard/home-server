# Jenkins CI server
Installs Jenkins, https://www.jenkins.io/doc/book/installing/kubernetes/

The YAML in this folder was generated from the following steps:
- `git clone https://github.com/scriptcamp/kubernetes-jenkins`
- Copy [jenkins.patch](./jenkins.patch) to the `kubernetes-jenkins` repo then apply the patch: `git am jenkins.patch`

