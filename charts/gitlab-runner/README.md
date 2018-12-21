# Gitlab runner Configuration

The runner is managed with Helm. Configuring it requires a runner token from https://gitlab.com/groups/apolitical/-/settings/ci_cd.

## Installation

* Set up a new cluster and kubectl config in the usual way
* Run the setup script in ../../setup
* `helm install --name gitlab-runner -f ./values.yaml gitlab/gitlab-runner --kube-context=ci --set runnerRegistrationToken={token from gitlab runner config}`

## Upgrading

* `helm init --upgrade` if necessary to upgrade tiller to your client version
* `helm upgrade -f ./values.yaml gitlab-runner gitlab/gitlab-runner --set runnerRegistrationToken={token from gitlab runner config}`
