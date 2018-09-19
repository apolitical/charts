# Gitlab runner Configuration

## Installation

* Set up a new cluster and kubectl config in the usual way
* Run the setup script in ../../setup
* `helm install --name gitlab-runner -f ./values.yaml gitlab/gitlab-runner --kube-context=ci --set runnerRegistrationToken={token from gitlab runner config}`
