## Containerized Self-hosted GitHub Actions Runner

### Instructions

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
```

#### Start and run the actions-runner

Using Rancher/Kubernetes as an example:
- upon first startup, run the container with `CMD ["tail", "-f", "/dev/null"]` and run the `${ACTIONS_RUNNER_SCRIPTS_DIR}/install-runner.sh` script manually to install and configure the actions-runner. Or run the container using `CMD ["sh", "-c", "/opt/actions-runner-scripts/install-runner.sh"]` .
- after the runner has been configured, change the ENTRYPOINT/CMD to `CMD ["sh", "-c", "/opt/actions-runner-scripts/entrypoint.sh"]` to start the runner.

#### Note
- A persistent volume can be mounted at `/opt/actions-runner` to persist file changes, and has to be writable by user `runner` or `3001` .

