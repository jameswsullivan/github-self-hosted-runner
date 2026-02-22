ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION}

ARG RUNNER_USER_ID
ARG RUNNER_USER_NAME
ARG ACTIONS_RUNNER_DIR

ENV DEBIAN_FRONTEND="noninteractive"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

# Intall basic packages :
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nano wget git curl unzip tzdata locales ca-certificates sudo && \
    apt-get upgrade ca-certificates -y && \
    ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Install docker and configure actions-runner :
COPY ./install-runner.sh /usr/local/bin/install-runner.sh
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "Types: deb" >> /etc/apt/sources.list.d/docker.sources && \
    echo "URIs: https://download.docker.com/linux/ubuntu" >> /etc/apt/sources.list.d/docker.sources && \
    echo "Suites: $(. /etc/os-release && echo ${UBUNTU_CODENAME:-$VERSION_CODENAME})" >> /etc/apt/sources.list.d/docker.sources && \
    echo "Components: stable" >> /etc/apt/sources.list.d/docker.sources && \
    echo "Signed-By: /etc/apt/keyrings/docker.asc" >> /etc/apt/sources.list.d/docker.sources

RUN apt-get update -y && \
    apt-get install -y docker-ce-cli docker-buildx-plugin libicu-dev jq && \
    groupadd --non-unique -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    useradd --non-unique -d /${RUNNER_USER_NAME} -m -u ${RUNNER_USER_ID} -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    usermod -aG sudo ${RUNNER_USER_NAME} && \
    mkdir ${ACTIONS_RUNNER_DIR} && \
    chown ${RUNNER_USER_ID}:${RUNNER_USER_ID} ${ACTIONS_RUNNER_DIR} && \
    echo 'runner  ALL=(ALL)    NOPASSWD: ALL' >> /etc/sudoers && \
    chmod +x /usr/local/bin/install-runner.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Install latest kubectl :
RUN apt-get update -y && \
    apt-get install -y apt-transport-https gnupg && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install msmtp:
COPY ./msmtprc /etc/msmtprc

RUN apt-get install msmtp -y

# Install trivy:
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
    gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
    tee -a /etc/apt/sources.list.d/trivy.list && \
    apt-get update -y && \
    apt-get install trivy -y

# Force IPv4:
RUN echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 && \
    echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99no-pipeline

USER ${RUNNER_USER_NAME}

WORKDIR ${ACTIONS_RUNNER_DIR}

CMD ["entrypoint.sh"]


