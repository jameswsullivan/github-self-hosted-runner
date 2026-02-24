ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION}

ARG RUNNER_USER_ID
ARG RUNNER_USER_NAME
ARG ACTIONS_RUNNER_DIR
ARG OPT_INIT_SCRIPTS_DIR
ARG OPT_PACKAGES
ARG OPT_KUBECTL
ARG OPT_TRIVY
ARG OPT_NODE
ARG FORCE_IPV4

ENV DEBIAN_FRONTEND="noninteractive"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

ENV DOCKER_HOST=${DOCKER_HOST}
ENV DOCKER_BUILDKIT=${DOCKER_BUILDKIT}
ENV ACTIONS_RUNNER_DIR=${ACTIONS_RUNNER_DIR}
ENV OPT_INIT_SCRIPTS_DIR=${OPT_INIT_SCRIPTS_DIR}

# Intall basic packages :
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y tzdata locales ca-certificates && \
    update-ca-certificates && \
    ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# Install additional packages:
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y wget curl sudo \
    ${ADDITIONAL_PACKAGES} && \
    rm -rf /var/lib/apt/lists/*

# Install msmtp:
COPY ./msmtprc /etc/msmtprc

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y msmtp && \
    rm -rf /var/lib/apt/lists/*

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
    apt-get install --no-install-recommends -y libicu-dev docker-ce-cli docker-buildx-plugin && \
    groupadd --non-unique -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    useradd --non-unique -d /${RUNNER_USER_NAME} -m -u ${RUNNER_USER_ID} -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    usermod -aG sudo ${RUNNER_USER_NAME} && \
    mkdir ${ACTIONS_RUNNER_DIR} && \
    chown ${RUNNER_USER_ID}:${RUNNER_USER_ID} ${ACTIONS_RUNNER_DIR} && \
    mkdir ${OPT_INIT_SCRIPTS_DIR} && \
    chown ${RUNNER_USER_ID}:${RUNNER_USER_ID} ${OPT_INIT_SCRIPTS_DIR} && \
    echo 'runner  ALL=(ALL)    NOPASSWD: ALL' >> /etc/sudoers && \
    chmod +x /usr/local/bin/install-runner.sh && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    rm -rf /var/lib/apt/lists/*

# Force IPv4:
RUN if [ "${FORCE_IPV4}" = "true" ]; then \
        echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4 && \
        echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99no-pipeline ; \
    fi

# Install latest kubectl :
RUN if [ "${OPT_KUBECTL}" = "true" ]; then \
        apt-get update -y && \
        apt-get install --no-install-recommends -y apt-transport-https gnupg && \
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
        install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
        rm -rf /var/lib/apt/lists/* ; \
    fi

# Install trivy:
RUN if [ "${OPT_TRIVY}" = "true" ]; then \
        apt-get update -y && \
        apt-get install --no-install-recommends -y gnupg && \
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
        gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null && \
        echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
        tee -a /etc/apt/sources.list.d/trivy.list && \
        apt-get update -y && \
        apt-get install --no-install-recommends -y trivy && \
        rm -rf /var/lib/apt/lists/* ; \
    fi

# Install node:
RUN if [ "${OPT_NODE}" = "true" ]; then \
        curl -fsSL https://deb.nodesource.com/setup_24.x -o nodesource_setup.sh && \
        chmod +x nodesource_setup.sh && \
        ./nodesource_setup.sh && \
        apt-get install --no-install-recommends -y nodejs && \
        npm install --global yarn && \
        rm -rf /var/lib/apt/lists/* ; \
    fi

USER ${RUNNER_USER_NAME}

WORKDIR ${ACTIONS_RUNNER_DIR}

CMD ["entrypoint.sh"]

