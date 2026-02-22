## Actions Runner + Docker-in-Docker

Generic self-hosted GitHub Actions Runner + Docker-in-Docker (DinD) suitable for:
- building docker images
- running trivy scans
- managing Kubernetes clusters with kubectl
- CI/CD pipelines
- sending email notifications via msmtp

### Docker Deployment

#### Run with Your Custom Settings

Create a `.env` from `example.env` and supply the following information as follows:

For build args:
```
ACTIONS_RUNNER_IMAGE_TAG=johndoe/github-self-hosted-runner:docker-in-docker
UBUNTU_VERSION=25.10
RUNNER_USER_ID=3001
RUNNER_USER_NAME=runner
ACTIONS_RUNNER_DIR=/opt/actions-runner
OPT_INIT_SCRIPTS_DIR=/opt/init.d
OPT_PACKAGES="nano git unzip jq"
OPT_KUBECTL=true
OPT_TRIVY=true
OPT_NODE=false
FORCE_IPV4=true
```
- `ACTIONS_RUNNER_DIR` and `OPT_INIT_SCRIPTS_DIR` are also created as ENVs for ease of use.
- Mount of add custom init scripts into `OPT_INIT_SCRIPTS_DIR` for entrypoint script to pick up.
- Extend `OPT_PACKAGES` to install additional packages.
- Setting `OPT_NODE` to `true` will install `node 24 LTS`.

For environment variables:
```
SMTP_RELAY=my-smtp-relay.mydomain.com
SMTP_PORT=25
MSMTP_LOG_PATH=/mnt/logs/msmtp.log
MSMTP_NOTIF_EMAIL_FROM=noreply@mydomain.com
MSMTP_NOTIF_EMAIL_TO=notifications@mydomain.com
```

Set the following environment variables using information from GitHub repository's `Settings - Code and automation - Actions - Runners - New self-hosted runner - Runner image - Linux - Download/Configure` sections:

```
e.g.

Download

# Create a folder
$ mkdir actions-runner && cd actions-runner# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz
# Optional: Validate the hash
$ echo "5fcc01bd546ba5c3f1291c2803658ebd3cedb3836489eda3be357d41bfcf28a7  actions-runner-linux-x64-2.331.0.tar.gz" | shasum -a 256 -c
# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz

Configure

# Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/johndoe/myrepo --token ABCDEFGHIJ1KLMN2OP3QRS4TU5VWX
# Last step, run it!
$ ./run.sh
```

Map the information from above as follows:

```
GITHUB_REPO_URL=https://github.com/johndoe/myrepo
GITHUB_REPO_TOKEN='ABCDEFGHIJ1KLMN2OP3QRS4TU5VWX'
ACTIONS_RUNNER_INSTALL_FILENAME=actions-runner-linux-x64-2.331.0.tar.gz
ACTIONS_RUNNER_DOWNLOAD_URL=https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz

GITHUB_RUNNER_GROUP=
GITHUB_RUNNER_NAME=my-runner
GITHUB_RUNNER_LABELS=
GITHUB_RUNNER_WORK_FOLDER=
```

Note: Use single quotes as needed if any values contain special characters such as `$` and `#`.

Finally, run with `docker compose up -d`.

#### Use Pre-built Image
- [https://hub.docker.com/r/jameswsullivan/github-self-hosted-runner](https://hub.docker.com/r/jameswsullivan/github-self-hosted-runner)
- `docker pull jameswsullivan/github-self-hosted-runner:latest`

`latest` image is built with default settings set in `example.env`, simply create a `.env` from `example.env`, add your runtime ENVs and run with `docker compose up -d` .

#### Mount Custom Init Scripts

Modify `compose.yaml` and mount custom init scripts under `OPT_INIT_SCRIPTS_DIR=/opt/init.d`:
```
...
actions-runner:
    ...
    volumes:
        - actions-runner:${ACTIONS_RUNNER_DIR}
        - docker-sock:/var/run
        - ./my-custom-init-script.sh:${OPT_INIT_SCRIPTS_DIR}/my-custom-init-script.sh
    ...
...
```

#### Send Email with msmtp

```
printf "%s\n" "${YOUR_EMAIL_BODY}" | msmtp "${MSMTP_NOTIF_EMAIL_TO}"
```

### Kubernetes Deployment

Helm Chart coming soon ...


