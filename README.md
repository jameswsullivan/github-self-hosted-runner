## Containerized Self-hosted GitHub Actions Runner

### Instructions


#### Overview

- My test environment is Rancher v2.8.5, but it should be able to run in any Docker/Kubernetes environment with minor configuration changes.
- The actions-runner is built on `ubuntu:24.04` .
- The actions-runner needs to be run in privileged mode.
- A `bind mount` of `/var/run/docker.sock` is needed for the container to utilize the host/node's docker socket.
- Your cluster's KubeConfig file is required for the actions-runner to interact with the deployments via `kubectl` . In our example, the KubeConfig file is obtained using a Rancher service account named `actionrunner_sa`.
- If you wish to persist your installation, a persistent volume can be mounted to the `ACTIONS_RUNNER_DIR="/opt/actions-runner"` path.
- The installation and entrypoint scripts are under the `ACTIONS_RUNNER_SCRIPTS_DIR="/opt/actions-runner-scripts"` directory.

#### Build image

- Make a copy of the `example-build.sh` and name it to `build.sh`, and modify the `ACTIONS_RUNNER_IMAGE_TAG` and `ACTIONS_RUNNER_IMAGE_FULL_TAG` variables as needed.
- Login to your docker registry before running the script.
- Run the `build.sh` to build and push your actions-runner image.

#### Configurations

The following environment variables should be supplied. These information could be found from:

Your GitHub Repo --> Settings --> Actions --> Runners --> New self-hosted runner --> Choose Linux

e.g. :

For repo `https://github.com/jameswsullivan/mysamplerepo` , the following information can be found under the `Download` and `Configure` sections :

**Download**
```
curl -o actions-runner-linux-x64-2.320.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-linux-x64-2.320.0.tar.gz
```

**Configure**
```
./config.sh --url https://github.com/jameswsullivan/mysamplerepo --token ABCDEFGHIJKLMNOPQRSTUVWXYZABC
```


The environment variables would then be configured as follows :

```
ENV GITHUB_REPO_URL="https://github.com/jameswsullivan/mysamplerepo"
ENV GITHUB_REPO_TOKEN="ABCDEFGHIJKLMNOPQRSTUVWXYZABC"
ENV ACTIONS_RUNNER_INSTALL_FILENAME="actions-runner-linux-x64-2.320.0.tar.gz"
ENV ACTIONS_RUNNER_DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-linux-x64-2.320.0.tar.gz"

ENV GITHUB_RUNNER_GROUP=""
ENV GITHUB_RUNNER_NAME="mysamplerepo-runner"
ENV GITHUB_RUNNER_LABELS=""
ENV GITHUB_RUNNER_WORK_FOLDER=""

KUBECONFIG_CONTENT="<CONTENT_FROM_YOUR_KUBECONFIG_FILE>"
```

#### Start and run the actions-runner

Using Rancher/Kubernetes as an example:
- upon first startup, run the container with `CMD ["tail", "-f", "/dev/null"]` and run the `${ACTIONS_RUNNER_SCRIPTS_DIR}/install-runner.sh` script manually to install and configure the actions-runner. Or run the container using `CMD ["sh", "-c", "/opt/actions-runner-scripts/install-runner.sh"]` .
- after the runner has been configured, change the ENTRYPOINT/CMD to `CMD ["sh", "-c", "/opt/actions-runner-scripts/entrypoint.sh"]` to start the runner.